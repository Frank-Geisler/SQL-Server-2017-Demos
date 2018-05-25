/*============================================================================
	File:		03 - AQP - Batch Mode Adaptive Joins - Create Table

	Summary:	Dieses Script erzeugt eine Tabelle und eine Referenz-Tabelle
	            mit Demo-Datensätzen die zur Demonstration des Batch Mode
				Adaptive Joins benötigt werden. 
	            
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
-- Datenbank setzen
------------------------------------------------------------------------------
USE [AQP TESTING]
GO

------------------------------------------------------------------------------
-- Tabelle erzeugen
------------------------------------------------------------------------------
DROP TABLE IF EXISTS dbo.AdaptiveJoinTest;
GO

CREATE TABLE dbo.AdaptiveJoinTest
	(
		CustNo int NOT NULL
	  , PONo int NOT NULL
	  , OrderNo int NOT NULL
	  , Join_id int NOT NULL
	  , INDEX indextest CLUSTERED COLUMNSTORE
	);
GO
 
------------------------------------------------------------------------------
-- Demo-Datensätze in die Tabelle einfügen
------------------------------------------------------------------------------
INSERT INTO dbo.AdaptiveJoinTest WITH (TABLOCK)
			SELECT TOP (50000) my.Test
				 , my.Test
				 , my.Test
				 , my.Test
			FROM   (
					   SELECT
								  ROW_NUMBER() OVER (ORDER BY (
																  SELECT
																	  NULL
															  )
													) Test
					   FROM		  master..spt_values temp1
					   CROSS JOIN master..spt_values temp2
				   ) my
OPTION (MAXDOP 1);

ALTER TABLE dbo.AdaptiveJoinTest
REBUILD WITH (
				 MAXDOP = 1
			 );

------------------------------------------------------------------------------
-- Refernz-Tabelle erzeugen
------------------------------------------------------------------------------
DROP TABLE If exists dbo.ReferenceTable;
GO
 
CREATE TABLE dbo.ReferenceTable (
    Ref_id INT NOT NULL,
    Value VARCHAR(2000) NOT NULL,
    PRIMARY KEY (Ref_id)
);
GO

------------------------------------------------------------------------------
-- Demo-Datensätze in die Referenz-Tabelle einfügen
------------------------------------------------------------------------------
INSERT INTO dbo.ReferenceTable WITH (TABLOCK)
			SELECT	   TOP (200000) ROW_NUMBER() OVER (ORDER BY (
																	SELECT
																		NULL
																)
													  )
					 , REPLICATE('T', 2000)
			FROM	   master..spt_values temp1
			CROSS JOIN master..spt_values temp2;
GO
