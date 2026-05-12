/*
===============================================================================
DDL Script: Create Gold Fact Views
===============================================================================

Script Purpose:

    This script creates fact views in the Gold layer of the
    data warehouse.

    The Gold layer represents the final analytical layer designed
    using dimensional modeling principles (Star Schema).

    Each fact view integrates, transforms and enriches standardized
    data from the Silver layer to produce business-ready datasets
    optimized for reporting, dashboarding and analytical workloads.

    These fact views store measurable business metrics and are designed
    to be joined with dimension tables for multidimensional analysis.

Usage:
    - Creates analytical fact views in the Gold layer
    - Supports reporting and BI dashboard consumption
    - Provides centralized and standardized business metrics
    - Intended for direct querying by analytics tools

Notes:
    - Source data originates from the Silver layer
    - Fact views are designed to work with Gold dimension tables
    - Country-related data is standardized using ISO3 mappings
    - Some fact views use date_key from dim_date for temporal analysis
    - Some fact views may use distinct year values directly depending
      on the source data grain and business requirements
    - Optimized for aggregations, trend analysis and KPI reporting

===============================================================================
*/

IF OBJECT_ID('gold.fact_asia_fuel_prices_tax_snapshot', 'V') IS NOT NULL
    DROP VIEW gold.fact_asia_fuel_prices_tax_snapshot;
GO

CREATE VIEW gold.fact_asia_fuel_prices_tax_snapshot AS
SELECT
	a.iso3,
    a.country,
    a.gasoline_usd_per_liter,
    a.diesel_usd_per_liter,
    ROUND((a.gasoline_usd_per_liter + a.diesel_usd_per_liter) * 0.5, 2) AS avg_fuel_usd,
    a.avg_monthly_income_usd,
    a.fuel_affordability_index,
    a.gasoline_pct_daily_wage,
    a.oil_import_dependency_pct,
    a.refinery_capacity_kbpd,
    a.ev_adoption_pct,
    a.fuel_subsidy_active,
    a.subsidy_cost_bn_usd,

    t.gasoline_tax_pct,
    t.diesel_tax_pct,
    t.vat_pct,
    t.excise_usd_per_liter,
    t.carbon_tax_active,
    t.total_tax_usd_per_liter,
    t.tax_burden_category
FROM silver.asia_fuel_prices_detailed a
LEFT JOIN silver.fuel_tax_comparison t
    ON t.iso3 = a.iso3
LEFT JOIN gold.dim_country d
    ON a.iso3 = d.iso3;
GO

IF OBJECT_ID('gold.fact_global_snapshot','V') IS NOT NULL
	DROP VIEW gold.fact_global_snapshot;
GO

CREATE VIEW gold.fact_global_snapshot AS
SELECT 
	g.country,
	g.region,
	g.iso3,
	g.gasoline_usd_per_liter,
	g.diesel_usd_per_liter,
	g.local_currency,
	g.gasoline_local_price,
	g.diesel_local_price,
	g.is_asian,
	g.avg_fuel_usd,
	g.price_spread_usd,
	g.price_spread_local
FROM silver.global_fuel_prices g
LEFT JOIN gold.dim_country d
	ON g.iso3 = d.iso3
GO

IF OBJECT_ID('gold.fact_subsidy_snapshot','V') IS NOT NULL
	DROP VIEW gold.fact_subsidy_snapshot;
GO

CREATE VIEW gold.fact_subsidy_snapshot AS
SELECT 
	g.country,
	g.iso3,
	g.gasoline_subsidized,
	g.diesel_subsidized,
	g.subsidy_type,
	g.annual_subsidy_cost_bn_usd,
	g.subsidy_pct_gdp,
	g.subsidy_description,
	g.pricing_mechanism,
	g.regulator
FROM silver.asia_subsidy_tracker g
LEFT JOIN gold.dim_country d
	ON g.iso3 = d.iso3;
GO

IF OBJECT_ID('gold.fact_tax_snapshot','V') IS NOT NULL
	DROP VIEW gold.fact_tax_snapshot;
GO

CREATE VIEW gold.fact_tax_snapshot AS
SELECT 
	g.country,
	g.iso3,
	g.region,
	g.gasoline_tax_pct,
	g.diesel_tax_pct,
	g.vat_pct,
	g.excise_usd_per_liter,
	g.carbon_tax_active,
	g.total_tax_usd_per_liter,
	g.tax_burden_category
FROM silver.fuel_tax_comparison g
LEFT JOIN gold.dim_country d
	ON g.iso3 = d.iso3;
GO

IF OBJECT_ID('gold.fact_price_trend_monthly', 'V') IS NOT NULL
    DROP VIEW gold.fact_price_trend_monthly;
GO

CREATE VIEW gold.fact_price_trend_monthly AS
SELECT DISTINCT
	(f."year" * 10000 + f."month" * 100 + 1) AS date_key,
	f.iso3,
	f.country,
	f.gasoline_usd_per_liter,
	f.brent_crude_usd_bbl,
	f.gasoline_mom_change_pct,
	f.gasoline_yoy_change_pct,
	f.brent_crude_usd_per_liter,
	f.gasoline_to_brent_abs_margin,
	f.gasoline_to_brent_rel_margin,
	f.gasoline_to_brent_ratio
FROM silver.price_trend_monthly f
LEFT JOIN gold.dim_date d
	ON (f."year" * 10000 + f."month" * 100 + 1) = d.date_key
LEFT JOIN gold.dim_country c
	ON f.iso3 = c.iso3
WHERE f.region LIKE LOWER(TRIM('%asia%'));
GO

IF OBJECT_ID('gold.fact_event_annual', 'V') IS NOT NULL
    DROP VIEW gold.fact_event_annual;
GO

CREATE VIEW gold.fact_event_annual AS
SELECT 
	s.year,
	s.key_event,
	s.brent_avg_usd_bbl,
	s.wti_avg_usd_bbl,
	s.wti_yoy_change_pct,
	s.brent_wti_spread,
	s.avg_price_usd_bbl
FROM silver.crude_oil_annual s
LEFT JOIN (
	SELECT DISTINCT year 
	FROM gold.dim_date ) d
	ON s.year = d.year;
GO



