-- PostgreSQL
-- Database: olist_crm
-- Source layer: CRM + Marketing + Reference

CREATE SCHEMA IF NOT EXISTS crm;
CREATE SCHEMA IF NOT EXISTS marketing;
CREATE SCHEMA IF NOT EXISTS reference;

CREATE TABLE IF NOT EXISTS crm.customers (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32) NOT NULL,
    customer_zip_code_prefix INTEGER NOT NULL,
    customer_city VARCHAR(100) NOT NULL,
    customer_state CHAR(2) NOT NULL
);

CREATE TABLE IF NOT EXISTS crm.sellers (
    seller_id VARCHAR(32) PRIMARY KEY,
    seller_zip_code_prefix INTEGER NOT NULL,
    seller_city VARCHAR(100) NOT NULL,
    seller_state CHAR(2) NOT NULL
);

CREATE TABLE IF NOT EXISTS marketing.marketing_qualified_leads (
    mql_id VARCHAR(32) PRIMARY KEY,
    first_contact_date DATE NOT NULL,
    landing_page_id VARCHAR(100) NOT NULL,
    origin VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS marketing.closed_deals (
    mql_id VARCHAR(32) PRIMARY KEY,
    seller_id VARCHAR(32) NOT NULL,
    sdr_id VARCHAR(32) NOT NULL,
    sr_id VARCHAR(32) NOT NULL,
    won_date TIMESTAMP NOT NULL,
    business_segment VARCHAR(100) NOT NULL,
    lead_type VARCHAR(100),
    lead_behaviour_profile VARCHAR(100),
    has_company BOOLEAN,
    has_gtin BOOLEAN,
    average_stock VARCHAR(100),
    business_type VARCHAR(100) NOT NULL,
    declared_product_catalog_size NUMERIC,
    declared_monthly_revenue NUMERIC(15,2),

    CONSTRAINT fk_closed_deals_mql
        FOREIGN KEY (mql_id)
        REFERENCES marketing.marketing_qualified_leads(mql_id),

    CONSTRAINT fk_closed_deals_seller
        FOREIGN KEY (seller_id)
        REFERENCES crm.sellers(seller_id)
);

CREATE TABLE IF NOT EXISTS reference.geolocation (
    geolocation_zip_code_prefix INTEGER NOT NULL,
    geolocation_lat NUMERIC(10,7) NOT NULL,
    geolocation_lng NUMERIC(10,7) NOT NULL,
    geolocation_city VARCHAR(100) NOT NULL,
    geolocation_state CHAR(2) NOT NULL
);

CREATE TABLE IF NOT EXISTS reference.product_category_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100) NOT NULL
);

