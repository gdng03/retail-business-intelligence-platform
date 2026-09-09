#====== Dim_Date ======
USE olist_analytics;
GO

DECLARE @StartDate DATE = '2016-01-01';
DECLARE @EndDate DATE = '2018-12-31';

WITH DateSeries AS
(
    SELECT @StartDate AS full_date

    UNION ALL

    SELECT DATEADD(DAY, 1, full_date)
    FROM DateSeries
    WHERE full_date < @EndDate
)
INSERT INTO dw.Dim_Date
(
    date_key,
    full_date,
    day_number,
    month_number,
    month_name,
    quarter_number,
    year_number,
    day_of_week,
    day_name,
    is_weekend
)
SELECT
    CONVERT(INT, CONVERT(CHAR(8), full_date, 112)) AS date_key,
    full_date,
    DAY(full_date),
    MONTH(full_date),
    DATENAME(MONTH, full_date),
    DATEPART(QUARTER, full_date),
    YEAR(full_date),
    DATEPART(WEEKDAY, full_date),
    DATENAME(WEEKDAY, full_date),
    CASE
        WHEN DATEPART(WEEKDAY, full_date) IN (1, 7)
        THEN 1
        ELSE 0
    END
FROM DateSeries
OPTION (MAXRECURSION 0);
GO


# ====== Dim_Product ======
USE olist_analytics;
GO

INSERT INTO dw.Dim_Product
(
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
)
SELECT
    p.product_id,
    p.product_category_name,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM olist_sales.catalog.products p;
GO

# ====== Import_Customer ======
USE olist_analytics;
GO

CREATE TABLE dw.Import_Customer (
    seller_id VARCHAR(50) NOT NULL
);
GO

BULK INSERT dw.Import_Customer
FROM '/var/opt/mssql/data/raw/dw_customers.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);
GO

# ====== Dim_Customer ======
INSERT INTO dw.Dim_Customer (customer_id)
SELECT
    REPLACE(
        REPLACE(customer_id, CHAR(13), ''),
        CHAR(10), ''
    )
FROM dw.Import_Customer;
GO

# ====== Import_Seller =======
USE olist_analytics;
GO

CREATE TABLE dw.Import_Seller (
    seller_id VARCHAR(50) NOT NULL
);
GO

BULK INSERT dw.Import_Seller
FROM '/var/opt/mssql/data/raw/dw_sellers.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);
GO
# ====== Dim_Seller ======
INSERT INTO dw.Dim_Seller (seller_id)
SELECT
    REPLACE(
        REPLACE(seller_id, CHAR(13), ''),
        CHAR(10), ''
    )
FROM dw.Import_Seller;
GO