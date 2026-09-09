USE olist_sales;
GO


/* =========================================================
   1. PRODUCT PERFORMANCE
   ========================================================= */

WITH product_sales AS
(
    SELECT
        p.product_id,
        p.product_category_name,

        COUNT(oi.order_id) AS total_items_sold,

        SUM(oi.price) AS product_revenue,

        SUM(oi.freight_value) AS freight_revenue,

        SUM(oi.price + oi.freight_value) AS total_revenue,

        AVG(oi.price) AS avg_price

    FROM catalog.products p

    JOIN sales.order_items oi
        ON p.product_id = oi.product_id

    GROUP BY
        p.product_id,
        p.product_category_name
)

SELECT
    *,
    
    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank

FROM product_sales

ORDER BY
    revenue_rank;
GO

/* =========================================================
   2. PRODUCT CATEGORY PERFORMANCE
   ========================================================= */

WITH category_sales AS
(
    SELECT
        p.product_category_name,

        COUNT(oi.order_id) AS total_items_sold,

        SUM(oi.price) AS product_revenue,

        SUM(oi.freight_value) AS freight_revenue,

        SUM(oi.price + oi.freight_value) AS total_revenue

    FROM catalog.products p

    JOIN sales.order_items oi
        ON p.product_id = oi.product_id

    GROUP BY
        p.product_category_name
)

SELECT
    product_category_name,
    total_items_sold,
    product_revenue,
    freight_revenue,
    total_revenue,

    ROUND(
        100.0 * total_revenue
        / SUM(total_revenue) OVER (),
        2
    ) AS revenue_share_percent

FROM category_sales

ORDER BY
    total_revenue DESC;
GO