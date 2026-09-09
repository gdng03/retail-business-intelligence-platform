INSERT INTO dw.Fact_Sales (
    date_key,
    customer_key,
    product_key,
    seller_key,
    order_id,
    order_item_id,
    price,
    freight_value
)
SELECT
    d.date_key,
    c.customer_key,
    p.product_key,
    s.seller_key,
    o.order_id,
    oi.order_item_id,
    oi.price,
    oi.freight_value
FROM olist_sales.sales.orders o
JOIN olist_sales.sales.order_items oi
    ON o.order_id = oi.order_id
LEFT JOIN dw.Dim_Customer c
    ON o.customer_id = c.customer_id
LEFT JOIN dw.Dim_Product p
    ON oi.product_id = p.product_id
LEFT JOIN dw.Dim_Seller s
    ON oi.seller_id = s.seller_id
LEFT JOIN dw.Dim_Date d
    ON CAST(o.order_purchase_timestamp AS DATE) = d.full_date;
GO