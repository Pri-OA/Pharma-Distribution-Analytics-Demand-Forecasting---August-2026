# 🗄️ SQL — Pharmaceutical Distribution Analytics

**Database:** MySQL  
**Author:** Prince Owusu Agyare  

All scripts follow a single consolidated file structure organised into 5 clearly commented sections — from schema design through to stored procedures.

---

## 📋 Section Index

| # | Section | What it does |
|---|---|---|
| 1 | Table Creation | Creates `Drugs`, `Customers`, and `Sales` tables with primary and foreign key constraints |
| 2 | Revenue & Performance | Total revenue, top-selling drugs, category breakdown, monthly sales trend |
| 3 | Customer Behaviour | Top customers by revenue, hospital vs pharmacy comparison, ordering frequency and loyalty |
| 4 | Inventory & Expiry Risk | Drugs expiring within 12 months with risk classification, slow-moving stock with expiry risk |
| 5 | Stored Procedure | `MonthlyPharmaReport()` — parameterised monthly report covering revenue, profit, top drugs, and top customers |

---

## 🗂️ Database Schema

Three tables in a star schema — `Sales` as the fact table, `Drugs` and `Customers` as dimension tables.

```
Customers ──── Sales ──── Drugs
```

| Table | Primary Key | Foreign Keys |
|---|---|---|
| `Drugs` | DrugID | — |
| `Customers` | CustomerID | — |
| `Sales` | SalesID | CustomerID → Customers, DrugID → Drugs |

---

## 📊 Queries Included

### Section 2 — Revenue & Performance
- **Total Revenue** — overall sales revenue across all transactions
- **Top 10 Drugs** — ranked by quantity sold, with revenue and profit per drug
- **Revenue by Category** — demand, revenue, and profit margin % per drug category
- **Monthly Sales Trend** — month-by-month revenue, quantity, and active customer count

### Section 3 — Customer Behaviour
- **Top 10 Customers** — ranked by revenue, split by hospital / pharmacy / wholesaler type
- **Hospital vs Pharmacy Comparison** — total quantity, revenue, customer count, and average order value by customer type
- **Customer Loyalty** — order frequency, first and last order date, days between first and last order

### Section 4 — Inventory & Expiry Risk
- **Expiry Risk Report** — all drugs expiring within 12 months, classified as:
  - 🔴 `CRITICAL` — expires within 3 months
  - 🟠 `HIGH` — expires within 6 months
  - 🟡 `MODERATE` — expires within 12 months
- **Slow-Moving Expiry Risk** — drugs with fewer than 50 units sold and expiring within 6 months

### Section 5 — Stored Procedure

```sql
CALL MonthlyPharmaReport('2025-06');
```

Returns three result sets for the given month:
1. **Summary** — revenue, cost, profit, profit margin %, quantity sold, active customers, unique drugs ordered
2. **Top 5 drugs** by quantity sold
3. **Top 5 customers** by revenue

---

## ▶️ How to Run

```sql
-- Step 1: Create the database
CREATE DATABASE PharmaProject;
USE PharmaProject;

-- Step 2: Run the full script
source pharma_queries.sql

-- Step 3: Import data via MySQL Workbench Table Data Import Wizard (uploaded in the excel folder)

-- Step 4: Create store procedure to Generate a monthly report
CALL MonthlyPharmaReport('2023-07');
```

---

> 📁 Full script: [`pharma_queries.sql`](./pharma_queries.sql)  
> 📂 Back to main project: [`README`](../README.md)
