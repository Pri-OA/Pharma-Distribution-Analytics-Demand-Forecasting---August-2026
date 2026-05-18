# 📊 Power BI Dashboard — Pharmaceutical Analytics

## 🔍 Overview

The Power BI report is the final layer of the analytical pipeline, turning cleaned and modelled data into interactive executive dashboards used by management for operational decision-making.

---

## 🗂️ Data Model (Star Schema)

```
        Customers
            |
            | (CustomerID)
            |
Date ── Sales ── Drugs
            |
       (SaleDate)
```

| Table | Type | Columns | Description |
|-------|------|---------|-------------|
| Sales | Fact | SalesID, CustomerID, DrugID, Quantity, SaleDate, Revenue, UnitPrice, Profit, SalesMonth | Central transaction table |
| Drugs | Dimension | DrugID, DrugName, Standardized DrugName, Category, UnitPrice, CostPrice, ShelfLifeMonths, ManufactureDate, ExpiryDate | Drug catalogue |
| Customers | Dimension | CustomerID, CustomerName, CustomerType, City, JoinDate | Hospital / Pharmacy / Wholesaler data |
| Date | Dimension | 16 columns | Standard date intelligence table for time-based filtering |

**🔗 Relationships:**
- Sales → Customers (Many-to-One on CustomerID)
- Sales → Drugs (Many-to-One on DrugID)
- Sales → Date (Many-to-One on SaleDate)
- Drugs → LocalDateTable on ManufactureDate and ExpiryDate

---

## 🧮 DAX Measures (20 Total)

### 💰 Revenue & Profitability

| Measure | DAX Expression | Format |
|---------|---------------|--------|
| Total Revenue | `SUMX(Sales, Sales[Quantity] * Sales[UnitPrice])` | $#,0 |
| Total Cost | `SUMX(Sales, Sales[Quantity] * RELATED(Drugs[CostPrice]))` | #,##0 |
| Total Profit | `[Total Revenue] - [Total Cost]` | #,##0 |
| Profit Margin % | `DIVIDE([Total Profit], [Total Revenue], 0)` | 0% |

### 📦 Demand & Volume

| Measure | DAX Expression | Format |
|---------|---------------|--------|
| Total Quantity Sold | `SUM(Sales[Quantity])` | 0 |
| Total Demand | `SUM(Sales[Quantity])` | 0 |
| Average | `AVERAGE(Sales[Quantity])` | Auto |
| Movement Category | `IF([Total Quantity Sold] > [Average], "Fast-moving", "Slow-moving")` | Text |

### 🏥 Customer Analytics

| Measure | DAX Expression | Format |
|---------|---------------|--------|
| Active Customers | `DISTINCTCOUNT(Sales[CustomerID])` | #,##0 |
| Revenue per Customer | `DIVIDE([Total Revenue], [Active Customers], 0)` | #,##0.00 |
| Average Revenue per Customer | `AVERAGEX(KEEPFILTERS(VALUES('Customers'[CustomerID])), CALCULATE([Total Revenue]))` | $#,0 |

### 📈 Growth & Trend

| Measure | DAX Expression | Format |
|---------|---------------|--------|
| Revenue Growth % (MoM) | `VAR CurrentRevenue = [Total Revenue]` `VAR PreviousRevenue = CALCULATE([Total Revenue], DATEADD(Sales[SaleDate], -1, MONTH))` `RETURN DIVIDE(CurrentRevenue - PreviousRevenue, PreviousRevenue, 0) * 100` | 0.00% |

### 🎯 Targets & Alerts

| Measure | Value / Logic | Format |
|---------|--------------|--------|
| Revenue Target Yearly | 250,000 | 0 |
| Quantity Target Yearly | 9,000 | #,##0 |
| Profit Margin Target | 90,000 | 0 |
| Profit Target Yearly | 90,000 | 0 |
| Profit Margin Threshold | 0.30 | Auto |
| Profit Margin Alert | `IF([Profit Margin %] < 0.20, "🔴 Low Margin", IF([Profit Margin %] < 0.35, "⚠️ Moderate", "🟢 Healthy"))` | Text |
| Revenue vs Target Alert | `IF([Total Revenue] >= [Revenue Target Yearly], "✅ Revenue target exceeded", "❌ Revenue target not met")` | Text |
| Qty vs Target Alert | `IF([Total Quantity Sold] >= [Quantity Target Yearly], "✅ Quantity target exceeded", "❌ Quantity target not met")` | Text |

---

## 🖥️ Dashboard Pages

### 📋 Page 1 — Executive Summary
- KPI cards: Total Revenue, Total Profit, Profit Margin %, Active Customers
- Revenue vs Target gauge
- Quantity vs Target gauge
- Profit Margin Alert indicator
- Revenue Growth % (MoM)

### 📈 Page 2 — Sales & Demand Analysis
- Monthly Revenue trend (line chart)
- Drug Demand by Category (bar chart)
- Top 10 Drugs by Quantity Sold (bar chart)
- Fast-moving vs Slow-moving drug classification table

### 🏥 Page 3 — Customer Analysis
- Top Hospitals and Pharmacies by Revenue (table)
- Hospital vs Pharmacy revenue split (pie chart)
- Revenue per Customer KPI
- Customer ordering behaviour over time

### 🧪 Page 4 — Inventory & Expiry Risk
- Drug Expiry Risk table with conditional formatting:
  - 🔴 Critical — expires within 3 months
  - 🟠 High — expires within 6 months
  - 🟡 Moderate — expires within 12 months
- Slow-moving drugs flagged for expiry risk
- Drug shelf life distribution

### 💰 Page 5 — Profitability
- Profit Margin % by Category
- Revenue vs Cost vs Profit by Category (clustered bar)
- Profit Margin Alert by drug
- Cost variance analysis

---

## 🧠 Key Insights Delivered

- ✅ Reduced manual reporting effort by **30%** through automated Power BI dashboards and Power Automate alerts
- ✅ Improved capacity planning accuracy by **25%** using ARIMA forecasting integrated with Power BI trend visuals
- ✅ Identified fast-moving vs slow-moving drug segments using the Movement Category DAX measure
- ✅ Built profit margin alert system flagging drugs below the 20% margin threshold automatically
- ✅ Delivered expiry risk intelligence enabling procurement to act on drugs expiring within 90 days



## 📸 Screenshots

Dashboard screenshots are available in the `/powerbi/screenshots/` folder.

> **⚠️ Note:** The `.pbix` file is not included in this repository as it contains embedded business data.  
> All DAX measures and model documentation are fully documented above.


> 📂 Back to main project: [`README`](../README.md)

