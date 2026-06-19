WITH

fact_revenue AS (
    SELECT *
    FROM your_db.your_schema.fact_revenue
),

dim_customer AS (
    SELECT *
    FROM your_db.your_schema.dim_customer
),

dim_product AS (
    SELECT *
    FROM your_db.your_schema.dim_product
),

dim_entity AS (
    SELECT *
    FROM your_db.your_schema.dim_entity
),

dim_other AS (
    SELECT *
    FROM your_db.your_schema.dim_other
),

dim_calendar AS (
    SELECT *
    FROM your_db.your_schema.dim_calendar
),

date_joins AS (

    SELECT

        MD5(
            CONCAT(
                COALESCE(UPPER(r.customer_key), ''),
                COALESCE(UPPER(r.product_key), ''),
                COALESCE(UPPER(r.entity_key), ''),
                COALESCE(UPPER(r.other_key), ''),
                COALESCE(UPPER(r.revenue_type), '')
            )
        ) AS revenue_key,

        r.revenue_type,
        r.month,
        r.revenue,
        r.volume,

        MIN(r.month) OVER (
            PARTITION BY MD5(
                CONCAT(
                    COALESCE(UPPER(r.customer_key), ''),
                    COALESCE(UPPER(r.product_key), ''),
                    COALESCE(UPPER(r.entity_key), ''),
                    COALESCE(UPPER(r.other_key), ''),
                    COALESCE(UPPER(r.revenue_type), '')
                )
            )
        ) AS segment_start_month,

        MAX(r.month) OVER (
            PARTITION BY MD5(
                CONCAT(
                    COALESCE(UPPER(r.customer_key), ''),
                    COALESCE(UPPER(r.product_key), ''),
                    COALESCE(UPPER(r.entity_key), ''),
                    COALESCE(UPPER(r.other_key), ''),
                    COALESCE(UPPER(r.revenue_type), '')
                )
            )
        ) AS segment_end_month,

        c.*,
        p.*,
        o.*

    FROM fact_revenue r

    LEFT JOIN dim_customer c
        ON r.customer_key = c.customer_key

    LEFT JOIN dim_product p
        ON r.product_key = p.product_key

    LEFT JOIN dim_entity e
        ON r.entity_key = e.entity_key

    LEFT JOIN dim_other o
        ON r.other_key = o.other_key

    WHERE r.revenue <> 0.00
),

date_scaffolding AS (

    SELECT

        d.revenue_key,
        d.revenue_type,

        c.customer_key,
        p.product_key,
        e.entity_key,
        o.other_key,

        cal.month_roll,

        CASE
            WHEN cal.month_roll <> d.month THEN 0
            ELSE d.volume
        END AS volume,

        CASE
            WHEN cal.month_roll <> d.month THEN 0
            ELSE d.revenue
        END AS mrr

    FROM dim_calendar cal

    INNER JOIN date_joins d
        ON cal.month_roll <= DATEADD(MONTH, 22, d.segment_end_month)
       AND cal.month_roll >= d.segment_start_month
),

aggregated_revenue AS (

    SELECT

        revenue_key AS monthly_revenue_key,
        revenue_type,

        customer_key,
        product_key,
        entity_key,
        other_key,

        month_roll,

        SUM(mrr) AS mrr,
        SUM(volume) AS volume,

        DATE_PART(
            MONTH,
            DATEADD(
                MONTH,
                -{{ var('ytd_year_start') }} + 1,
                month_roll
            )
        ) AS ytd_helper

    FROM date_scaffolding

    GROUP BY
        revenue_key,
        revenue_type,
        customer_key,
        product_key,
        entity_key,
        other_key,
        month_roll
),

churn_month AS (

    SELECT
        customer_key,
        product_key,
        MAX(month_roll) AS product_churn_month

    FROM aggregated_revenue

    WHERE mrr <> 0.0

    GROUP BY
        customer_key,
        product_key
)

SELECT

    a.*,

    CASE
        WHEN a.revenue_type = 'Recurring' THEN a.mrr * 12

        WHEN a.month_roll <= c.product_churn_month THEN
            SUM(a.mrr) OVER (
                PARTITION BY a.monthly_revenue_key
                ORDER BY a.month_roll
                ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
            )

        ELSE 0
    END AS arr

FROM aggregated_revenue a

LEFT JOIN churn_month c
    ON a.customer_key = c.customer_key
   AND a.product_key = c.product_key;
