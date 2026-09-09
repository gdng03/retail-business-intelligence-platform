/* =========================================================
   1. MQL TO CLOSED DEAL CONVERSION
   ========================================================= */

SELECT

    COUNT(DISTINCT m.mql_id) AS total_mqls,

    COUNT(DISTINCT c.mql_id) AS converted_leads,

    COUNT(DISTINCT m.mql_id)
        - COUNT(DISTINCT c.mql_id) AS non_converted_leads,

    ROUND(
        100.0 *
        COUNT(DISTINCT c.mql_id)
        / NULLIF(COUNT(DISTINCT m.mql_id), 0),
        2
    ) AS conversion_rate_percent

FROM marketing.marketing_qualified_leads m

LEFT JOIN marketing.closed_deals c
    ON m.mql_id = c.mql_id;

/* =========================================================
   2. LEAD TYPE PERFORMANCE
   ========================================================= */

SELECT

    m.lead_type,

    COUNT(DISTINCT m.mql_id) AS total_mqls,

    COUNT(DISTINCT c.mql_id) AS converted_leads,

    ROUND(
        100.0 *
        COUNT(DISTINCT c.mql_id)
        / NULLIF(COUNT(DISTINCT m.mql_id), 0),
        2
    ) AS conversion_rate_percent

FROM marketing.marketing_qualified_leads m

LEFT JOIN marketing.closed_deals c
    ON m.mql_id = c.mql_id

GROUP BY
    m.lead_type

ORDER BY
    conversion_rate_percent DESC;

/* =========================================================
   3. BUSINESS SEGMENT PERFORMANCE
   ========================================================= */

SELECT

    c.business_segment,

    COUNT(DISTINCT c.mql_id) AS closed_deals,

    AVG(c.declared_monthly_revenue) AS avg_declared_monthly_revenue,

    AVG(c.declared_product_catalog_size)
        AS avg_product_catalog_size

FROM marketing.closed_deals c

GROUP BY
    c.business_segment

ORDER BY
    closed_deals DESC;

/* =========================================================
   4. SDR PERFORMANCE
   ========================================================= */

SELECT

    sdr_id,

    COUNT(DISTINCT mql_id) AS closed_deals,

    AVG(declared_monthly_revenue)
        AS avg_declared_monthly_revenue

FROM marketing.closed_deals

GROUP BY
    sdr_id

ORDER BY
    closed_deals DESC;