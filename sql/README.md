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
GROUP BY d.DrugName
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


-- Customer ordering frequency and loyalty
SELECT
    c.CustomerName,
    c.CustomerType,
    COUNT(DISTINCT s.SalesID)               AS TotalOrders,
    MIN(s.SaleDate)                         AS FirstOrder,
    MAX(s.SaleDate)                         AS LastOrder,
    DATEDIFF(MAX(s.SaleDate), MIN(s.SaleDate)) AS DaysBetweenFirstAndLast
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
GROUP BY c.CustomerName, c.CustomerType
ORDER BY TotalOrders DESC;


-- ============================================================
-- SECTION 4: INVENTORY & EXPIRY RISK QUERIES
-- ============================================================

-- Drug expiry risk report — drugs expiring within 12 months
SELECT
    DrugID,
    DrugName,
    Category,
    ShelfLifeMonths,
    ExpiryDate,
    DATEDIFF(ExpiryDate, CURDATE()) AS DaysUntilExpiry,
    CASE
        WHEN DATEDIFF(ExpiryDate, CURDATE()) < 90  THEN 'CRITICAL — Expires within 3 months'
        WHEN DATEDIFF(ExpiryDate, CURDATE()) < 180 THEN 'HIGH — Expires within 6 months'
        WHEN DATEDIFF(ExpiryDate, CURDATE()) < 365 THEN 'MODERATE — Expires within 12 months'
        ELSE 'OK'
    END AS ExpiryRisk
FROM Drugs
WHERE DATEDIFF(ExpiryDate, CURDATE()) < 365
ORDER BY DaysUntilExpiry ASC;


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

CREATE PROCEDURE MonthlyPharmaReport(IN report_month VARCHAR(7))
BEGIN
    -- Summary: revenue, quantity, profit, active customers
    SELECT
        DATE_FORMAT(s.SaleDate, '%Y-%m')            AS ReportMonth,
        SUM(s.Quantity * d.UnitPrice)               AS TotalRevenue,
        SUM(s.Quantity * d.CostPrice)               AS TotalCost,
        SUM(s.Quantity * (d.UnitPrice - d.CostPrice)) AS TotalProfit,
        ROUND(
            SUM(s.Quantity * (d.UnitPrice - d.CostPrice)) /
            NULLIF(SUM(s.Quantity * d.UnitPrice), 0) * 100, 2
        )                                           AS ProfitMarginPct,
        SUM(s.Quantity)                             AS TotalQuantitySold,
        COUNT(DISTINCT s.CustomerID)                AS ActiveCustomers,
        COUNT(DISTINCT s.DrugID)                    AS UniqueDrugsOrdered
    FROM Sales s
    JOIN Drugs d ON s.DrugID = d.DrugID
    WHERE DATE_FORMAT(s.SaleDate, '%Y-%m') = report_month;

    -- Top 5 drugs for the month
    SELECT
        d.DrugName,
        d.Category,
        SUM(s.Quantity)                             AS QuantitySold,
        SUM(s.Quantity * d.UnitPrice)               AS Revenue
    FROM Sales s
    JOIN Drugs d ON s.DrugID = d.DrugID
    WHERE DATE_FORMAT(s.SaleDate, '%Y-%m') = report_month
    GROUP BY d.DrugName, d.Category
    ORDER BY QuantitySold DESC
    LIMIT 5;

    -- Top 5 customers for the month
    SELECT
        c.CustomerName,
        c.CustomerType,
        SUM(s.Quantity * d.UnitPrice)               AS Revenue,
        SUM(s.Quantity)                             AS QuantityOrdered
    FROM Sales s
    JOIN Customers c ON s.CustomerID = c.CustomerID
    JOIN Drugs d     ON s.DrugID     = d.DrugID
    WHERE DATE_FORMAT(s.SaleDate, '%Y-%m') = report_month
    GROUP BY c.CustomerName, c.CustomerType
    ORDER BY Revenue DESC
    LIMIT 5;

END$$

DELIMITER ;

-- Usage: CALL MonthlyPharmaReport('2025-06');
