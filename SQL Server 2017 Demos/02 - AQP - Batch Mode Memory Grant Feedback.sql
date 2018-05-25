/*============================================================================
	File:		02 - AQP - Batch Mode Memory Grant Feedback

	Summary:	Dieses Script zeigt wie das Batch Mode Memory Grant Feedback
	            funktioniert. Es wird dem SQL Server vorgespiegelt, dass eine
				Tabelle 4.000.000 Datensätze enthält. Daraufhin erzeugt er 
				wegen Speichermangels einen Spill in die TempDB. Durch das
				Feedback wird festgestellt, dass gar nicht so viel Speicher
				benötigt würde, es werden ja nur 1.160.121 Datensätze 
				zurückgeliefert. Beim zweiten Durchlauf verschätzt sich
				der SQL Server nach unten und hat somit zu wenig Speicher
				für die Abfrage allokiert (Memory Grant). Beim dritten Durchlauf
				allokiert er dann die richtige Menge an Speicherplatz. 
	            
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
USE [AQP Testing];
GO

------------------------------------------------------------------------------
-- Datenbank auf den SQL Server 2017 Kompatibilitätslevel setzen 
------------------------------------------------------------------------------
ALTER DATABASE [AQP Testing]
SET
	COMPATIBILITY_LEVEL = 140;
GO

------------------------------------------------------------------------------
-- Statistiken aktualisieren um dem Server mitzuteilen, dass es 4.000.000 Zeilen
-- in der Tabelle gibt. In Wirklichkeit gibt es 1.160.121 Zeilen.
-- ACHTUNG: Diese manuelle Aktualisierung der Statistik ist nur zu 
--          Demonstrationszwecken und wird nicht als generelle Praxis empfohlen. 
------------------------------------------------------------------------------
UPDATE STATISTICS dbo.TopResellerSales
WITH
	ROWCOUNT = 4000000;

------------------------------------------------------------------------------
-- Cache leeren 
------------------------------------------------------------------------------
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

------------------------------------------------------------------------------
-- Die SELECT Abfrage ausführen um Daten aus einem bestimmten Datumsbereich
-- auszuwählen. Die Abfrage wird drei Mal hintereinander ausgeführt und
-- man kann sehen, wie sich der Memory Grant ändert.
-- Tatsächlichen Ausführungsplan einschließen
------------------------------------------------------------------------------
SELECT
		 TrackingNumber
FROM	 dbo.TopResellerSales c
WHERE	 c.DueDate
BETWEEN	 '20140101' AND '20150101'
ORDER BY c.TrackingNumber
	   , c.PONumber;
GO 3
