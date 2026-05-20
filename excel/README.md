📊 Excel Data Preparation — Pharmaceutical Analytics
Overview
Excel was the starting point of the entire pipeline. Raw data was cleaned, standardised, and enriched here before being passed to MySQL and Python for deeper analysis. No clean data in, no reliable insights out — this step sets the foundation for everything else.

1. 🧹 Data Cleaning Steps
StepActionFormula / MethodRemove duplicatesEliminated duplicate rows across all three datasetsData → Remove DuplicatesFix text casingStandardised drug and customer names to proper case=PROPER(A2)Fix date formatsConverted all dates to consistent DD/MM/YYYY formatFormat Cells → DateHandle missing valuesIdentified and filled or flagged blanks in key columns=IF(ISBLANK(A2), "Unknown", A2)Trim whitespaceRemoved leading/trailing spaces from all text fields=TRIM(A2)

2. ➕ Computed Fields Added
ColumnFormulaDescriptionRevenue=Quantity * UnitPriceGross revenue per saleProfit=Revenue - (Quantity * CostPrice)Gross profit per saleProfit Margin %=Profit / RevenueFormatted as percentageMonth=TEXT(SaleDate, "YYYY-MM")Used for monthly aggregations

3. 📋 Pivot Tables
Pivot 1 — Drug Demand by Category

Rows: Category
Values: SUM of Quantity
Purpose: Identify highest-demand drug categories

Pivot 2 — Monthly Drug Sales

Rows: Month (grouped by SaleDate)
Values: SUM of Revenue
Purpose: Track revenue trends over time

Pivot 3 — Top Customers

Rows: CustomerName, CustomerType
Values: SUM of Revenue, SUM of Quantity
Purpose: Identify highest-value hospitals and pharmacies


4. 📈 Charts Created
Chart TypeData UsedPurposeLine chartMonthly RevenueVisualise revenue trend over timeBar chartCategory-wise SalesCompare demand across drug categoriesPie chartCustomer Type DistributionHospital vs Pharmacy revenue shareColumn chartTop 10 DrugsHighest-selling individual drugs

5. 🎨 Conditional Formatting Rules
Applied ToRuleFormatInventory levelsCell value < threshold🔴 Red fill — low stock alertProfit Margin %Value < 20%🔴 Red — low margin warningProfit Margin %20% – 35%🟡 Amber — moderate marginProfit Margin %Value > 35%🟢 Green — healthy marginHigh-demand categoriesTop 25% by quantity🔵 Blue highlightExpiry datesWithin 6 months🔴 Red fill — expiry risk

6. 📁 Files

The raw Excel workbooks are not included in this repository to protect data privacy.
Sample anonymised data is available in the /data/ folder.
