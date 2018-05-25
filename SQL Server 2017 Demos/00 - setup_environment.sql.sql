/*============================================================================
	File:		00 - setup_environment.sql

	Summary:	Dieses Script stellt alle Datenbanken aus dem Verzeichnis
	            C:\DB Backup wieder her. Die Datenbanken sind Demo-Datenbanken
				für SQL Server 2017 Demos

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

USE [master];

------------------------------------------------------------------------------
-- Restore AdventureWorks
------------------------------------------------------------------------------
IF (EXISTS (
			   SELECT
					 name
			   FROM	 master.dbo.sysdatabases
			   WHERE (name = 'AdventureWorks')
		   )
   )
	BEGIN
		ALTER DATABASE AdventureWorks
		SET
			SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	END;
GO

RESTORE DATABASE [AdventureWorks]
FROM DISK = N'C:\DB Backups\AdventureWorks2016CTP3.bak'
WITH
	FILE = 1
  , MOVE N'AdventureWorks2016CTP3_Data'
	TO N'F:\Data\AdventureWorks_Data.mdf'
  , MOVE N'AdventureWorks2016CTP3_Log'
	TO N'F:\Log\AdventureWorks_Log.ldf'
  , MOVE N'AdventureWorks2016CTP3_mod'
	TO N'F:\Data\AdventureWorks_mod'
  , NOUNLOAD
  , REPLACE
  , STATS = 5;
GO

ALTER DATABASE AdventureWorks
SET
	MULTI_USER;
GO

------------------------------------------------------------------------------
-- Restore AdventureWorksDW
------------------------------------------------------------------------------
IF (EXISTS (
			   SELECT
					 name
			   FROM	 master.dbo.sysdatabases
			   WHERE (name = 'AdventureWorksDW')
		   )
   )
	BEGIN
		ALTER DATABASE AdventureWorksDW
		SET
			SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	END;
GO

RESTORE DATABASE [AdventureWorksDW]
FROM DISK = N'C:\DB Backups\AdventureWorksDW2016CTP3.bak'
WITH
	FILE = 1
  , MOVE N'AdventureWorksDW2014_Data'
	TO N'F:\Data\AdventureWorksDW2016CTP3_Data.mdf'
  , MOVE N'AdventureWorksDW2014_Log'
	TO N'F:\Log\AdventureWorksDW2016CTP3_Log.ldf'
  , NOUNLOAD
  , REPLACE
  , STATS = 5;

GO

ALTER DATABASE AdventureWorksDW
SET
	MULTI_USER;
GO

------------------------------------------------------------------------------
-- Restore AdventureWorks2014
------------------------------------------------------------------------------
IF (EXISTS (
			   SELECT
					 name
			   FROM	 master.dbo.sysdatabases
			   WHERE (name = 'AdventureWorks2014')
		   )
   )
	BEGIN
		ALTER DATABASE AdventureWorks2014
		SET
			SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	END;
GO

RESTORE DATABASE [AdventureWorks2014]
FROM DISK = N'C:\DB Backups\AdventureWorks2014.bak'
WITH
	FILE = 1
  , MOVE N'AdventureWorks2014_Data'
	TO N'F:\Data\AdventureWorks2014_Data.mdf'
  , MOVE N'AdventureWorks2014_Log'
	TO N'F:\Log\AdventureWorks2014_Log.ldf'
  , NOUNLOAD
  , REPLACE
  , STATS = 5;
GO

ALTER DATABASE AdventureWorks2014
SET
	MULTI_USER;
GO

------------------------------------------------------------------------------
-- Restore AdventureWorksDW2014
------------------------------------------------------------------------------
IF (EXISTS (
			   SELECT
					 name
			   FROM	 master.dbo.sysdatabases
			   WHERE (name = 'AdventureWorksDW2014')
		   )
   )
	BEGIN
		ALTER DATABASE AdventureWorksDW2014
		SET
			SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	END;
GO

RESTORE DATABASE [AdventureWorksDW2014]
FROM DISK = N'C:\DB Backups\AdventureWorksDW2014.bak'
WITH
	FILE = 1
  , MOVE N'AdventureWorksDW2014_Data'
	TO N'F:\Data\AdventureWorksDW2014_Data.mdf'
  , MOVE N'AdventureWorksDW2014_Log'
	TO N'F:\Log\AdventureWorksDW2014_Log.ldf'
  , NOUNLOAD
  , REPLACE
  , STATS = 5;

GO

ALTER DATABASE AdventureWorksDW2014
SET
	MULTI_USER;
GO

------------------------------------------------------------------------------
-- Restore AQP Testing
------------------------------------------------------------------------------
IF (EXISTS (
			   SELECT
					 name
			   FROM	 master.dbo.sysdatabases
			   WHERE (name = 'AQP Testing')
		   )
   )
	BEGIN
		ALTER DATABASE [AQP Testing]
		SET
			SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	END;
GO

RESTORE DATABASE [AQP Testing]
FROM DISK = N'C:\DB Backups\AQP_Testing.bak'
WITH
	FILE = 1
  , NOUNLOAD
  , REPLACE
  , STATS = 5;
GO

ALTER DATABASE [AQP Testing]
SET
	MULTI_USER;
GO

------------------------------------------------------------------------------
-- Restore WideWorldImportersDW
------------------------------------------------------------------------------
IF (EXISTS (
			   SELECT
					 name
			   FROM	 master.dbo.sysdatabases
			   WHERE (name = 'WideWorldImportersDW')
		   )
   )
	BEGIN
		ALTER DATABASE [WideWorldImportersDW]
		SET
			SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	END;
GO

RESTORE DATABASE [WideWorldImportersDW]
FROM DISK = N'C:\DB Backups\WideWorldImportersDW-Full.bak'
WITH
	FILE = 1
  , MOVE N'WWI_Primary'
	TO N'F:\Data\WideWorldImportersDW.mdf'
  , MOVE N'WWI_UserData'
	TO N'F:\Data\WideWorldImportersDW_UserData.ndf'
  , MOVE N'WWI_Log'
	TO N'F:\Log\WideWorldImportersDW.ldf'
  , MOVE N'WWIDW_InMemory_Data_1'
	TO N'F:\Data\WideWorldImportersDW_InMemory_Data_1'
  , NOUNLOAD
  , REPLACE
  , STATS = 5;
GO

ALTER DATABASE [WideWorldImportersDW]
SET
	MULTI_USER;
GO

------------------------------------------------------------------------------
-- Restore WideWorldImporters
------------------------------------------------------------------------------
IF (EXISTS (
			   SELECT
					 name
			   FROM	 master.dbo.sysdatabases
			   WHERE (name = 'WideWorldImporters')
		   )
   )
	BEGIN
		ALTER DATABASE [WideWorldImporters]
		SET
			SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	END;
GO

RESTORE DATABASE [WideWorldImporters]
FROM DISK = N'C:\DB Backups\WideWorldImporters-Full.bak'
WITH
	FILE = 1
  , MOVE N'WWI_Primary'
	TO N'F:\Data\WideWorldImporters.mdf'
  , MOVE N'WWI_UserData'
	TO N'F:\Data\WideWorldImporters_UserData.ndf'
  , MOVE N'WWI_Log'
	TO N'F:\Log\WideWorldImporters.ldf'
  , MOVE N'WWI_InMemory_Data_1'
	TO N'F:\Data\WideWorldImporters_InMemory_Data_1'
  , NOUNLOAD
  , REPLACE
  , STATS = 5;
GO

ALTER DATABASE [WideWorldImporters]
SET
	MULTI_USER;
GO

------------------------------------------------------------------------------
-- Restore XboxOneParts
------------------------------------------------------------------------------
IF (EXISTS (
			   SELECT
					 name
			   FROM	 master.dbo.sysdatabases
			   WHERE (name = 'XboxOneParts')
		   )
   )
	BEGIN
		ALTER DATABASE XboxOneParts
		SET
			SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	END;
GO

RESTORE DATABASE [XboxOneParts]
FROM DISK = N'C:\DB Backups\XboxOneParts.bak'
WITH
	FILE = 1
  , MOVE N'xbox'
	TO N'F:\Data\xbox.mdf'
  , MOVE N'xbox_log'
	TO N'F:\Log\xbox_log.ldf'
  , NOUNLOAD
  , REPLACE
  , STATS = 5;
GO

ALTER DATABASE [XboxOneParts]
SET
	MULTI_USER;
GO

------------------------------------------------------------------------------
-- Restore tpcxbb_1gb
------------------------------------------------------------------------------
IF (EXISTS (
			   SELECT
					 name
			   FROM	 master.dbo.sysdatabases
			   WHERE (name = 'tpcxbb_1gb')
		   )
   )
	BEGIN
		ALTER DATABASE tpcxbb_1gb
		SET
			SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	END;
GO

RESTORE DATABASE [tpcxbb_1gb]
FROM DISK = N'C:\DB Backups\tpcxbb_1gb.bak'
WITH
	FILE = 1
  , NOUNLOAD
  , REPLACE
  , STATS = 5;

GO

ALTER DATABASE [tpcxbb_1gb]
SET
	MULTI_USER;
GO