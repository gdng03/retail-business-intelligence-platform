-- SALE PERFORMANCE
USE olist_sales;
GO

CREATE OR ALTER VIEW sales.vw_monthly_sales
AS
SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(oi.order_id) AS total_items,

    SUM(oi.price) AS product_revenue,

    SUM(oi.freight_value) AS freight_revenue,

    SUM(oi.price + oi.freight_value) AS total_sales,

    AVG(oi.price) AS avg_item_price

FROM sales.orders o
JOIN sales.order_items oi
    ON o.order_id = oi.order_id

GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp);
GO

-- test
SELECT *
FROM sales.vw_monthly_sales;

-- ORDER PERFORMANCE
CREATE OR ALTER VIEW sales.vw_order_performance
AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,

    COUNT(oi.order_item_id) AS item_count,

    SUM(oi.price) AS product_value,

    SUM(oi.freight_value) AS freight_value,

    SUM(oi.price + oi.freight_value) AS order_value

FROM sales.orders o
LEFT JOIN sales.order_items oi
    ON o.order_id = oi.order_id

GROUP BY
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp;
GO

-- test
SELECT TOP 20 *
FROM sales.vw_order_performance
ORDER BY order_value DESC;