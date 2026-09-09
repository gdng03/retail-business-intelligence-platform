USE olist_sales;
GO


/* =========================================================
   1. CUSTOMER SPENDING ANALYSIS
   ========================================================= */

WITH customer_sales AS
(
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COUNT(oi.order_item_id) AS total_items,
        SUM(oi.price) AS product_spending,
        SUM(oi.freight_value) AS freight_spending,
        SUM(oi.price + oi.freight_value) AS total_spending,
        AVG(oi.price + oi.freight_value) AS avg_item_value

    FROM sales.orders o

    JOIN sales.order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        o.customer_id
)

SELECT
    customer_id,
    total_orders,
    total_items,
    product_spending,
    freight_spending,
    total_spending,
    avg_item_value,

    RANK() OVER (
        ORDER BY total_spending DESC
    ) AS spending_rank

FROM customer_sales

ORDER BY
    spending_rank;
GO

/* =========================================================
   2. CUSTOMER VALUE SEGMENTATION
   ========================================================= */

WITH customer_sales AS
(
    SELECT
        o.customer_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        SUM(oi.price + oi.freight_value) AS total_spending

    FROM sales.orders o

    JOIN sales.order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        o.customer_id
),

customer_segment AS
(
    SELECT
        customer_id,
        total_orders,
        total_spending,

        NTILE(4) OVER (
            ORDER BY total_spending
        ) AS spending_quartile

    FROM customer_sales
)

SELECT
    customer_id,
    total_orders,
    total_spending,
    spending_quartile,

    CASE
        WHEN spending_quartile = 4
            THEN 'High Value'

        WHEN spending_quartile = 3
            THEN 'Medium-High Value'

        WHEN spending_quartile = 2
            THEN 'Medium-Low Value'

        ELSE 'Low Value'
    END AS customer_segment

FROM customer_segment

ORDER BY
    total_spending DESC;
GO

/* =========================================================
   3. REPEAT CUSTOMER ANALYSIS
   ========================================================= */

WITH customer_orders AS
(
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM sales.orders
    GROUP BY customer_id
)

SELECT
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN total_orders = 1 THEN 1
            ELSE 0
        END
    ) AS one_time_customers,

    SUM(
        CASE
            WHEN total_orders > 1 THEN 1
            ELSE 0
        END
    ) AS repeat_customers,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN total_orders > 1 THEN 1
                ELSE 0
            END
        )
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS repeat_customer_rate

FROM customer_orders;
GO