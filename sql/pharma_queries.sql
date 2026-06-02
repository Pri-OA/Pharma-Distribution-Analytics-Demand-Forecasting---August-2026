-- ============================================================
-- PHARMACEUTICAL DISTRIBUTION ANALYTICS
-- Database: MySQL
-- Author: Prince Owusu Agyare
-- Description: Schema design, queries, and stored procedures
--              for pharmaceutical sales and inventory analysis
-- ============================================================


-- ============================================================
-- SECTION 1: TABLE CREATION
-- ============================================================
Create Database Pharma;
CREATE TABLE Drugs (
    DrugID          VARCHAR(10)     PRIMARY KEY,
    DrugName        VARCHAR(100)    NOT NULL,
    Category        VARCHAR(50),
    UnitPrice       DECIMAL(10,2),
    CostPrice       DECIMAL(10,2),
    ShelfLifeMonths INT,
    ManufactureDate DATE,
    ExpiryDate      DATE
);

CREATE TABLE Customers (
    CustomerID      VARCHAR(10)     PRIMARY KEY,
    CustomerName    VARCHAR(100)    NOT NULL,
    CustomerType    VARCHAR(20),        -- Hospital / Pharmacy / Wholesaler
    City            VARCHAR(50),
    JoinDate        DATE
);

CREATE TABLE Sales (
    SalesID         VARCHAR(10)     PRIMARY KEY,
    CustomerID      VARCHAR(10),
    DrugID          VARCHAR(10),
    Quantity        INT,
    SaleDate        DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (DrugID)     REFERENCES Drugs(DrugID)
);


-- ============================================================
-- SECTION 2: REVENUE & PERFORMANCE QUERIES
-- ============================================================

-- Total pharmaceutical revenue across all sales
SELECT
    SUM(s.Quantity * d.UnitPrice) AS TotalRevenue
FROM Sales s
JOIN Drugs d ON s.DrugID = d.DrugID;


-- Top-selling drugs by total quantity demanded
SELECT
    d.DrugName,
    SUM(s.Quantity)                         AS TotalDemand,
    SUM(s.Quantity * d.UnitPrice)           AS TotalRevenue,
    SUM(s.Quantity * (d.UnitPrice - d.CostPrice)) AS TotalProfit
FROM Sales s
JOIN Drugs d ON s.DrugID = d.DrugID
GROUP BY d.Category
ORDER BY TotalDemand DESC
LIMIT 10;


-- Drug demand and revenue by category
SELECT
    d.Category,
    SUM(s.Quantity)                         AS TotalQuantity,
    SUM(s.Quantity * d.UnitPrice)           AS TotalRevenue,
    ROUND(
        SUM(s.Quantity * (d.UnitPrice - d.CostPrice)) /
        NULLIF(SUM(s.Quantity * d.UnitPrice), 0) * 100, 2
    )                                       AS ProfitMarginPct
FROM Sales s
JOIN Drugs d ON s.DrugID = d.DrugID
GROUP BY d.Category
ORDER BY TotalRevenue DESC;


-- Monthly sales trend (revenue over time)
SELECT
    DATE_FORMAT(s.SaleDate, '%Y-%m')        AS Month,
    SUM(s.Quantity * d.UnitPrice)           AS Revenue,
    SUM(s.Quantity)                         AS TotalQuantity,
    COUNT(DISTINCT s.CustomerID)            AS ActiveCustomers
FROM Sales s
JOIN Drugs d ON s.DrugID = d.DrugID
GROUP BY Month
ORDER BY Month;


-- ============================================================
-- SECTION 3: CUSTOMER BEHAVIOUR QUERIES
-- ============================================================

-- Top customers by revenue (hospitals vs pharmacies)
SELECT
    c.CustomerName,
    c.CustomerType,
    c.City,
    SUM(s.Quantity * d.UnitPrice)           AS TotalRevenue,
    SUM(s.Quantity)                         AS TotalQuantity,
    COUNT(DISTINCT s.SalesID)               AS TotalOrders
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
JOIN Drugs d     ON s.DrugID     = d.DrugID
GROUP BY c.CustomerName, c.CustomerType, c.City
ORDER BY TotalRevenue DESC
LIMIT 10;


