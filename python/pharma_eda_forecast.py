# ============================================================
# PHARMACEUTICAL DISTRIBUTION ANALYTICS
# Tool: Python (pandas, matplotlib, seaborn, statsmodels)
# Author: Prince Owusu Agyare
# Description: Data loading, EDA, and 6-month demand
#              forecasting using ARIMA
# ============================================================

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from statsmodels.tsa.arima.model import ARIMA
from statsmodels.tsa.stattools import adfuller
import warnings
warnings.filterwarnings("ignore")

# ── Plot style ────────────────────────────────────────────────
sns.set_theme(style="whitegrid", palette="Blues_d")
plt.rcParams["figure.figsize"] = (12, 5)


# ============================================================
# SECTION 1: LOAD & MERGE DATA
# ============================================================

drugs     = pd.read_csv("data/Drugs.csv")
customers = pd.read_csv("data/Customers.csv")
sales     = pd.read_csv("data/Sales.csv")

# Parse dates
sales["SaleDate"]             = pd.to_datetime(sales["SaleDate"])
drugs["ManufactureDate"]      = pd.to_datetime(drugs["ManufactureDate"])
drugs["ExpiryDate"]           = pd.to_datetime(drugs["ExpiryDate"])
customers["JoinDate"]         = pd.to_datetime(customers["JoinDate"])

# Merge into one analytical dataset
df = (
    sales
    .merge(drugs,     on="DrugID",     how="left")
    .merge(customers, on="CustomerID", how="left")
)

# ── Computed fields ───────────────────────────────────────────
df["Revenue"]      = df["Quantity"] * df["UnitPrice"]
df["Cost"]         = df["Quantity"] * df["CostPrice"]
df["Profit"]       = df["Revenue"] - df["Cost"]
df["ProfitMargin"] = df["Profit"] / df["Revenue"]
df["DemandRate"]   = df["Quantity"] / df["Quantity"].max()   # normalised 0-1
df["Month"]        = df["SaleDate"].dt.to_period("M")

print("Dataset shape:", df.shape)
print(df.head())


# ============================================================
# SECTION 2: EXPLORATORY DATA ANALYSIS (EDA)
# ============================================================

# ── 2.1 Drug demand by category ──────────────────────────────
cat_demand = df.groupby("Category")["Quantity"].sum().sort_values(ascending=False)

cat_demand.plot(kind="bar", color="steelblue", edgecolor="white")
plt.title("Drug Demand by Category")
plt.xlabel("Category")
plt.ylabel("Total Quantity Sold")
plt.xticks(rotation=45, ha="right")
plt.tight_layout()
plt.savefig("python/outputs/01_demand_by_category.png", dpi=150)
plt.show()


# ── 2.2 Monthly revenue trend ────────────────────────────────
monthly_rev = df.groupby("Month")["Revenue"].sum()
monthly_rev.index = monthly_rev.index.to_timestamp()

monthly_rev.plot(marker="o", color="steelblue", linewidth=2)
plt.title("Monthly Pharmaceutical Sales Revenue")
plt.xlabel("Month")
plt.ylabel("Revenue ($)")
plt.tight_layout()
plt.savefig("python/outputs/02_monthly_revenue_trend.png", dpi=150)
plt.show()


# ── 2.3 Category-wise revenue ────────────────────────────────
cat_rev = df.groupby("Category")["Revenue"].sum().sort_values(ascending=False)

cat_rev.plot(kind="bar", color="teal", edgecolor="white")
plt.title("Revenue by Drug Category")
plt.xlabel("Category")
plt.ylabel("Revenue ($)")
plt.xticks(rotation=45, ha="right")
plt.tight_layout()
plt.savefig("python/outputs/03_revenue_by_category.png", dpi=150)
plt.show()


# ── 2.4 Hospital vs pharmacy consumption ─────────────────────
cust_comp = df.groupby("CustomerType")[["Quantity", "Revenue", "Profit"]].sum()
print("\nHospital vs Pharmacy Consumption:\n", cust_comp)

cust_comp["Revenue"].plot(
    kind="pie", autopct="%1.1f%%", startangle=90,
    colors=["#2E5FA3", "#5BA4CF"]
)
plt.title("Revenue Share: Hospital vs Pharmacy")
plt.ylabel("")
plt.tight_layout()
plt.savefig("python/outputs/04_customer_type_revenue.png", dpi=150)
plt.show()


# ── 2.5 Top 10 drugs by demand ───────────────────────────────
top_drugs = (
    df.groupby("DrugName")["Quantity"]
    .sum()
    .sort_values(ascending=False)
    .head(10)
)

top_drugs.plot(kind="barh", color="steelblue", edgecolor="white")
plt.title("Top 10 Drugs by Total Demand")
plt.xlabel("Total Quantity Sold")
plt.gca().invert_yaxis()
plt.tight_layout()
plt.savefig("python/outputs/05_top10_drugs.png", dpi=150)
plt.show()


# ── 2.6 Outlier detection — demand spikes ────────────────────
monthly_qty = df.groupby("Month")["Quantity"].sum()
monthly_qty.index = monthly_qty.index.to_timestamp()

