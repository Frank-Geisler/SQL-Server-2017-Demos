/*============================================================================
	File:		01 - AQP - MSTVF

	Summary:	Dieses Script erzeugt eine neue Multi Statement Table Valued 
				Function und zeigt die �berlappte Ausf�hrung f�r Multi Statement
				Table Valued Functions (Interleaved execution for MSTVFs)
	            
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
Use [AQP Testing]

------------------------------------------------------------------------------
-- Neue MSTVF Funktion erstellen
------------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.MVF(@n int)
RETURNS @t TABLE(SalesOrderNumber NVARCHAR(40), SalesOrderLineNumber TINYINT)
WITH SCHEMABINDING
AS
BEGIN
    INSERT @t(SalesOrderNumber, SalesOrderLineNumber)
    SELECT TOP(@n)
        ReSellerSalesOrderNumber, 
        ReSellerSalesOrderLineNumber
    FROM
        dbo.TopResellerSales;
    RETURN;
END
GO

/*
==============================================================================
== Qualit�t des Plans zeigen der die MSTVF enth�lt 
==============================================================================*/

------------------------------------------------------------------------------
-- Procedure Cache der Datenbank leeren 
------------------------------------------------------------------------------
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

------------------------------------------------------------------------------
-- Erstmal den Kompatibilit�ts-Level auf 130 (SQL Server 2016) setzen um das 
-- bisherige Verhalten zu zeigen wenn man eine MSTVF in einer Abfrage aufruft
-- Tats�chlichen Ausf�hrungsplan einschlie�en
------------------------------------------------------------------------------
ALTER DATABASE [AQP Testing]
SET
	COMPATIBILITY_LEVEL = 130;
GO

SELECT
	 c = COUNT_BIG(*)
FROM dbo.TopResellerSales c
JOIN dbo.MVF(50000) t
ON t.SalesOrderNumber = c.ReSellerSalesOrderNumber
   AND t.SalesOrderLineNumber = c.ReSellerSalesOrderLineNumber;
GO

------------------------------------------------------------------------------
-- Dieselbe Abfrage, jetzt aber mit Kompatibilit�ts-Level 140 (SQL Server 2017)
-- Hier noch mal den Query Plan anzeigen 
-- Tats�chlichen Ausf�hrungsplan einschlie�en
------------------------------------------------------------------------------
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

ALTER DATABASE [AQP Testing]
SET
	COMPATIBILITY_LEVEL = 140;
GO

SELECT
	 c = COUNT_BIG(*)
FROM dbo.TopResellerSales c
JOIN dbo.MVF(50000) t
ON t.SalesOrderNumber = c.ReSellerSalesOrderNumber
   AND t.SalesOrderLineNumber = c.ReSellerSalesOrderLineNumber;
GO