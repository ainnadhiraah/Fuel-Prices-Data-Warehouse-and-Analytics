# 🌍 Fuel Prices Data Warehouse & Analytics

This project demonstrates how global oil price shocks propagate into local fuel prices and influence government policy responses, especially in Asian markets.

## 📌 Context

Recent geopolitical tensions involving major oil-producing regions (e.g. Iran and the Strait of Hormuz) can significantly impact global energy markets.

The Strait of Hormuz is a critical oil transit route where approximately **20% of global oil shipments** pass through daily.

When disruption risk increases:

- 🌐 Global oil supply becomes uncertain  
- ⛽ Crude oil prices rise  
- 🚗 Local fuel prices increase  
- 🏛️ Governments respond with subsidies or tax adjustments  

This project models that transmission effect using a structured data warehouse.

## 🎯 Project Scope

This project focuses on three key analytical areas:

### 1. Global Oil Price Shocks
- Brent & WTI crude oil price movements  
- Historical trends (annual & monthly)  
- Impact of geopolitical events on oil prices  

### 2. Transmission to Local Fuel Prices
- Country-level gasoline and diesel pricing  
- Relationship between crude oil and retail fuel prices  
- Price spreads and margin analysis  

### 3. Government Intervention
- Fuel tax structures across countries  
- Subsidy tracking in Asian economies  
- Policy impact on fuel affordability  

## 🏗️ Data Warehouse Architecture

The project follows a **Medallion Architecture (Bronze → Silver → Gold)**:

```
Source Data (CSV Files)
↓
Bronze Layer (Raw Data)
↓
Silver Layer (Cleaned & Standardized Data)
↓
Gold Layer (Business Insights - Future)
```

## 🥉 Bronze Layer (Raw Ingestion)

The Bronze layer stores raw data exactly as received from source files.

**Characteristics:**
- Full refresh (TRUNCATE + BULK INSERT)
- No transformation applied
- Preserves original data structure
- Serves as the source for downstream layers

**Key Tables:**
- global_fuel_prices
- crude_oil_annual
- fuel_tax_comparison
- asia_subsidy_tracker
- countries_ref

## 🥈 Silver Layer (Cleaned & Standardized)

The Silver layer transforms raw data into analytics-ready datasets.

**Key Transformations:**
- Data trimming and formatting (TRIM)
- Type casting (DECIMAL, BIT, etc.)
- Country standardization using ISO3 mapping
- Derived calculations:
  - Price spreads
  - Margins
  - Ratios
- Analytical enhancements (ranking, comparisons)

**Key Features:**
- Consistent country definitions
- Unified ISO3 integration key
- Cross-dataset join consistency

## 🔑 Data Standardization Strategy

One of the key challenges in this project is inconsistent country naming across datasets.

This is solved using:

- `silver.country_ref` → Master ISO3 reference table  
- `silver.countries_mapping` → Handles country name variations  

Examples:
- "Vietnam" → "Viet Nam"
- "UAE" → "United Arab Emirates"
- "South Korea" → "Korea, Republic of"

This ensures reliable joins across all datasets.

## ⚙️ How to Run the Pipeline

### Step 1: Load Bronze Layer
```sql
EXEC bronze.load_bronze;
```
### Step 2: Load Silver Layer
```sql
EXEC silver.load_silver;
```

## 📊 Analytical Use Cases

This data warehouse enables analysis of:
  - Global oil price shocks and volatility
  - Fuel price transmission across countries
  - Regional fuel affordability comparisons
  - Government subsidy effectiveness
  - Fuel taxation impact on consumers

## 🚧 Future Improvements
  - Gold layer (business KPI & semantic model)
  - Power BI / Tableau dashboard integration
  - Incremental ETL processing
  - Automated scheduling (SQL Agent / Python)
  - Centralized ETL logging table (instead of PRINT logs)

## 🧠 Summary

This project demonstrates a full end-to-end data warehouse pipeline that transforms raw global energy datasets into structured, analytics-ready information.

It simulates real-world energy market analysis, focusing on:
  - Oil price shocks
  - Fuel price transmission
  - Government policy responses
