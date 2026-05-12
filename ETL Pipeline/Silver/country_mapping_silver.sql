CREATE TABLE silver.countries_mapping (
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
