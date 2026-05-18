-- ============================================================
-- PROJECT  : Pharmaceutical Sales & Distribution Analytics
-- DATABASE : MySQL
-- AUTHOR   : Prince Owusu Agyare
-- GITHUB   : https://github.com/Pri-OA
-- LINKEDIN : https://www.linkedin.com/in/prince-o-agyare-data-bi-reporting-analyst/
-- ------------------------------------------------------------
-- DESCRIPTION:
--   End-to-end SQL pipeline for pharmaceutical distribution
--   analytics. Covers schema design, revenue reporting,
--   customer behaviour analysis, inventory & expiry risk
--   monitoring, and automated monthly reporting via stored
--   procedure.
-- ------------------------------------------------------------
-- SECTIONS:
--   1. Table Creation
--   2. Revenue & Performance Queries
--   3. Customer Behaviour Queries
--   4. Inventory & Expiry Risk Queries
--   5. Stored Procedure — Monthly Pharma Report
-- ============================================================


-- ============================================================
-- SECTION 1 | TABLE CREATION
-- ============================================================
-- Creates the star schema:
--   Drugs and Customers are dimension tables
--   Sales is the central fact table
-- ============================================================

CREATE DATABASE IF NOT EXISTS PharmaProject;
USE PharmaProject;

-- ------------------------------------------------------------
-- Drugs: product catalogue with pricing and shelf life
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- Customers: hospitals, pharmacies, and wholesalers
-- ------------------------------------------------------------
CREATE TABLE Customers (
    CustomerID      VARCHAR(10)     PRIMARY KEY,
    CustomerName    VARCHAR(100)    NOT NULL,
    CustomerType    VARCHAR(20),        -- Hospital / Pharmacy / Wholesaler
    City            VARCHAR(50),
    JoinDate        DATE
);

-- ------------------------------------------------------------
-- Sales: transaction fact table
-- References Customers and Drugs via foreign keys
-- ------------------------------------------------------------
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
-- SECTION 2 | REVENUE & PERFORMANCE QUERIES
-- ============================================================


-- ------------------------------------------------------------
-- 2.1 Total Revenue
-- Overall pharmaceutical revenue across all sales
-- ------------------------------------------------------------
SELECT
    SUM(s.Quantity * d.UnitPrice)                           AS TotalRevenue
FROM Sales s
JOIN Drugs d ON s.DrugID = d.DrugID;


-- ------------------------------------------------------------
-- 2.2 Top 10 Selling Drugs
-- Ranked by total quantity sold, with revenue and profit
-- ------------------------------------------------------------
SELECT
    d.DrugName,
    SUM(s.Quantity)                                         AS TotalDemand,
    SUM(s.Quantity * d.UnitPrice)                           AS TotalRevenue,
    SUM(s.Quantity * (d.UnitPrice - d.CostPrice))           AS TotalProfit
FROM Sales s
JOIN Drugs d ON s.DrugID = d.DrugID
GROUP BY d.DrugName
ORDER BY TotalDemand DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 2.3 Revenue & Profit Margin by Drug Category
-- Identifies highest-performing and lowest-margin categories
-- ------------------------------------------------------------
SELECT
    d.Category,
    SUM(s.Quantity)                                         AS TotalQuantity,
    SUM(s.Quantity * d.UnitPrice)                           AS TotalRevenue,
    ROUND(
        SUM(s.Quantity * (d.UnitPrice - d.CostPrice)) /
        NULLIF(SUM(s.Quantity * d.UnitPrice), 0) * 100, 2
    )                                                       AS ProfitMarginPct
FROM Sales s
JOIN Drugs d ON s.DrugID = d.DrugID
GROUP BY d.Category
ORDER BY TotalRevenue DESC;


