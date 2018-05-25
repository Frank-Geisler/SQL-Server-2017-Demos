/*============================================================================
	File:		04 - AQP - Batch Mode Adaptive Joins - Test

	Summary:	Dieses Script demonstriert Batch Mode Adaptive Joins. 
	            
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
USE [AQP Testing]
GO

------------------------------------------------------------------------------
-- Kompatibilitäts-Modus auf SQL Server 2017 setzen
------------------------------------------------------------------------------
ALTER DATABASE [AQP TESTING ]
SET
	COMPATIBILITY_LEVEL = 140;
GO

------------------------------------------------------------------------------
-- Adaptive Join Operator mit Hash Match zeigen
-- Tatsächlichen Ausführungsplan einschließen
------------------------------------------------------------------------------
SELECT
		   *
FROM	   dbo.AdaptiveJoinTest aj
INNER JOIN dbo.ReferenceTable rt
ON aj.Join_id = rt.Ref_id;
GO

------------------------------------------------------------------------------
-- Adaptive Join Operator mit Nested Inner Join zeigen
-- Tatsächlichen Ausführungsplan einschließen
------------------------------------------------------------------------------
SELECT
		   *
FROM	   dbo.AdaptiveJoinTest aj
INNER JOIN dbo.ReferenceTable rt
ON aj.Join_id = rt.Ref_id
WHERE	   aj.CustNo = 1;
GO

