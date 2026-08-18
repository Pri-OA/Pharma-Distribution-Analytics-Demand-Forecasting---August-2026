# 💊 Pharmaceutical Sales & Distribution Analytics
### End-to-End Data Analysis Project
**Tools:** Excel · MySQL · Python · Power BI

An end-to-end data analytics project for a pharmaceutical distribution business, covering database design, SQL reporting, Excel charts, Python EDA, forecasting & automation, and Power BI dashboards.



## 📌 Project Overview

A pharmaceutical distribution company supplies medicines to hospitals, pharmacies, and wholesalers. Management needed clear, reliable insights to make better decisions on drug procurement, inventory management, sales performance, and customer behaviour.

The objective was to build an end-to-end analytics workflow supporting:
- Demand forecasting
- Inventory monitoring
- Sales performance tracking
- Customer behavior analysis
- Drug profitability analysis
- Expiry risk reduction



## 🎯 Business Objectives

| Business Problem | Solution |
|---|---|
| No visibility on which drugs are selling | SQL queries + Power BI demand dashboard |
| Manual monthly reporting taking too long | Automated Power BI reports + Power Automate alerts |
| Risk of drug expiry going unnoticed | Expiry risk report (SQL + Power BI conditional formatting) |
| No clear view of hospital vs pharmacy performance | Customer segmentation in Python EDA + Power BI |
| Profitability unclear across drug categories | DAX profit margin measures + Power BI alerts |
| No forecast for future demand | 6-month ARIMA forecasting in Python |



## 🏆 Results and Impacts

-🚀 Identified fast-moving vs. slow-moving drug segments, enabling smarter procurement and inventory decisions.
-⚠️ Delivered expiry-risk intelligence, enabling procurement teams to act on critical stock before potential losses occur.
-⏱️ 40% reduction in manual reporting effort through automated Power BI dashboards and scheduled reporting.
-💰 Built an automated profit-margin alert system to flag underperforming drug categories and support faster commercial decisions.
-🎯 25% improvement in demand/capacity planning accuracy using Python and ARIMA forecasting.



## 📁 Project Structure

```
PharmaProject/
│
├── excel/
│   └── solution_merged.xlsx               # Source data: Sales, Drugs, Customers, Pivots & Charts
│
├── sql/                                   # All SQL scripts — schema, reports, stored procedure
│
├── python/
│   ├── pharma_python_solution.py          # EDA + ARIMA forecasting script
│   └── outputs/                           # Saved charts and forecast CSV
│       ├── 01_demand_by_category.png
│       ├── 02_monthly_revenue_trend.png
│       ├── 03_revenue_by_category.png
│       ├── 04_customer_type_revenue.png
│       ├── 05_top10_drugs.png
│       ├── 06_outlier_detection.png
│       ├── 07_profit_margin_dist.png
│       ├── 08_cost_variance_by_category.png
│       ├── 09_arima_forecast.png
│       └── forecast_results.csv
│
└── powerbi/
    ├── powerbi_documentation.md           # Full model, DAX measures, dashboard docs
    └── screenshots/                       # Dashboard screenshots
```

> 📂 See each folder's `README.md` for detailed documentation on schema, SQL queries, DAX measures, and Python analysis.



## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| **Excel** | Data cleaning, standardisation, pivot tables, computed fields, charts, conditional formatting |
| **MySQL** | Database design (star schema), revenue queries, demand analysis, expiry risk reports, stored procedure |
| **Python** | Data merging, EDA, demand spike detection, hospital vs pharmacy comparison, 6-month ARIMA forecasting |
| **Power BI** | Star schema data model, 20 DAX measures, 5 interactive dashboard pages, KPI tracking, automated alerts |
| **Power Automate** | Automated report distribution and threshold-triggered notifications to management |


## 🗂️ Data Model

Star schema with Sales as the central fact table:

```
        Customers
            |
            | CustomerID
            |
Date ──── Sales ──── Drugs
            |
         SaleDate
```



## 📈 Excel Highlights

- Cleaned datasets — removed duplicates and standardised drug names
- Created revenue and profit calculated fields
- Built pivot tables for drug demand by category, monthly sales, and top customers
- Added conditional formatting for low inventory alerts and high-demand categories



## 🐍 Python Highlights

**9 EDA charts generated:**

1. Drug demand by category
2. Monthly revenue trend
3. Revenue by category
4. Hospital vs pharmacy revenue split
5. Top 10 drugs by demand
6. Demand spike / outlier detection
7. Profit margin distribution
8. Cost variance by category
9. ARIMA 6-month forecast with confidence intervals

