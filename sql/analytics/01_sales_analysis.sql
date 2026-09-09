USE olist_sales;
GO

/* =========================================================
   01 - SALES ANALYSIS
   ========================================================= */


/* ---------------------------------------------------------
   1. Monthly Sales Performance
   --------------------------------------------------------- */

SELECT
    order_year,
    order_month,
    total_orders,
    total_items,
    product_revenue,
    freight_revenue,
    total_sales,
    avg_item_price
FROM sales.vw_monthly_sales
ORDER BY
    order_year,
    order_month;
GO

/* ---------------------------------------------------------
   2. Monthly Sales + MoM Growth
   --------------------------------------------------------- */

WITH monthly_sales AS (
    SELECT
        order_year,
        order_month,
        total_sales
    FROM sales.vw_monthly_sales
)

SELECT
    order_year,
    order_month,
    total_sales,

    LAG(total_sales) OVER (
        ORDER BY order_year, order_month
    ) AS previous_month_sales,

    total_sales - LAG(total_sales) OVER (
            ORDER BY order_year, order_month
        ) AS sales_change,

    ROUND(
        (
            total_sales
            - LAG(total_sales) OVER (
                ORDER BY order_year, order_month
            )
        )
        * 100.0
        / NULLIF(
            LAG(total_sales) OVER (
                ORDER BY order_year, order_month
            ),
            0
        ),
        2
    ) AS mom_growth_pct

FROM monthly_sales

ORDER BY
    order_year,
    order_month;
GO