/*
===============================================================================
Table: silver.country_mapping
===============================================================================

Script Purpose:
    This mapping table standardizes country names across different datasets
    in the Silver layer and links them to a unified country reference.

Description:
    - source_country     : Original country name as it appears in source data
    - standard_country   : Cleaned / standardized country name used in analytics based on reference dataset
    - iso3               : Standard 3-letter ISO country code (FK to country_ref)

Role in Data Warehouse:
    This table acts as a conformance mapping layer to ensure consistency
    when joining datasets that contain inconsistent or variant country naming
    conventions (e.g., "Vietnam" vs "Viet Nam").

Relationships:
    - Foreign Key: iso3 references silver.country_ref("alpha-3")
    - Ensures all mapped countries exist in the master country reference table

Usage:
    - Used during Silver layer transformations to standardize country fields
    - Enables reliable joins across fact tables and dimension tables
    - Supports reporting consistency across global datasets

Notes:
    - This is a manually maintained mapping table
    - Should be updated when new country name variations are identified
    - ISO3 acts as the primary integration key across datasets

===============================================================================
*/

CREATE TABLE silver.country_mapping (
    source_country      NVARCHAR(255) PRIMARY KEY,
    standard_country    NVARCHAR(255),
    iso3                CHAR(3) NOT NULL,

    CONSTRAINT fk_countries_mapping_iso3
        FOREIGN KEY (iso3)
        REFERENCES silver.country_ref("alpha-3")
);

INSERT INTO silver.country_mapping (source_country, standard_country, iso3)
VALUES
    ('South Korea', 'Korea, Republic of', 'KOR'),
    ('Vietnam', 'Viet Nam', 'VNM'),
    ('UAE', 'United Arab Emirates', 'ARE'),
    ('Iran', 'Iran, Islamic Republic of', 'IRN'),
    ('Turkey', 'TÃ¼rkiye', 'TUR'),
    ('United States', 'United States of America', 'USA'),
    ('United Kingdom', 'United Kingdom of Great Britain and Northern Ireland', 'GBR'),
    ('Netherlands', 'Netherlands, Kingdom of the', 'NLD') ;
