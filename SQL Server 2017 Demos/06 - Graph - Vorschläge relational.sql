/*============================================================================
	File:		06 - Graph - Vorschl�ge relational

	Summary:	Dieses Script zeigt wie eine relationale Abfrage aussieht die
	            Vorschl�ge aus einer Datenbank ermittelt.
				Stellen Sie sich vor Sie haben einen Benutzer der in Ihrem
				E-Commerce System angemeldet ist und sich das Produkt 
				'White chocolate snow balls 250g' anschaut oder der es gerade
				gekauft hat. 
				Unser Ziel ist es, �hnliche Produkte zu finden wie das Produkt das
				der Benutzer gerade anschaut und zwar basierend auf dem Verhalten
				des Benutzers. 
				In diesem Beispiel zeigen wir, wir man relational (�ber Joins)
				Produkte findet die �hnlich sind wie 'White chocolate snow balls 250g'.

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
USE [WideWorldImporters];
GO
;

------------------------------------------------------------------------------
-- Empfohlene Produkte
------------------------------------------------------------------------------

-- Aktueller Benutzer hat White chocolate snow balls 250g gekauft
WITH Current_Usr
AS (SELECT
		CustomerID = 88
	  , StockItemID = 226 -- 'White chocolate snow balls 250g'
	  , PurchasedCount = 1)
   -- Benutzer herausfinden, die dasselbe Produkt gekauft haben
   , Other_Usr
AS (SELECT
			 C.CustomerID
		   , P.StockItemID
		   , Purchased_by_others = COUNT(*)
	FROM	 Sales.OrderLines AS OD
	JOIN	 Sales.Orders AS OH
	ON OH.OrderID = OD.OrderID
	JOIN	 Sales.Customers AS C
	ON OH.CustomerID = C.CustomerID
	JOIN	 Current_Usr AS P
	ON P.StockItemID = OD.StockItemID
	WHERE	 C.CustomerID <> P.CustomerID
	GROUP BY C.CustomerID
		   , P.StockItemID)
   -- Die anderen Produkte herausfinden die diese Benutzer auch noch gekauft haben
   , Other_Items
AS (SELECT
			 C.CustomerID
		   , P.StockItemID
		   , Other_purchased = COUNT(*)
	FROM	 Sales.OrderLines AS OD
	JOIN	 Sales.Orders AS OH
	ON OH.OrderID = OD.OrderID
	JOIN	 Other_Usr AS C
	ON OH.CustomerID = C.CustomerID
	JOIN	 Warehouse.StockItems AS P
	ON P.StockItemID = OD.StockItemID
	WHERE	 P.StockItemName <> 'White chocolate snow balls 250g'
	GROUP BY C.CustomerID
		   , P.StockItemID)
-- �u�ere Abfrage
-- Dem aktuellen Benutzer die Top 10 Produkte aus den anderen Produkten empfehlen
-- die die anderen Benutzer gekauft haben. Das Ganze wird nach der Anzahl der 
-- Verk�ufe sortiert.
SELECT	 TOP 10 P.StockItemName
	   , COUNT(Other_purchased)
FROM	 Other_Items
JOIN	 Warehouse.StockItems AS P
ON P.StockItemID = Other_Items.StockItemID
GROUP BY P.StockItemName
ORDER BY COUNT(Other_purchased) DESC;
GO