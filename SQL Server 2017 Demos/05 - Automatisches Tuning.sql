/*============================================================================
	File:		05 - Automatisches Tuning

	Summary:	Dieses Script demonstriert das Auto-Tuning vom SQL Server 2017 
	            
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
USE master;
GO

------------------------------------------------------------------------------
-- QueryStore für WideWorldImporters einschalten
------------------------------------------------------------------------------
ALTER DATABASE WideWorldImporters
SET
	QUERY_STORE
		(
			OPERATION_MODE = READ_WRITE
		  , DATA_FLUSH_INTERVAL_SECONDS = 60
		  , INTERVAL_LENGTH_MINUTES = 1
		  , QUERY_CAPTURE_MODE = ALL
		);
GO

------------------------------------------------------------------------------
-- SETUP - alles löschen und auf Anfang
------------------------------------------------------------------------------
USE WideWorldImporters;
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
ALTER DATABASE CURRENT SET QUERY_STORE CLEAR ALL;
ALTER DATABASE CURRENT SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = OFF);
GO

------------------------------------------------------------------------------
-- Strored Procedure anlegen
------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.report
	(
		@packagetypeid int
	)
AS
	BEGIN

		EXEC sp_executesql
			N'select avg([UnitPrice]*[Quantity])
						from Sales.OrderLines
						where PackageTypeID = @packagetypeid'
, N'@packagetypeid int'
, @packagetypeid;
	END
GO

/*
==============================================================================
== TEIL 1
== Plan Regression zeigen
==============================================================================
*/

------------------------------------------------------------------------------
-- 1. Workload starten - Prozedur wird 30 Mal ausgeführt
--    Beobachten, dass die Ausführungszeit ~5 Sekunden insgesamt ist
--    Tatsächlichen Ausführungsplan einschließen
------------------------------------------------------------------------------
BEGIN
	DECLARE @packagetypeid int = 7;
	EXEC dbo.report
		@packagetypeid
END
GO 30

------------------------------------------------------------------------------
-- 1. Prozedur ausführen die Plan Regression verursacht
------------------------------------------------------------------------------
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;

DECLARE @packagetypeid int = 1;
EXEC report
	@packagetypeid;
GO

------------------------------------------------------------------------------
-- 3. Workload noch mal starten. Nun ist es langsamer.
--    Ausführungszeit liegt bei ~18 Sekunden obwohl nur 20 Durchgänge 
--    gestartet werden (im Vergleich - oben 30 Durchgänge)
------------------------------------------------------------------------------
BEGIN
	DECLARE @packagetypeid int = 7;
	EXEC dbo.report
		@packagetypeid;
END
GO 20

------------------------------------------------------------------------------
-- Query Store löschen
------------------------------------------------------------------------------
EXECUTE sp_query_store_flush_db;
GO

------------------------------------------------------------------------------
-- 4. Empfehlungen von der Datenbank anzeigen
-- Anmerkung: Benutzer kann das Script anwenden und eine Plankorrektur erzwingen
-- um das Problem zu beheben. In Teil 2 zeigen wir einen besseren Weg
-- Automatisches Tuning
------------------------------------------------------------------------------
SELECT
	 reason
   , score
   , JSON_VALUE(details, '$.implementationDetails.script') script
   , planForceDetails.*
FROM sys.dm_db_tuning_recommendations
CROSS APPLY
	 OPENJSON(details, '$.planForceDetails')
	 WITH (
			  query_id int '$.queryId'
			, [new plan_id] int '$.regressedPlanId'
			, [recommended plan_id] int '$.forcedPlanId'
		  ) AS planForceDetails;

/*
==============================================================================
== TEIL 2
== Automatisches Tuning
==============================================================================
*/

------------------------------------------------------------------------------
-- SETUP - alles löschen und auf Anfang
------------------------------------------------------------------------------
USE WideWorldImporters;
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
ALTER DATABASE CURRENT SET QUERY_STORE CLEAR ALL;
ALTER DATABASE CURRENT SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON);
GO

------------------------------------------------------------------------------
-- Prüfen ob der Status von Force Last Good Plan (FLGP) auf ON ist
------------------------------------------------------------------------------
SELECT
	 name
   , actual_state_desc
FROM sys.database_automatic_tuning_options;
GO

------------------------------------------------------------------------------
-- 1. Workload starten. Prozedur wird 20 Mal ausgeführt.
--    Ausführungszeit liegt bei ~7 Sekunden insgesamt. 
--    Tatsächlichen Ausführungsplan einschließen
------------------------------------------------------------------------------
BEGIN
	DECLARE @packagetypeid int = 7;
	EXEC dbo.report
		@packagetypeid
END
GO 20

------------------------------------------------------------------------------
-- 2. Prozedur ausführen die Plan Regression erzeugt
------------------------------------------------------------------------------
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;

DECLARE @packagetypeid int = 1;
EXEC report
	@packagetypeid;
GO

------------------------------------------------------------------------------
-- 3. Workload noch mal starten. Prozedur wird 20 Mal ausgeführt.
--    Ausführungszeit liegt bei ~18 Sekunden insgesamt und ist langsamer. 
------------------------------------------------------------------------------
BEGIN
	DECLARE @packagetypeid int = 7;
	EXEC dbo.report
		@packagetypeid;
END
GO 20

------------------------------------------------------------------------------
-- 4. Empfehlungen finden die Abfragegeschwindigkeit verbessern.
------------------------------------------------------------------------------
SELECT
	 reason
   , score
   , JSON_VALUE(state, '$.currentValue') state
   , JSON_VALUE(details, '$.implementationDetails.script') script
   , planForceDetails.*
FROM sys.dm_db_tuning_recommendations
CROSS APPLY
	 OPENJSON(details, '$.planForceDetails')
	 WITH (
			  query_id int '$.queryId'
			, [new plan_id] int '$.regressedPlanId'
			, [recommended plan_id] int '$.forcedPlanId'
		  ) AS planForceDetails;
GO

------------------------------------------------------------------------------
-- 5. Warten bis die Empfehlungen angewendet werden und Workload noch mal 
--    starten. Feststellen, dass es schneller läuft. Ausführungszeit sollte
--    bei ~7 Sekunden liegen. Query Plan sollte einen Scan enthalten.
------------------------------------------------------------------------------
BEGIN
	DECLARE @packagetypeid int = 7;
	EXEC dbo.report
		@packagetypeid;
END
GO 20

------------------------------------------------------------------------------
-- Unter Query Store die Abfrage Tracked Queries öffnen und Plan History
-- anschauen. 
------------------------------------------------------------------------------