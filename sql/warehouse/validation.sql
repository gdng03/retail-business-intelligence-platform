-- Kiểm tra duplicate theo grain
USE olist_analytics;
GO

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS row_count
FROM dw.Fact_Sales
GROUP BY
    order_id,
    order_item_id
HAVING COUNT(*) > 1;
GO

-- Kiểm tra các Dimension Key bị NULL
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN date_key IS NULL THEN 1 ELSE 0 END) AS missing_date,
    SUM(CASE WHEN customer_key IS NULL THEN 1 ELSE 0 END) AS missing_customer,
    SUM(CASE WHEN product_key IS NULL THEN 1 ELSE 0 END) AS missing_product,
    SUM(CASE WHEN seller_key IS NULL THEN 1 ELSE 0 END) AS missing_seller

FROM dw.Fact_Sales;
GO

-- Kiểm tra giá trị sale
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN price < 0 THEN 1 ELSE 0 END) AS negative_price,

    SUM(CASE WHEN freight_value < 0 THEN 1 ELSE 0 END) AS negative_freight,

    SUM(CASE WHEN total_item_value < 0 THEN 1 ELSE 0 END) AS negative_total

FROM dw.Fact_Sales;
GO

-- Kiểm tra công thức total_item_value
SELECT TOP 20
    order_id,
    order_item_id,
    price,
    freight_value,
    total_item_value,
    price + freight_value AS expected_total
FROM dw.Fact_Sales
WHERE total_item_value <> price + freight_value;
GO
