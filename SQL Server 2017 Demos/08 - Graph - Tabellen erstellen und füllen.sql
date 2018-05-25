/*============================================================================
	File:		08 - Graph - Tabellen erstellen und füllen

	Summary:	Dieses Script erzeugt die Knotentabelle Person und die
	            Kantentabellen parent, childeren und siblings. Die Tabellen
				werden dann mit Daten gefüllt.

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
USE [WideWorldImporters]
GO

------------------------------------------------------------------------------
-- Knoten Tabelle People erstellen
------------------------------------------------------------------------------
DROP TABLE IF EXISTS people;

CREATE TABLE people (
	personId	INT,
	name		NVARCHAR(255),
	email		NVARCHAR(255)
) AS NODE;
GO

------------------------------------------------------------------------------
-- Datensätze in Tabelle people einfügen
-- 4-5 fiktive Personen einfügen
------------------------------------------------------------------------------
INSERT INTO people (
					   personId
					 , name
					 , email
				   )
VALUES
(
	0, 'a smith', 'a.smith@meetthesmiths.com'
)
, (
	  1, 'b smith', 'b.smith@meetthesmiths.com'
  )
, (
	  2, 'r smith', 'r.smith@meetthesmiths.com'
  )
, (
	  3, 't smith', 't.smith@meetthesmiths.com'
  )
, (
	  4, 'j smith', 'j.smith@meetthesmiths.com'
  );
GO

------------------------------------------------------------------------------
-- Kanten Tabellen erzeugen für parents, cildren und siblings
------------------------------------------------------------------------------
DROP TABLE IF EXISTS parents;

CREATE TABLE parents (
	relation	NVARCHAR(100)
) AS EDGE;
GO

DROP TABLE IF EXISTS children;

CREATE TABLE children (
	relation	NVARCHAR(100)
) AS EDGE;
GO

DROP TABLE IF EXISTS siblings;

CREATE TABLE siblings (
	relation	NVARCHAR(100)
) AS EDGE;
GO

------------------------------------------------------------------------------
-- Kanten Tabellen children, parents und siblings mit Daten füllen
------------------------------------------------------------------------------
INSERT INTO children VALUES 
	((SELECT $node_id FROM people WHERE personId = 0), (SELECT $node_id FROM people WHERE personId = 2), 'mother'),
	((SELECT $node_id FROM people WHERE personId = 0), (SELECT $node_id FROM people WHERE personId = 3), 'mother'),
	((SELECT $node_id FROM people WHERE personId = 0), (SELECT $node_id FROM people WHERE personId = 4), 'mother'),
	((SELECT $node_id FROM people WHERE personId = 1), (SELECT $node_id FROM people WHERE personId = 2), 'father'),
	((SELECT $node_id FROM people WHERE personId = 1), (SELECT $node_id FROM people WHERE personId = 3), 'father'),
	((SELECT $node_id FROM people WHERE personId = 1), (SELECT $node_id FROM people WHERE personId = 4), 'father')
;

INSERT INTO parents VALUES 
	((SELECT $node_id FROM people WHERE personId = 2), (SELECT $node_id FROM people WHERE personId = 0), 'son'),
	((SELECT $node_id FROM people WHERE personId = 3), (SELECT $node_id FROM people WHERE personId = 0), 'daughter'),
	((SELECT $node_id FROM people WHERE personId = 4), (SELECT $node_id FROM people WHERE personId = 0), 'daughter'),
	((SELECT $node_id FROM people WHERE personId = 2), (SELECT $node_id FROM people WHERE personId = 1), 'son'),
	((SELECT $node_id FROM people WHERE personId = 3), (SELECT $node_id FROM people WHERE personId = 1), 'daughter'),
	((SELECT $node_id FROM people WHERE personId = 4), (SELECT $node_id FROM people WHERE personId = 1), 'daughter')
;

-- Brüder
INSERT INTO siblings VALUES 
	((SELECT $node_id FROM people WHERE personId = 2), (SELECT $node_id FROM people WHERE personId = 3), 'brother'),
	((SELECT $node_id FROM people WHERE personId = 2), (SELECT $node_id FROM people WHERE personId = 4), 'brother')
;

-- Schwestern
INSERT INTO siblings VALUES 
	((SELECT $node_id FROM people WHERE personId = 3), (SELECT $node_id FROM people WHERE personId = 2), 'sister'),
	((SELECT $node_id FROM people WHERE personId = 3), (SELECT $node_id FROM people WHERE personId = 4), 'sister'),
	((SELECT $node_id FROM people WHERE personId = 4), (SELECT $node_id FROM people WHERE personId = 2), 'sister'),
	((SELECT $node_id FROM people WHERE personId = 4), (SELECT $node_id FROM people WHERE personId = 3), 'sister')
;
