USE olist_sales;
GO


/* =========================================================
   1. ORDER VALUE ANALYSIS
   ========================================================= */

WITH order_value AS
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchase_timestamp,

        SUM(oi.price) AS product_value,

        SUM(oi.freight_value) AS freight_value,

        SUM(oi.price + oi.freight_value) AS order_value

    FROM sales.orders o

    JOIN sales.order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchase_timestamp
)

SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    product_value,
    freight_value,
    order_value,

    CASE
        WHEN order_value < 50
            THEN 'Low Value'

        WHEN order_value < 150
            THEN 'Medium Value'

        WHEN order_value < 300
            THEN 'High Value'

        ELSE 'Very High Value'
    END AS order_value_segment

FROM order_value

ORDER BY
    order_value DESC;
GO

/* =========================================================
   2. ORDER STATUS PERFORMANCE
   ========================================================= */

SELECT
    order_status,

    COUNT(*) AS total_orders,

    CAST(
        100.0 * COUNT(*)
        / SUM(COUNT(*)) OVER ()
        AS DECIMAL(10,2)
    ) AS order_share_percent

FROM sales.orders

GROUP BY
    order_status

ORDER BY
    total_orders DESC;
GO

/* =========================================================
   3. PAYMENT METHOD ANALYSIS
   ========================================================= */

SELECT
    payment_type,

    COUNT(DISTINCT order_id) AS total_orders,

    SUM(payment_value) AS total_payment_value,

    AVG(payment_value) AS avg_payment_value,

    AVG(payment_installments) AS avg_installments

FROM sales.order_payments

GROUP BY
    payment_type

ORDER BY
    total_payment_value DESC;
GO