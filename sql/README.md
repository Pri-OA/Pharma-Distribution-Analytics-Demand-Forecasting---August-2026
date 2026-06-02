🗄️ SQL Database Layer — Pharmaceutical Distribution Analytics
Overview
The SQL layer is the backbone of the entire project. After cleaning and structuring the data in Excel, the database was built in MySQL to store, query, and validate every business insight surfaced in Power BI. Every number in the dashboard was confirmed here first — SQL was the validation layer, not just a reporting tool.

1. 🏗️ Database Schema
Three relational tables with primary keys, foreign keys, and referential integrity enforced from the start.
TableDescriptionPrimary KeyDrugsDrug catalogue — name, category, unit price, cost price, shelf lifeDrugIDCustomersHospital and pharmacy records — name, type, city, join dateCustomerIDSalesTransaction records — links customers to drugs via foreign keysSalesID
Relationships:

Sales → Customers via CustomerID
Sales → Drugs via DrugID


2. 🔍 Queries Written
QueryPurposeKey ResultTotal RevenueGross revenue across all sales$3,845,045Total Quantity SoldUnits moved across all transactions136,870 unitsTop Selling DrugsDemand, revenue, and profit per drugCiprofloxacin 500mg leads — 4,879 units, $107,338 profitDrug Demand by CategoryRevenue and profit margin per categoryAntibiotics $1.125M · Supplements 58.5% marginMonthly Sales TrendRevenue, quantity, active customers by monthMay ($551K) and June ($366K) peak monthsHigh-Order Hospitals & PharmaciesTop 10 customers by revenue, quantity, ordersZulekha Hospital leads — $217,972, 27 ordersHospital vs Pharmacy ConsumptionRevenue, quantity, customer count, avg order value by typePharmacies $2.14M vs Hospitals $1.70MDrug Expiry RiskFlags drugs below 30-month shelf life thresholdAmoxicillin 250mg (18 months) and Insulin Regular (12 months) — 🔴 RiskyFast vs Slow Moving DrugsClassifies drugs above/below avg demand (273.74 units)Pantoprazole 40mg and Vitamin C lead fast-movingOrder Count per CustomerTotal distinct orders per customerNMC Pharmacy leads — 29 ordersAverage Quantity DemandAverage units ordered per drugSupports procurement planning thresholds

3. 🔗 Join Queries
All analytical queries use multi-table joins across Sales, Drugs, and Customers to produce business-ready results:
sql-- Example: Hospital vs Pharmacy revenue comparison
SELECT c.CustomerType,
       SUM(s.Quantity)              AS TotalQuantity,
       SUM(s.Quantity * d.UnitPrice) AS TotalRevenue,
       COUNT(DISTINCT s.CustomerID) AS CustomerCount,
       ROUND(AVG(s.Quantity * d.UnitPrice), 2) AS AvgOrderValue
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
JOIN Drugs d     ON s.DrugID = d.DrugID
GROUP BY c.CustomerType
ORDER BY TotalRevenue DESC;

4. 📊 RFM Customer Segmentation
Built a Recency-Frequency-Monetary table to segment all 60 customers for marketing and loyalty targeting:
MetricDefinitionRecencyDays since last order vs most recent sale in datasetFrequencyCount of distinct sales transactionsMonetaryTotal spend (Quantity × UnitPrice)
Top result: Zulekha Hospital — 27 orders, $217,972 spend, 2 days recency.

5. ⚙️ Stored Procedure — Pharma_Reports
A reusable stored procedure that generates a full monthly management summary on demand.
sqlCALL pharmaproject.Pharma_Reports('2023-07');
Output columns: ReportMonth · Total_Revenue · TotalCost · TotalProfit · Total_Qty_Sold · ActiveCustomers · UniqueDrugsOrdered
Sample output for 2023-07:
$326,998 revenue · $180,569 cost · $146,429 profit · 11,412 units · 27 active customers · 23 unique drugs

6. ⚠️ Expiry Risk Report
sqlSELECT DrugName, ShelfLifeMonths AS MonthsToExpiry,
  CASE WHEN ShelfLifeMonths <= 18 THEN 'risky' ELSE 'ok' END AS Status
FROM Drugs
WHERE ShelfLifeMonths < 30;
Flagged drugs requiring immediate procurement review:

🔴 Amoxicillin 250mg — 18 months
🔴 Insulin Regular — 12 months


7. ✅ Validation Against Power BI
Every key metric produced in SQL was cross-referenced against the Power BI dashboard to confirm data accuracy and model integrity. Results matched across all measures — confirming the star schema, DAX calculations, and source data are all aligned.

8. 📁 Files
FileDescriptioncreate_tables_import_data_and_preview.sqlSchema creation, data import instructions, table previewspharma_queries.sqlAll analytical queriesstore_procedure_for_reports.sqlMonthly Pharma_Reports stored procedure

Raw data is not included in this repository. Sample anonymised data is available in the /data/ folder.