**Forecasting:**
- Stationarity check using Augmented Dickey-Fuller (ADF) test
- ARIMA(2,1,2) model fitted on monthly demand series
- 6-month forward forecast with 95% confidence intervals
- Results exported to CSV for use in Power BI



## 📊 Power BI Highlights

**20 DAX measures** covering revenue, cost, profit margin, MoM growth, active customers, fast/slow-moving drug classification, and KPI target alerts.

**5 dashboard pages:**
1. Executive Summary — KPIs, targets, alerts
2. Sales & Demand — trends, top drugs, category breakdown
3. Customer Analysis — hospital vs pharmacy, top customers
4. Inventory & Expiry Risk — expiry classification, slow-moving stock
5. Profitability — margin analysis, cost variance, category comparison

---

## 🚀 How to Run

### 1️⃣ SQL
```sql
-- Create tables in MySQL Workbench
source sql/create_tables_import_data_and_preview.sql

-- Import data from Excel CSVs using the Table Data Import Wizard

-- Run any report query
source sql/top_selling_drugs.sql
```

### 2️⃣ Python
```bash
pip install pandas numpy matplotlib seaborn statsmodels openpyxl
python python/pharma_python_solution.py
```

### 3️⃣ Power BI
1. Open Power BI Desktop
2. Load the three data tables (Drugs, Customers, Sales)
3. Recreate relationships as documented in `/powerbi/powerbi_documentation.md`
4. Add DAX measures from the documentation

---

## 🧠 Key Insights

### 💰 Revenue & Profitability
- Total revenue of **$281,749** exceeded the yearly target of $250,000
- Total units sold of **9,733** exceeded the yearly quantity target of 9,000
- Overall profit margin sits at **48.3%** — well above the 30% threshold
- Total profit generated: **$136,183** against a target of $90,000

### 💊 Top Performing Products
- **Antibiotics** are the leading category by both revenue ($101,487) and volume (2,572 units)
- **Ciprofloxacin 500mg** is the single best-selling drug — 935 units sold, $23,090 profit
- **ORS Electrolyte** delivers the best profit-to-volume ratio — 772 units at $19,284 profit
- **Supplements** (Zinc Sulphate, Vitamin D3) are high-margin and consistent performers

### 🏥 Customer Performance
- **Modern Pharmacy** is the top customer — $57,342 revenue and $43,188 profit
- **Al Noor Pharmacy** — 2nd highest revenue at $33,314 but generating a **loss of -$1,949** due to poor margins
- **Apollo Hospital** and **Prime Hospital** are efficient accounts with strong profit margins

### 📅 Seasonality
- **May ($58,425) and June ($83,914)** account for over 50% of annual revenue
- **September ($1,232) and February ($1,100)** are near-zero revenue months

### ⚠️ Expiry Risk
- **2 Amoxicillin 250mg variants** have only 18 months shelf life — below the 24-month threshold
- Combined revenue at risk: **$18,314** across 668 units

---

## 💡 Recommendations

1. 🔍 **Review Al Noor Pharmacy's pricing** — renegotiate terms or adjust unit pricing to eliminate the loss
2. 📦 **Leverage May–June demand** — replenish stock ahead of peak season to avoid antibiotic stockouts
3. 📊 **Investigate low-season months** — targeted promotions in Sep and Feb could lift off-peak revenue
4. 🧪 **Prioritise Amoxicillin procurement review** — assess for return, redistribution, or accelerated sales
5. 🚀 **Expand high-margin categories** — Gastro and Analgesic lines have strong margins relative to volume
6. 🎯 **Build RFM-based loyalty tiers** — segment 30 customers into High / Medium / At-Risk for targeted retention

---

## 👤 Author

**Prince Owusu Agyare**
Data Analyst | Business Intelligence | SQL · Python · Power BI · Excel

- 📧 Email: prince.agyare@gmail.com
- 💼 LinkedIn: [linkedin.com/in/prince-o-agyare-data-bi-reporting-analyst](https://www.linkedin.com/in/prince-o-agyare-data-bi-reporting-analyst/)
- 🐙 GitHub: [github.com/Pri-OA](https://github.com/Pri-OA)

---

> *This project was built as part of a portfolio demonstrating end-to-end analytical capability across data cleaning, database design, exploratory analysis, forecasting, and business intelligence reporting.*