-- Hospital vs pharmacy consumption comparison
SELECT
    c.CustomerType,
    SUM(s.Quantity)                         AS TotalQuantity,
    SUM(s.Quantity * d.UnitPrice)           AS TotalRevenue,
    COUNT(DISTINCT s.CustomerID)            AS CustomerCount,
    ROUND(AVG(s.Quantity * d.UnitPrice), 2) AS AvgOrderValue
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
JOIN Drugs d     ON s.DrugID     = d.DrugID
GROUP BY c.CustomerType
ORDER BY TotalRevenue DESC;


-- Customer ordering recency, frequency, monetary and loyalty
SELECT
    c.CustomerName,
    c.CustomerType,
    COUNT(DISTINCT s.SalesID)               AS TotalOrders,
    MIN(s.SaleDate)                         AS FirstOrder,
    MAX(s.SaleDate)                         AS LastOrder,
    DATEDIFF((SELECT MAX(SalesDate) FROM Sales), MAX(s.SalesDate)) AS RecencyDays,
   
    sum(s.Quantity * d.UnitPrice) 	as TotalSpend 
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
JOIN Drugs d     ON s.DrugID     = d.DrugID

GROUP BY CustomerName, CustomerType
ORDER BY TotalOrders DESC;


-- ============================================================
-- SECTION 4: INVENTORY & EXPIRY RISK QUERIES
-- ============================================================

-- Drug expiry risk report — drugs expiring within 30 months from sales date
SELECT
	DrugName, 
    ShelfLifeMonths as MonthstoExpiry,
CASE 
WHEN ShelfLifeMonths <= 18 THEN 'risky' ELSE 'ok'
END 		AS STATUS
FROM drugs
WHERE ShelfLifeMonths < 30;


-- Slow-moving drugs with expiry risk (high risk, low sales)
SELECT
    d.DrugName,
    d.Category,
    d.ExpiryDate,
    DATEDIFF(d.ExpiryDate, CURDATE())       AS DaysUntilExpiry,
    COALESCE(SUM(s.Quantity), 0)            AS TotalSold
FROM Drugs d
LEFT JOIN Sales s ON d.DrugID = s.DrugID
GROUP BY d.DrugName, d.Category, d.ExpiryDate
HAVING TotalSold < 50
   AND DATEDIFF(d.ExpiryDate, CURDATE()) < 180
ORDER BY DaysUntilExpiry ASC;


-- ============================================================
-- SECTION 5: STORED PROCEDURE — MONTHLY PHARMA REPORT
-- ============================================================

DELIMITER $$
CREATE PROCEDURE Pharma_Reports(
    IN report_month VARCHAR(7)
)
BEGIN
    SELECT
        DATE_FORMAT(s.SalesDate, '%Y-%m') AS ReportMonth,
        SUM(s.Quantity * d.UnitPrice) AS Total_Revenue,
        SUM(s.Quantity * d.CostPrice) AS TotalCost,
        SUM(s.Quantity * (d.UnitPrice - d.CostPrice)) AS TotalProfit,
        SUM(s.Quantity) AS Total_Qty_Sold,
        COUNT(DISTINCT s.CustomerID) AS ActiveCustomers,
        COUNT(DISTINCT s.DrugID) AS UniqueDrugsOrdered
    FROM Sales s
    JOIN Drugs d
        ON s.DrugID = d.DrugID
    WHERE DATE_FORMAT(s.SalesDate, '%Y-%m') = report_month -- put the report year and month here
    GROUP BY DATE_FORMAT(s.SalesDate, '%Y-%m');
END $$
DELIMITER ;

-- Usage: CALL MonthlyPharmaReport('2023-07');
CALL Pharma_Reports('2023-07');