-- ------------------------------------------------------------
-- 2.4 Monthly Sales Trend
-- Tracks revenue, quantity, and active customers over time
-- ------------------------------------------------------------
SELECT
    DATE_FORMAT(s.SaleDate, '%Y-%m')                        AS Month,
    SUM(s.Quantity * d.UnitPrice)                           AS Revenue,
    SUM(s.Quantity)                                         AS TotalQuantity,
    COUNT(DISTINCT s.CustomerID)                            AS ActiveCustomers
FROM Sales s
JOIN Drugs d ON s.DrugID = d.DrugID
GROUP BY Month
ORDER BY Month;


-- ============================================================
-- SECTION 3 | CUSTOMER BEHAVIOUR QUERIES
-- ============================================================


-- ------------------------------------------------------------
-- 3.1 Top 10 Customers by Revenue
-- Ranked with customer type and city breakdown
-- ------------------------------------------------------------
SELECT
    c.CustomerName,
    c.CustomerType,
    c.City,
    SUM(s.Quantity * d.UnitPrice)                           AS TotalRevenue,
    SUM(s.Quantity)                                         AS TotalQuantity,
    COUNT(DISTINCT s.SalesID)                               AS TotalOrders
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
JOIN Drugs d     ON s.DrugID     = d.DrugID
GROUP BY c.CustomerName, c.CustomerType, c.City
ORDER BY TotalRevenue DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 3.2 Hospital vs Pharmacy Consumption Comparison
-- Compares ordering behaviour across customer types
-- ------------------------------------------------------------
SELECT
    c.CustomerType,
    SUM(s.Quantity)                                         AS TotalQuantity,
    SUM(s.Quantity * d.UnitPrice)                           AS TotalRevenue,
    COUNT(DISTINCT s.CustomerID)                            AS CustomerCount,
    ROUND(AVG(s.Quantity * d.UnitPrice), 2)                 AS AvgOrderValue
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
JOIN Drugs d     ON s.DrugID     = d.DrugID
GROUP BY c.CustomerType
ORDER BY TotalRevenue DESC;


-- ------------------------------------------------------------
-- 3.3 Customer Ordering Frequency & Loyalty
-- Tracks order count, first/last order, and active span
-- ------------------------------------------------------------
SELECT
    c.CustomerName,
    c.CustomerType,
    COUNT(DISTINCT s.SalesID)                               AS TotalOrders,
    MIN(s.SaleDate)                                         AS FirstOrder,
    MAX(s.SaleDate)                                         AS LastOrder,
    DATEDIFF(MAX(s.SaleDate), MIN(s.SaleDate))              AS DaysBetweenFirstAndLast
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
GROUP BY c.CustomerName, c.CustomerType
ORDER BY TotalOrders DESC;


-- ============================================================
-- SECTION 4 | INVENTORY & EXPIRY RISK QUERIES
-- ============================================================


-- ------------------------------------------------------------
-- 4.1 Drug Expiry Risk Report
-- Classifies drugs expiring within 12 months by risk level
-- Risk levels:
--   CRITICAL  → expires within 3 months
--   HIGH      → expires within 6 months
--   MODERATE  → expires within 12 months
-- ------------------------------------------------------------
SELECT
    DrugID,
    DrugName,
    Category,
    ShelfLifeMonths,
    ExpiryDate,
    DATEDIFF(ExpiryDate, CURDATE())                         AS DaysUntilExpiry,
    CASE
        WHEN DATEDIFF(ExpiryDate, CURDATE()) < 90  THEN 'CRITICAL — Expires within 3 months'
        WHEN DATEDIFF(ExpiryDate, CURDATE()) < 180 THEN 'HIGH — Expires within 6 months'
        WHEN DATEDIFF(ExpiryDate, CURDATE()) < 365 THEN 'MODERATE — Expires within 12 months'
        ELSE 'OK'
    END                                                     AS ExpiryRisk
FROM Drugs
WHERE DATEDIFF(ExpiryDate, CURDATE()) < 365
ORDER BY DaysUntilExpiry ASC;


