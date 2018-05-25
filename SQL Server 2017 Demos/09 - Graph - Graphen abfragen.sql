/*============================================================================
	File:		09 - Graph - Graphen abfragen

	Summary:	In diesem Script sind verschiedene Abfragen enthalten die
	            die Daten in der Graphen-Datenbank abfragen. 

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
-- Tabelle People zeigen (Knoten) - Automatisch generierte $node_id
------------------------------------------------------------------------------
SELECT
	 *
FROM people;

------------------------------------------------------------------------------
-- Tabelle Parents zeigen (Kante) - Automatisch generierte $node_id
------------------------------------------------------------------------------
SELECT
	 *
FROM parents;

------------------------------------------------------------------------------
-- MATCH Abfrage die abfragt welche Kinder a.smith hat
------------------------------------------------------------------------------
SELECT 
   parent.name, 
   children.relation, 
   child.name
FROM 
  people AS parent, 
  children, 
  people AS child
WHERE MATCH (parent-(children)->child)
AND parent.personId = 0; -- personID = 0 ist a.smith

------------------------------------------------------------------------------
-- MATCH Abfrage die die Eltern von r.smith abfragt
------------------------------------------------------------------------------
SELECT 
   child.name, 
   parents.relation, 
   parent.name 
FROM 
	people AS child, 
	parents, 
	people AS parent
WHERE MATCH(child-(parents)->parent)
AND child.personId = 2; -- personId = 2 ist r.smith

------------------------------------------------------------------------------
-- MATCH Abfrage die Geschwister von r.smith ermittelt
------------------------------------------------------------------------------
SELECT 
  person1.name,
  siblings.relation,
  person2.name 
FROM 
  people AS person1, 
  siblings, 
  people AS person2
WHERE MATCH(person1-(siblings)->person2)
AND person1.personid = 2; -- personId = 2 ist r.smith

------------------------------------------------------------------------------
-- MATCH Abfrage die Geschwister von t.smith und j.smith ermittelt
------------------------------------------------------------------------------
SELECT 
   person1.name,
   siblings.relation,
   person2.name 
FROM 
   people AS person1, 
   siblings, 
   people AS person2
WHERE MATCH(person1-(siblings)->person2)
AND person1.personId IN (3,4);  -- personId = 3 ist t.smith und personId = 4 ist j.smith


------------------------------------------------------------------------------
-- MATCH Abfrage die Geschwister von t.smith ermittelt die Schwestern sind
------------------------------------------------------------------------------
SELECT    
   person1.name,
   siblings.relation,
   person2.name 
FROM 
	people AS person1, 
	siblings, 
	people AS person2
WHERE MATCH(person1-(siblings)->person2)
AND person1.personId = 3 -- personId = 3 ist t.smith
AND siblings.relation = 'sister'; -- Es wird nur nach Schwester gesucht