/*============================================================================
	File:		10 - ML - Vorbereitung

	Summary:	In diesem Script wird die Arbeit mit Python vorbereitet 

	Autor:		Frank Geisler

	Date:		May 2018
	Session:	Neuigkeiten rund um den SQL Server 2017

	SQL Server Version: 2017
------------------------------------------------------------------------------
	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/

------------------------------------------------------------------------------
-- Prüfen ob 'external scripts enabled' = 1 ist. Standardmäßig ist 
-- 'external scripts enabled' ausgeschaltet
------------------------------------------------------------------------------
EXEC sp_configure;
GO

------------------------------------------------------------------------------
-- 'external scripts enabled' einschalten. Danach den SQL Server neu starten
------------------------------------------------------------------------------
EXEC sp_configure
	'external scripts enabled'
  , 1;
RECONFIGURE WITH OVERRIDE;

------------------------------------------------------------------------------
-- Prüfen ob jetzt 'external scripts enabled' = 1 ist. 
------------------------------------------------------------------------------
EXEC sp_configure;
GO

------------------------------------------------------------------------------
-- Prüfen ob man Python Scripte ausführen kann.
-- Wenn der SQL Server nicht mit dem Launchpad Service kommunizieren kann,
-- kann es sein, dass der Service nicht läuft. Dann unter Services einschalten.
------------------------------------------------------------------------------
EXEC sp_execute_external_script
	@language = N'Python'
  , @script = N'OutputDataSet = InputDataSet;'
  , @input_data_1 = N'SELECT 1 AS hello'
WITH RESULT SETS (
					 (
						 [hello] int NOT NULL
					 )
				 );
GO

------------------------------------------------------------------------------
--  Datenbank wechseln
------------------------------------------------------------------------------
USE [tpcxbb_1gb];
GO

------------------------------------------------------------------------------
--  Tabelle models erstellen
------------------------------------------------------------------------------
DROP TABLE IF EXISTS [dbo].[models];
GO

CREATE TABLE [dbo].[models]
	(
		[language] [varchar](30) NOT NULL
	  , [model_name] [varchar](30) NOT NULL
	  , [model] [varbinary](MAX) NOT NULL
	  , [create_time] [datetime2](7) NULL
			DEFAULT (SYSDATETIME())
	  , [created_by] [nvarchar](500) NULL
			DEFAULT (SUSER_SNAME())
	  ,
	  PRIMARY KEY CLUSTERED
	  (
		  [language]
		, [model_name]
	  )
	);
GO

------------------------------------------------------------------------------
--  Sicht erstellen die Trainig-Daten zurückliefert
------------------------------------------------------------------------------
CREATE OR ALTER VIEW product_reviews_training_data
AS
SELECT TOP (CAST((
					 SELECT
						  COUNT(*)
					 FROM product_reviews
				 ) * .9 AS int)
		   ) CAST(pr_review_content AS nvarchar(4000)) AS pr_review_content
	 , CASE WHEN pr_review_rating < 3 THEN 1
			WHEN pr_review_rating = 3 THEN 2
			ELSE 3
	   END AS tag
FROM   product_reviews;
GO

------------------------------------------------------------------------------
--  Sicht erstellen die Test-Daten zurückliefert
------------------------------------------------------------------------------
CREATE OR ALTER VIEW product_reviews_test_data
AS
SELECT TOP(CAST( ( SELECT COUNT(*) FROM   product_reviews)*.1 AS INT))
  CAST(pr_review_content AS NVARCHAR(4000)) AS pr_review_content,
  CASE 
   WHEN pr_review_rating <3 THEN 1 
   WHEN pr_review_rating =3 THEN 2 
   ELSE 3 
  END AS tag 
FROM   product_reviews;
GO

------------------------------------------------------------------------------
--  Text Klassifizierungs-Modell erstellen
------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[create_text_classification_model]
AS
	BEGIN
		DECLARE
			@model varbinary(MAX)
		  , @train_script nvarchar(MAX);
		-- Das Python Script das ausgeführt werden soll
		SET @train_script = N'
##Import necessary packages
from microsoftml import rx_logistic_regression,featurize_text, n_gram
import pickle
## Defining the tag column as a categorical type
training_data["tag"] = training_data["tag"].astype("category")

## Create a machine learning model for multiclass text classification. 
## We are using a text featurizer function to split the text in features of 2-word chunks

#ngramLength=2: include not only "Word1", "Word2", but also "Word1 Word2"
#weighting="TfIdf": Term frequency & inverse document frequency
model = rx_logistic_regression(formula = "tag ~ features", data = training_data, method = "multiClass", ml_transforms=[
                        featurize_text(language="English",
                                     cols=dict(features="pr_review_content"),
                                      word_feature_extractor=n_gram(2, weighting="TfIdf"))])

## Serialize the model so that we can store it in a table
modelbin = pickle.dumps(model)';

		EXECUTE sp_execute_external_script
			@language = N'Python'
		  , @script = @train_script
		  , @input_data_1 = N'SELECT * FROM product_reviews_training_data'
		  , @input_data_1_name = N'training_data'
		  , @params = N'@modelbin varbinary(max) OUTPUT'
		  , @modelbin = @model OUTPUT;
		-- Modell in Datenbanktabelle speichern     
		DELETE FROM dbo.models
		WHERE model_name = 'rx_logistic_regression'
			  AND language = 'Python';
		INSERT INTO dbo.models (
								   language
								 , model_name
								 , model
							   )
		VALUES (
				   'Python', 'rx_logistic_regression', @model
			   );
	END;
GO

------------------------------------------------------------------------------
--  Text Klassifizierer der eine Sentiment Analyse auf Online Reviews durchführen
--  kann (Positiv, Negativ und Neutral)
------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[predict_review_sentiment]
AS
	BEGIN
		DECLARE
			@model_bin varbinary(MAX)
		  , @prediction_script nvarchar(MAX);

		-- Das Binärobjekt aus der Model-Tabelle auswählen
		SET @model_bin = (
							 SELECT
								   model
							 FROM  dbo.models
							 WHERE model_name = 'rx_logistic_regression'
								   AND language = 'Python'
						 );


		-- Das Python Script das ausgeführt werden soll
		SET @prediction_script = N'
from microsoftml import rx_predict
from revoscalepy import rx_data_step 
import pickle

## The input data from the query in @input_data_1 is populated in test_data
## We are selecting 10% of the entire dataset for testing the model

## Unserialize the model
model = pickle.loads(model_bin)

## Use the rx_logistic_regression model 
predictions = rx_predict(model = model, data = test_data, extra_vars_to_write = ["tag", "pr_review_content"], overwrite = True)

## Converting to output data set
result = rx_data_step(predictions)';

		EXECUTE sp_execute_external_script
			@language = N'Python'
		  , @script = @prediction_script
		  , @input_data_1 = N'SELECT * FROM product_reviews_test_data'
		  , @input_data_1_name = N'test_data'
		  , @output_data_1_name = N'result'
		  , @params = N'@model_bin varbinary(max)'
		  , @model_bin = @model_bin
		WITH RESULT SETS (
							 (
								 "Review" nvarchar(MAX)
							   , "tag" float
							   , "Predicted_Score_Negative" float
							   , "Predicted_Score_Neutral" float
							   , "Predicted_Score_Positive" float
							 )
						 );
	END;
GO

------------------------------------------------------------------------------
--  Stored Procedure die ein vortrainiertes Modell verwendet
------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[get_review_sentiment]
AS
	BEGIN
		DECLARE @script nvarchar(MAX);

		--The Python script we want to execute
		SET @script = N'
from microsoftml import rx_featurize, get_sentiment
# Get the sentiment scores
sentiment_scores = rx_featurize(data=reviews, ml_transforms=[get_sentiment(cols=dict(scores="review"))])
# Lets translate the score to something more meaningful
sentiment_scores["Sentiment"] = sentiment_scores.scores.apply(lambda score: "Positive" if score > 0.6 else "Negative")
'		;

		EXECUTE sp_execute_external_script
			@language = N'Python'
		  , @script = @script
		  , @input_data_1 = N'SELECT CAST(pr_review_content AS NVARCHAR(4000)) AS review FROM product_reviews'
		  , @input_data_1_name = N'reviews'
		  , @output_data_1_name = N'sentiment_scores'
		WITH RESULT SETS (
							 (
								 "Review" nvarchar(MAX)
							   , "score" float
							   , "Sentiment" nvarchar(30)
							 )
						 );

	END;
GO

------------------------------------------------------------------------------
--  Stored Procedure die eine Sentiment Analyse auf vortrainiertem Modell vornimmt
------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[get_sentiment](@text NVARCHAR(MAX)) 
AS
BEGIN
 DECLARE  @script nvarchar(max);

 --Python Script das ausgeführt werden soll
 SET @script = N'

import pandas as p
from microsoftml import rx_featurize, get_sentiment

analyze_this = text

## Create the data 

text_to_analyze = p.DataFrame(data=dict(Text=[analyze_this]))

## Get the sentiment scores 
## get_sentiment returns the probability that the sentiment of the input data is positive
## rx_featurize transforms data from an input data set to an output data set 
## ml_transformations specifies the type of transformation

sentiment_scores = rx_featurize(data=text_to_analyze,ml_transforms=[get_sentiment(cols=dict(scores="Text"))])

## Lets translate the score to something more meaningful by determining the range of
## values that will determine positivity 

sentiment_scores["Sentiment"] = sentiment_scores.scores.apply(lambda score: "Positive" if score > 0.6 else "Negative")
';
 
 EXECUTE sp_execute_external_script
    @language = N'Python'
    , @script = @script
    , @output_data_1_name = N'sentiment_scores'
    , @params = N'@text nvarchar(max)'
    , @text = @text
    WITH RESULT SETS (("Text" NVARCHAR(MAX),"Score" FLOAT, "Sentiment" NVARCHAR(30)));   
END    
GO


