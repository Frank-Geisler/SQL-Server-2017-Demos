/*============================================================================
	File:		11 - ML - Mit der Textklassifizierung arbeiten

	Summary:	In diesem Script arbeiten wir mit der Textklassifizierung die
	            in Python implementiert wurde. 

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
--  Datenbank wechseln
------------------------------------------------------------------------------
USE [tpcxbb_1gb];
GO

------------------------------------------------------------------------------
-- Prozedur ausführen - dauert etwas
------------------------------------------------------------------------------
EXECUTE dbo.create_text_classification_model;
GO

------------------------------------------------------------------------------
-- Objektmodell anschauen das in der Tabelle Model gespeichert wurde
------------------------------------------------------------------------------
SELECT * FROM dbo.models;
GO
------------------------------------------------------------------------------
-- Sentiment Analyse durchführen. Multiklassen Vorhersage
------------------------------------------------------------------------------
EXECUTE dbo.predict_review_sentiment 
GO

------------------------------------------------------------------------------
-- Sentiment Analyse durchführen. Multiklassen Vorhersage
------------------------------------------------------------------------------
EXECUTE [dbo].[get_review_sentiment];
GO

------------------------------------------------------------------------------
-- Negative Review
------------------------------------------------------------------------------
EXECUTE [dbo].[get_sentiment]
	N'These are not a normal stress reliever. First of all, they got sticky, hairy and dirty on the first day I received them. Second, they arrived with tiny wrinkles in their bodies and they were cold. Third, their paint started coming off. Fourth when they finally warmed up they started to stick together. Last, I thought they would be foam but, they are a sticky rubber. If these were not rubber, this review would not be so bad.';
GO

------------------------------------------------------------------------------
-- Positive Review
------------------------------------------------------------------------------
EXECUTE [dbo].[get_sentiment]
	N'These are the cutest things ever!! Super fun to play with and the best part is that it lasts for a really long time. So far these have been thrown all over the place with so many of my friends asking to borrow them because they are so fun to play with. Super soft and squishy just the perfect toy for all ages.';
GO