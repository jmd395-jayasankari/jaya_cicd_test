{{ 
    config(
        tags=['analysis']
    ) 
}}

WITH get_ytd_start AS (

    SELECT
        monthly_revenue_key,
        customer_key,
        product_key,
        entity_key,
        other_key,
        month_roll,
        arr,
        mrr,
        volume,
        ytd_helper,
        revenue_type
    FROM {{ ref('monthly_revenue') }}
    WHERE revenue_type IN ('Recurring','Re-occurring')
),

get_revenue_lags AS (

    SELECT
        a.monthly_revenue_key,
        a.customer_key,
        a.product_key,
        a.entity_key,
        a.other_key,
        a.month_roll,
        a.arr,
        a.mrr,
        a.volume,
        a.revenue_type,

        COALESCE(LAG(a.arr, 1) OVER (PARTITION BY a.monthly_revenue_key, a.revenue_type ORDER BY a.month_roll), 0)  AS arr_lm,
        COALESCE(LAG(a.arr, 3) OVER (PARTITION BY a.monthly_revenue_key, a.revenue_type ORDER BY a.month_roll), 0)  AS arr_l3m,
        COALESCE(LAG(a.arr, 12) OVER (PARTITION BY a.monthly_revenue_key, a.revenue_type ORDER BY a.month_roll), 0) AS arr_ltm,

        COALESCE(b.arr, 0) AS arr_ytd

    FROM get_ytd_start a

    LEFT JOIN get_ytd_start b
        ON a.customer_key = b.customer_key
        AND a.product_key = b.product_key
        AND a.entity_key = b.entity_key
        AND a.revenue_type = b.revenue_type
        AND a.month_roll = DATEADD(MONTH, a.ytd_helper, b.month_roll)
),

get_delta_revenue AS (

    SELECT
        monthly_revenue_key,
        customer_key,
        product_key,
        entity_key,
        other_key,
        month_roll,
        revenue_type,
        mrr,
        arr,
        volume,
        arr_lm,
        arr_l3m,
        arr_ltm,
        arr_ytd,

        arr - arr_lm  AS arr_lm_delta,
        arr - arr_l3m AS arr_l3m_delta,
        arr - arr_ltm AS arr_ltm_delta,
        arr - arr_ytd AS arr_ytd_delta

    FROM get_revenue_lags
),

find_price_volume_deltas AS (

    SELECT
        customer_key,
        product_key,
        month_roll,
        revenue_type,

        SUM(arr_lm_delta)  AS sum_arr_lm_delta,
        SUM(arr_l3m_delta) AS sum_arr_l3m_delta,
        SUM(arr_ltm_delta) AS sum_arr_ltm_delta,
        SUM(arr_ytd_delta) AS sum_arr_ytd_delta

    FROM get_delta_revenue
    GROUP BY
        customer_key,
        product_key,
        month_roll,
        revenue_type
)

SELECT
    r.monthly_revenue_key AS period_revenue_key,

    r.customer_key,
    r.product_key,
    r.entity_key,
    r.other_key,

    r.month_roll,
    r.mrr,
    r.arr,
    r.volume,
    r.revenue_type,

    r.arr_lm,
    r.arr_l3m,
    r.arr_ltm,
    r.arr_ytd,

    r.arr_lm_delta,
    r.arr_l3m_delta,
    r.arr_ltm_delta,
    r.arr_ytd_delta,

    p.sum_arr_lm_delta,
    p.sum_arr_l3m_delta,
    p.sum_arr_ltm_delta,
    p.sum_arr_ytd_delta

FROM get_delta_revenue r

LEFT JOIN find_price_volume_deltas p
    ON r.customer_key = p.customer_key
    AND r.product_key = p.product_key
    AND r.month_roll = p.month_roll
    AND r.revenue_type = p.revenue_type
