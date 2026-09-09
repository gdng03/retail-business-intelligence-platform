* ==== Dim_Date ====
USE olist_analytics;
GO

CREATE TABLE dw.Dim_Date
(
    date_key INT NOT NULL,
    full_date DATE NOT NULL,

    day_number INT NOT NULL,
    month_number INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,

    quarter_number INT NOT NULL,
    year_number INT NOT NULL,

    day_of_week INT NOT NULL,
    day_name VARCHAR(20) NOT NULL,

    is_weekend BIT NOT NULL,

    CONSTRAINT pk_dim_date
        PRIMARY KEY (date_key),

    CONSTRAINT uq_dim_date
        UNIQUE (full_date)
);
GO

* ==== Dim_Product ====
CREATE TABLE dw.Dim_Product
(
    product_key INT IDENTITY(1,1) NOT NULL,

    product_id VARCHAR(32) NOT NULL,

    product_category_name VARCHAR(100) NULL,

    product_name_length INT NULL,
    product_description_length INT NULL,
    product_photos_qty INT NULL,

    product_weight_g INT NULL,
    product_length_cm INT NULL,
    product_height_cm INT NULL,
    product_width_cm INT NULL,

    CONSTRAINT pk_dim_product
        PRIMARY KEY (product_key),

    CONSTRAINT uq_dim_product
        UNIQUE (product_id)
);
GO

* ==== Dim_Customer ====
CREATE TABLE dw.Dim_Customer
(
    customer_key INT IDENTITY(1,1) NOT NULL,

    customer_id VARCHAR(32) NOT NULL,

    CONSTRAINT pk_dim_customer
        PRIMARY KEY (customer_key),

    CONSTRAINT uq_dim_customer
        UNIQUE (customer_id)
);
GO

* ==== Dim_Seller ====
CREATE TABLE dw.Dim_Seller
(
    seller_key INT IDENTITY(1,1) NOT NULL,

    seller_id VARCHAR(32) NOT NULL,

    CONSTRAINT pk_dim_seller
        PRIMARY KEY (seller_key),

    CONSTRAINT uq_dim_seller
        UNIQUE (seller_id)
);
GO

* ==== Fact_Sales ====
CREATE TABLE dw.Fact_Sales
(
    sales_key BIGINT IDENTITY(1,1) NOT NULL,

    date_key INT NOT NULL,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    seller_key INT NOT NULL,

    order_id VARCHAR(32) NOT NULL,
    order_item_id INT NOT NULL,

    price DECIMAL(12,2) NOT NULL,
    freight_value DECIMAL(12,2) NOT NULL,

    total_item_value AS
        (price + freight_value) PERSISTED,

    CONSTRAINT pk_fact_sales
        PRIMARY KEY (sales_key),

    CONSTRAINT uq_fact_sales_item
        UNIQUE (order_id, order_item_id),

    CONSTRAINT fk_fact_sales_date
        FOREIGN KEY (date_key)
        REFERENCES dw.Dim_Date(date_key),

    CONSTRAINT fk_fact_sales_customer
        FOREIGN KEY (customer_key)
        REFERENCES dw.Dim_Customer(customer_key),

    CONSTRAINT fk_fact_sales_product
        FOREIGN KEY (product_key)
        REFERENCES dw.Dim_Product(product_key),

    CONSTRAINT fk_fact_sales_seller
        FOREIGN KEY (seller_key)
        REFERENCES dw.Dim_Seller(seller_key)
);
GO

*==== CHECKING =====
SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dw'
ORDER BY TABLE_NAME;