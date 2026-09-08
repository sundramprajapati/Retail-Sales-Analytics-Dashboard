CREATE DATABASE [Retail Sales Analytics];
GO;

USE [Retail Sales Analytics];
GO;

CREATE TABLE products
(
ProductID VARCHAR(10) PRIMARY KEY,
ProductName VARCHAR(50) UNIQUE NOT NULL,
Category VARCHAR(50),
UnitCost DECIMAL(10,2),
UnitPrice DECIMAL(10,2)
);

CREATE TABLE customers
(
CustomerID VARCHAR(10) PRIMARY KEY,
CustomerName VARCHAR(100) NOT NULL,
City VARCHAR(100) NOT NULL,
State VARCHAR(100) NOT NULL,
Region VARCHAR(20) NOT NULL,
Segment VARCHAR(50) NOT NULL,
SignupDate DATE
);


CREATE TABLE orders
(OrderID VARCHAR(15) PRIMARY KEY,
OrderDate DATE,
ShipDate DATE,
CustomerID VARCHAR(10) CONSTRAINT ORD_CUS_FK FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID),
ProductID VARCHAR(10) CONSTRAINT ORD_ID_FK FOREIGN KEY (ProductID) REFERENCES products(ProductID),
Quantity INT,
DiscountPercent DECIMAL(5,2) DEFAULT 0.00,
GrossSales DECIMAL(10,2),
DiscountAmount DECIMAL(10,2),
NetSales DECIMAL (10,2),
Profit DECIMAL (10,2)
);

SELECT * FROM orders
WHERE OrderID='ORD00029'
ORDER BY OrderID;

--Question No.1 (Remove Duplicate Orders)---

SELECT OrderID, COUNT(OrderID) FROM orders
GROUP BY OrderID
HAVING COUNT(OrderID) > 1;--For duplicate check

WITH DuplicateCTE AS (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY OrderID) AS rn
	FROM orders
)
DELETE FROM DuplicateCTE
WHERE rn >1;

--Question No.2 (Delete Quantity=0)----
SELECT * FROM orders WHERE Quantity=0;---Check
DELETE FROM orders WHERE Quantity=0;---DELETE

--Question No.3 (Resion wise Net sale and Profit)--------

SELECT c.region, SUM(o.netsales) "Total Net Sale", SUM(o.profit) "Total Profit"
FROM customers c INNER JOIN orders o
ON (c.CustomerID=o.CustomerID)
GROUP BY c.Region
ORDER BY c.Region;

---Question No.4 (TOP 5 Product by Revenue)-----


SELECT TOP 5 p.productname, SUM(o.netsales) AS TotalSale
FROM products p INNER JOIN orders o
ON (p.ProductID=o.ProductID)
GROUP BY p.ProductName
ORDER BY TotalSale DESC;

----Question No.5 (Month Over Month 2024 and 2025 ka Sales Trend)-----

WITH MOMSALES AS (
SELECT 
	DATENAME(MONTH,OrderDate) AS 'Months',
	DATEPART(YEAR,OrderDate) AS 'Years',
	SUM(NetSales) AS Total
FROM orders
GROUP BY DATENAME(MONTH,OrderDate),DATEPART(YEAR,OrderDate)
)
SELECT Months, [2024],[2025],
CASE MONTHS
	WHEN 'January' THEN 1
	WHEN 'February' THEN 2
	WHEN 'March'THEN 3
	WHEN 'April' THEN 4
	WHEN 'May'THEN 5
	WHEN 'June' THEN 6
	WHEN 'July' THEN 7
	WHEN 'August' THEN 8
	WHEN 'September' THEN 9
	WHEN 'October' THEN 10
	WHEN 'November' THEN 11
	WHEN 'December' THEN 12
END AS MONTHSORT
FROM 
	(SELECT Months, Years, Total FROM MOMSALES) AS SORUCETABLE

	PIVOT
		(SUM(TOTAL) FOR YEARS IN ([2024], [2025])) AS PIVOTTABLE
ORDER BY MONTHSORT ASC;


----Question No. (Segment-wise Average Order Value)-----------

SELECT
	c.Segment,
	COUNT(c.Segment) AS [Total Orders],
	SUM(o.NetSales) AS [Total Sale],
	(SUM(o.NetSales)/COUNT(c.Segment)) AS [AVG per Order]
FROM 
	customers c INNER JOIN orders o
ON (o.CustomerID=c.CustomerID)
GROUP BY c.Segment;

--Question No. 7 (Top 10 Customers by Total Spend)----

SELECT TOP 10 
	c.CustomerName AS CustomerName,
	SUM(o.NetSales) AS TotalSales
FROM 
	customers c INNER JOIN orders o
ON (c.CustomerID=o.CustomerID)
GROUP BY c.CustomerName
ORDER BY TotalSales DESC;


--Question No. 8 (Category-wise Profit Margin %)----

SELECT
	p.Category AS [Category],
	(SUM(o.Profit)/SUM(o.NetSales)) * 100 AS [Margin%]
FROM 
	products p INNER JOIN orders o
ON (p.ProductID=o.ProductID)
GROUP BY p.Category
ORDER BY [Margin%] DESC;