mean_qty = monthly_qty.mean()
std_qty  = monthly_qty.std()
upper    = mean_qty + 2 * std_qty
lower    = mean_qty - 2 * std_qty

outliers = monthly_qty[(monthly_qty > upper) | (monthly_qty < lower)]

plt.figure(figsize=(12, 5))
plt.plot(monthly_qty.index, monthly_qty.values, marker="o",
         color="steelblue", linewidth=2, label="Monthly Demand")
plt.axhline(upper, color="red",    linestyle="--", label="Upper bound (+2σ)")
plt.axhline(lower, color="orange", linestyle="--", label="Lower bound (-2σ)")
plt.scatter(outliers.index, outliers.values, color="red",
            zorder=5, label="Demand Spike / Outlier")
plt.title("Monthly Demand — Outlier & Spike Detection")
plt.xlabel("Month")
plt.ylabel("Quantity")
plt.legend()
plt.tight_layout()
plt.savefig("python/outputs/06_outlier_detection.png", dpi=150)
plt.show()

print(f"\nDemand spikes detected in: {list(outliers.index.strftime('%Y-%m'))}")


# ── 2.7 Profit margin distribution ───────────────────────────
df["ProfitMargin"].dropna().plot(kind="hist", bins=20,
                                  color="steelblue", edgecolor="white")
plt.title("Profit Margin Distribution")
plt.xlabel("Profit Margin")
plt.ylabel("Frequency")
plt.tight_layout()
plt.savefig("python/outputs/07_profit_margin_dist.png", dpi=150)
plt.show()


# ── 2.8 Cost variance by drug category ───────────────────────
cost_var = df.groupby("Category")[["Revenue", "Cost", "Profit"]].sum()
cost_var["CostVariance"] = cost_var["Revenue"] - cost_var["Cost"]

cost_var[["Revenue", "Cost", "Profit"]].plot(
    kind="bar", figsize=(12, 5),
    color=["steelblue", "salmon", "teal"], edgecolor="white"
)
plt.title("Revenue vs Cost vs Profit by Category")
plt.xlabel("Category")
plt.ylabel("Amount ($)")
plt.xticks(rotation=45, ha="right")
plt.tight_layout()
plt.savefig("python/outputs/08_cost_variance_by_category.png", dpi=150)
plt.show()


# ============================================================
# SECTION 3: 6-MONTH DEMAND FORECASTING — ARIMA
# ============================================================

# Prepare monthly quantity time series
monthly = df.groupby("Month")["Quantity"].sum()
monthly.index = monthly.index.to_timestamp()
monthly = monthly.asfreq("MS")   # monthly start frequency

# ── Stationarity check (ADF test) ────────────────────────────
adf_result = adfuller(monthly.dropna())
print(f"\nADF Statistic : {adf_result[0]:.4f}")
print(f"p-value       : {adf_result[1]:.4f}")
print("Series is", "stationary" if adf_result[1] < 0.05 else "non-stationary")

# ── Fit ARIMA(2,1,2) ─────────────────────────────────────────
model     = ARIMA(monthly, order=(2, 1, 2))
model_fit = model.fit()

print("\nARIMA Model Summary:")
print(model_fit.summary())

# ── Forecast next 6 months ───────────────────────────────────
forecast_steps  = 6
forecast_result = model_fit.get_forecast(steps=forecast_steps)
forecast_values = forecast_result.predicted_mean
forecast_ci     = forecast_result.conf_int()

# ── Plot historical + forecast ───────────────────────────────
plt.figure(figsize=(13, 5))
plt.plot(monthly.index, monthly.values,
         marker="o", color="steelblue", linewidth=2, label="Historical Demand")
plt.plot(forecast_values.index, forecast_values.values,
         marker="o", color="darkorange", linewidth=2, linestyle="--",
         label="6-Month Forecast")
plt.fill_between(
    forecast_ci.index,
    forecast_ci.iloc[:, 0],
    forecast_ci.iloc[:, 1],
    alpha=0.2, color="darkorange", label="95% Confidence Interval"
)
plt.axvline(monthly.index[-1], color="gray", linestyle=":", linewidth=1)
plt.title("6-Month Drug Demand Forecast (ARIMA)")
plt.xlabel("Month")
plt.ylabel("Quantity")
plt.legend()
plt.tight_layout()
plt.savefig("python/outputs/09_arima_forecast.png", dpi=150)
plt.show()

# ── Print forecast table ─────────────────────────────────────
forecast_df = pd.DataFrame({
    "Month":          forecast_values.index.strftime("%Y-%m"),
    "Forecast Qty":   forecast_values.values.round(0).astype(int),
    "Lower CI":       forecast_ci.iloc[:, 0].round(0).astype(int),
    "Upper CI":       forecast_ci.iloc[:, 1].round(0).astype(int),
})
print("\n6-Month Demand Forecast:\n")
print(forecast_df.to_string(index=False))

forecast_df.to_csv("python/outputs/forecast_results.csv", index=False)
print("\nForecast saved to python/outputs/forecast_results.csv")
