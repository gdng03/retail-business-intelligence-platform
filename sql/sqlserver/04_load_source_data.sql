USE olist_sales;
GO

BULK INSERT catalog.products
FROM '/var/opt/mssql/data/raw/olist_products_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);
GO

BULK INSERT sales.orders
FROM '/var/opt/mssql/data/raw/olist_orders_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);
GO

BULK INSERT sales.order_items
FROM '/var/opt/mssql/data/raw/olist_order_items_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);
GO

BULK INSERT sales.order_payments
FROM '/var/opt/mssql/data/raw/olist_order_payments_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);
GO

BULK INSERT sales.order_reviews
FROM '/var/opt/mssql/data/raw/olist_order_reviews_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);
GO