-- ------------------------------------------------------------
-- 4.2 Slow-Moving Drugs with Expiry Risk
-- Flags drugs with low sales AND approaching expiry
-- Threshold: fewer than 50 units sold, expiring within 6 months
-- ------------------------------------------------------------
SELECT
    d.DrugName,
    d.Category,
    d.ExpiryDate,
    DATEDIFF(d.ExpiryDate, CURDATE())                       AS DaysUntilExpiry,
    COALESCE(SUM(s.Quantity), 0)                            AS TotalSold
FROM Drugs d
LEFT JOIN Sales s ON d.DrugID = s.DrugID
GROUP BY d.DrugName, d.Category, d.ExpiryDate
HAVING TotalSold < 50
   AND DATEDIFF(d.ExpiryDate, CURDATE()) < 180
ORDER BY DaysUntilExpiry ASC;


-- ============================================================
-- SECTION 5 | STORED PROCEDURE — MONTHLY PHARMA REPORT
-- ============================================================
-- Generates a full monthly report for any given month
-- Returns 3 result sets:
--   1. Monthly summary (revenue, profit, margin, customers)
--   2. Top 5 drugs by quantity sold
--   3. Top 5 customers by revenue
--
-- Usage: CALL MonthlyPharmaReport('2025-06');
-- ============================================================

DELIMITER $$

CREATE PROCEDURE MonthlyPharmaReport(IN report_month VARCHAR(7))
BEGIN

    -- ----------------------------------------------------------
    -- Result Set 1: Monthly Summary
    -- ----------------------------------------------------------
    SELECT
        DATE_FORMAT(s.SaleDate, '%Y-%m')                    AS ReportMonth,
        SUM(s.Quantity * d.UnitPrice)                       AS TotalRevenue,
        SUM(s.Quantity * d.CostPrice)                       AS TotalCost,
        SUM(s.Quantity * (d.UnitPrice - d.CostPrice))       AS TotalProfit,
        ROUND(
            SUM(s.Quantity * (d.UnitPrice - d.CostPrice)) /
            NULLIF(SUM(s.Quantity * d.UnitPrice), 0) * 100, 2
        )                                                   AS ProfitMarginPct,
        SUM(s.Quantity)                                     AS TotalQuantitySold,
        COUNT(DISTINCT s.CustomerID)                        AS ActiveCustomers,
        COUNT(DISTINCT s.DrugID)                            AS UniqueDrugsOrdered
    FROM Sales s
    JOIN Drugs d ON s.DrugID = d.DrugID
    WHERE DATE_FORMAT(s.SaleDate, '%Y-%m') = report_month;

    -- ----------------------------------------------------------
    -- Result Set 2: Top 5 Drugs for the Month
    -- ----------------------------------------------------------
    SELECT
        d.DrugName,
        d.Category,
        SUM(s.Quantity)                                     AS QuantitySold,
        SUM(s.Quantity * d.UnitPrice)                       AS Revenue
    FROM Sales s
    JOIN Drugs d ON s.DrugID = d.DrugID
    WHERE DATE_FORMAT(s.SaleDate, '%Y-%m') = report_month
    GROUP BY d.DrugName, d.Category
    ORDER BY QuantitySold DESC
    LIMIT 5;

    -- ----------------------------------------------------------
    -- Result Set 3: Top 5 Customers for the Month
    -- ----------------------------------------------------------
    SELECT
        c.CustomerName,
        c.CustomerType,
        SUM(s.Quantity * d.UnitPrice)                       AS Revenue,
        SUM(s.Quantity)                                     AS QuantityOrdered
    FROM Sales s
    JOIN Customers c ON s.CustomerID = c.CustomerID
    JOIN Drugs d     ON s.DrugID     = d.DrugID
    WHERE DATE_FORMAT(s.SaleDate, '%Y-%m') = report_month
    GROUP BY c.CustomerName, c.CustomerType
    ORDER BY Revenue DESC
    LIMIT 5;

END$$

DELIMITER ;

-- ============================================================
-- END OF SCRIPT
-- ============================================================
