# 🐍 Python — Pharmaceutical Distribution Analytics

**Language:** Python 3  
**Author:** Prince Owusu Agyare  
**Libraries:** pandas · numpy · matplotlib · seaborn · statsmodels  

End-to-end Python analysis for the PharmaProject — covering data loading, merging, exploratory data analysis (EDA), and 6-month ARIMA demand forecasting.

---

## ✅ Tasks Completed

| Task | Status |
|---|---|
| Load datasets using pandas | ✔ |
| Merge Sales + Drugs + Customers | ✔ |
| Calculate Revenue, Profit, Cost Variance, Drug Demand Rate | ✔ |
| EDA — Demand trend by drug | ✔ |
| EDA — Category-wise revenue | ✔ |
| EDA — Outlier detection (demand spikes) | ✔ |
| EDA — Hospital vs Pharmacy consumption comparison | ✔ |
| Forecast next 6 months demand using ARIMA | ✔ |
| Visualisations — Monthly demand forecast | ✔ |
| Visualisations — Category-wise sales chart | ✔ |
| Visualisations — Top customers bar chart | ✔ |
| Visualisations — Inventory depletion prediction | ✔ |
| Export forecast results to CSV | ✔ |

---

## 📋 Script Structure

All analysis is contained in a single script — `pharma_python_solution.py` — organised into 5 clearly commented sections.

| # | Section | What it does |
|---|---|---|
| 1 | Imports & Setup | Loads libraries, sets chart style, creates output folder |
| 2 | Load & Merge Data | Reads Excel sheets, merges all three tables, calculates derived fields |
| 3 | EDA — Charts 1 to 8 | Generates 8 exploratory analysis charts |
| 4 | ARIMA Forecasting | ADF stationarity test, fits ARIMA(2,1,2), 6-month forecast with 95% CI |
| 5 | Export Results | Saves forecast to `outputs/forecast_results.csv` |

---

## 📊 EDA Visualisations

| Chart | File | Description |
|---|---|---|
| 1 | `01_demand_by_category.png` | Total quantity sold per drug category |
| 2 | `02_monthly_revenue_trend.png` | Month-by-month revenue trend with labels |
| 3 | `03_revenue_by_category.png` | Revenue vs profit side-by-side per category |
| 4 | `04_customer_type_revenue.png` | Hospital vs pharmacy revenue split (pie chart) |
| 5 | `05_top10_drugs.png` | Top 10 drugs ranked by total quantity sold |
| 6 | `06_outlier_detection.png` | Monthly demand with mean ± 1 SD spike detection |
| 7 | `07_profit_margin_dist.png` | Profit margin % distribution across all drug lines |
| 8 | `08_cost_variance_by_category.png` | Avg unit price vs avg cost price per category |
| 9 | `09_arima_forecast.png` | ARIMA 6-month demand forecast with confidence intervals |

---

## 🔢 Calculated Fields

```python
df["Revenue"]   = df["Quantity"] * df["UnitPrice"]
df["Profit"]    = df["Quantity"] * (df["UnitPrice"] - df["CostPrice"])
df["YearMonth"] = df["SaleDate"].dt.to_period("M")
df["Month"]     = df["SaleDate"].dt.strftime("%b")
```

---

## 📈 Load & Merge Logic

```python
import pandas as pd

sales     = pd.read_excel("excel/solution_merged.xlsx", sheet_name="Sales")
drugs     = pd.read_excel("excel/solution_merged.xlsx", sheet_name="Drugs")
customers = pd.read_excel("excel/solution_merged.xlsx", sheet_name="Customers")

df = (
    sales
    .merge(drugs,     on="DrugID",     how="left")
    .merge(customers, on="CustomerID", how="left")
)
```



## 🔮 ARIMA Forecasting

```python
from statsmodels.tsa.stattools import adfuller
from statsmodels.tsa.arima.model import ARIMA

# Monthly demand time series
monthly = df.groupby("YearMonth")["Quantity"].sum()
monthly.index = monthly.index.to_timestamp()

# Stationarity check
adf_result = adfuller(monthly)

# Fit ARIMA(2,1,2) — d=1 applies first-order differencing
model  = ARIMA(monthly, order=(2, 1, 2))
result = model.fit()

# 6-month forecast with 95% confidence intervals
forecast    = result.get_forecast(steps=6)
forecast_df = forecast.predicted_mean
forecast_ci = forecast.conf_int(alpha=0.05)
```

**Model:** ARIMA(2,1,2)  
**Horizon:** 6 months  
**Confidence interval:** 95%  
**Stationarity test:** Augmented Dickey-Fuller (ADF)

---

## ▶️ How to Run

### Install dependencies
```bash
pip install pandas numpy matplotlib seaborn statsmodels openpyxl
```

### Run the script
```bash
python python/pharma_python_solution.py
```

### Expected output
```
Dataset loaded: 200 sales records
Date range    : 2025-01-01 → 2025-12-31
Customers     : 30
Drugs         : 35
Total Revenue : $281,749
Total Profit  : $136,183

ADF Statistic : -3.4521
p-value       : 0.0094
Stationary    : Yes

6-Month Demand Forecast:
   Month  Forecast Qty  Lower 95% CI  Upper 95% CI
 2026-01           712           580           844
 ...

✔ Chart 1 saved — Drug Demand by Category
✔ Chart 2 saved — Monthly Revenue Trend
...
✔ Chart 9 saved — ARIMA Forecast
✔ Forecast CSV saved — outputs/forecast_results.csv

✅ All outputs saved to the outputs/ folder.
```


## 📁 Output Files

All outputs are saved to the `outputs/` folder:

```
outputs/
├── 01_demand_by_category.png
├── 02_monthly_revenue_trend.png
├── 03_revenue_by_category.png
├── 04_customer_type_revenue.png
├── 05_top10_drugs.png
├── 06_outlier_detection.png
├── 07_profit_margin_dist.png
├── 08_cost_variance_by_category.png
├── 09_arima_forecast.png
└── forecast_results.csv
```

---

> 📁 Full script: [`pharma_python_solution.py`](./pharma_python_solution.py)  
> 📂 Back to main project: [`README`](../README.md)

