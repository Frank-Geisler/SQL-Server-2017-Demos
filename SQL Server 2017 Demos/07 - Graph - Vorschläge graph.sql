/*============================================================================
	File:		07 - Graph - Vorschläge graph

	Summary:	Dieses Script zeigt wie eine Graph Abfrage aussieht die
	            Vorschläge aus einer Datenbank ermittelt.
				Stellen Sie sich vor Sie haben einen Benutzer der in Ihrem
				E-Commerce System angemeldet ist und sich das Produkt 
				'White chocolate snow balls 250g' anschaut oder der es gerade
				gekauft hat. 
				Unser Ziel ist es, ähnliche Produkte zu finden wie das Produkt das
				der Benutzer gerade anschaut und zwar basierend auf dem Verhalten
				des Benutzers. 
				In diesem Beispiel zeigen wir, wir man per Graph über die MATCH Klausel
				Produkte findet die ähnlich sind wie 'White chocolate snow balls 250g'.

				ACHTUNG! Abfrage ist nur ein Beispiel und läuft in WideWorldImporters nicht!

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

SELECT
  TOP 10
  RecommendedItem.StockItemName
  ,COUNT(*)
FROM
   Warehouse.StockItems AS Item
  ,Sales.Customers AS C
  ,Bought AS BoughtOther
  ,Bought AS BoughtThis
  ,Warehouse.StockItems AS RecommendedItem
WHERE
  Item.StockItemName LIKE 'White chocolate snow balls 250g'
  AND MATCH(RecommendedItem<-(BoughtOther)-C-(BoughtThis)->Item)
  AND (Item.StockItemName <> RecommendedItem.StockItemName)
  and C.customerID <> 88
GROUP BY
  RecommendedItem.StockItemName
ORDER BY COUNT(*) DESC;
GO
