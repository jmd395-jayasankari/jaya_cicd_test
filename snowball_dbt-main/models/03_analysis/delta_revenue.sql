WITH get_arr_business_flag AS (

    SELECT
        p1.period_revenue_key,

        -- KEY LEVEL COLUMNS (replace macro output with actual columns)
        p1.customer_level_1,
        p1.customer_level_2,
        p1.product_level_1,
        p1.product_level_2,
        p1.entity_level_1,
        p1.entity_level_2,
        p1.other_level_1,
        p1.other_level_2,

        p1.month_roll,
        p1.revenue_type,
        p1.arr,
        p1.arr_lm,
        p1.arr_l3m,
        p1.arr_ltm,
        p1.arr_ytd,
        p1.arr_lm_delta,
        p1.arr_l3m_delta,
        p1.arr_ltm_delta,
        p1.arr_ytd_delta,

        -- CUSTOMER FLAGS
        c.lm_customer_new_flag,
        c.l3m_customer_new_flag,
        c.ltm_customer_new_flag,
        c.ytd_customer_new_flag,

        c.lm_customer_churn_flag,
        c.l3m_customer_churn_flag,
        c.ltm_customer_churn_flag,
        c.ytd_customer_churn_flag,

        -- PRODUCT FLAGS
        p2.lm_product_churn_flag,
        p2.l3m_product_churn_flag,
        p2.ltm_product_churn_flag,
        p2.ytd_product_churn_flag,

        -- BUSINESS EVENT FLAGS
        b.deactivation_helper,
        b.intermittent_churn_helper,

        b.lm_cross_sell_flag,
        b.lm_upsell_flag,
        b.lm_downsell_flag,

        b.l3m_cross_sell_flag,
        b.l3m_upsell_flag,
        b.l3m_downsell_flag,

        b.ltm_cross_sell_flag,
        b.ltm_upsell_flag,
        b.ltm_downsell_flag,

        b.ytd_cross_sell_flag,
        b.ytd_upsell_flag,
        b.ytd_downsell_flag

    FROM your_db.your_schema.period_revenue p1

    INNER JOIN your_db.your_schema.customer_lifecycle_events c
        ON p1.period_revenue_key = c.customer_lifecycle_events_key
        AND p1.revenue_type = c.revenue_type
        AND p1.month_roll = c.month_roll

    INNER JOIN your_db.your_schema.customer_product_lifecycle_events p2
        ON p1.period_revenue_key = p2.customer_product_lifecycle_events_key
        AND p1.revenue_type = p2.revenue_type
        AND p1.month_roll = p2.month_roll

    INNER JOIN your_db.your_schema.customer_product_revenue_events b
        ON p1.period_revenue_key = b.customer_product_revenue_events_key
        AND p1.revenue_type = b.revenue_type
        AND p1.month_roll = b.month_roll
),

filling_delta AS (

    SELECT
        period_revenue_key,
        customer_level_1,
        customer_level_2,
        product_level_1,
        product_level_2,
        entity_level_1,
        entity_level_2,
        other_level_1,
        other_level_2,
        month_roll,
        revenue_type,

        -- MONTHLY
        CASE WHEN lm_customer_new_flag = 1 THEN arr ELSE 0 END AS lm_delta_customer_new,
        CASE WHEN lm_customer_churn_flag = 1 THEN -arr_lm ELSE 0 END AS lm_delta_customer_churn,
        CASE WHEN lm_cross_sell_flag = 1 THEN arr ELSE 0 END AS lm_delta_cross_sell,

        CASE
            WHEN deactivation_helper = 0
             AND intermittent_churn_helper = 0
             AND lm_product_churn_flag = 1
            THEN -arr_lm ELSE 0
        END AS lm_delta_downgrade,

        CASE WHEN lm_upsell_flag = 1 THEN arr_lm_delta ELSE 0 END AS lm_delta_upsell,
        CASE WHEN lm_downsell_flag = 1 THEN arr_lm_delta ELSE 0 END AS lm_delta_downsell,

        -- QUARTERLY
        CASE WHEN l3m_customer_new_flag = 1 THEN arr ELSE 0 END AS l3m_delta_customer_new,
        CASE WHEN l3m_customer_churn_flag = 1 THEN -arr_l3m ELSE 0 END AS l3m_delta_customer_churn,
        CASE WHEN l3m_cross_sell_flag = 1 THEN arr ELSE 0 END AS l3m_delta_cross_sell,

        CASE
            WHEN deactivation_helper = 0
             AND intermittent_churn_helper = 0
             AND l3m_product_churn_flag = 1
            THEN -arr_l3m ELSE 0
        END AS l3m_delta_downgrade,

        CASE WHEN l3m_upsell_flag = 1 THEN arr_l3m_delta ELSE 0 END AS l3m_delta_upsell,
        CASE WHEN l3m_downsell_flag = 1 THEN arr_l3m_delta ELSE 0 END AS l3m_delta_downsell,

        -- LTM
        CASE WHEN ltm_customer_new_flag = 1 THEN arr ELSE 0 END AS ltm_delta_customer_new,
        CASE WHEN ltm_customer_churn_flag = 1 THEN -arr_ltm ELSE 0 END AS ltm_delta_customer_churn,
        CASE WHEN ltm_cross_sell_flag = 1 THEN arr ELSE 0 END AS ltm_delta_cross_sell,

        CASE
            WHEN deactivation_helper = 0
             AND intermittent_churn_helper = 0
             AND ltm_product_churn_flag = 1
            THEN -arr_ltm ELSE 0
        END AS ltm_delta_downgrade,

        CASE WHEN ltm_upsell_flag = 1 THEN arr_ltm_delta ELSE 0 END AS ltm_delta_upsell,
        CASE WHEN ltm_downsell_flag = 1 THEN arr_ltm_delta ELSE 0 END AS ltm_delta_downsell,

        -- YTD
        CASE WHEN ytd_customer_new_flag = 1 THEN arr ELSE 0 END AS ytd_delta_customer_new,
        CASE WHEN ytd_customer_churn_flag = 1 THEN -arr_ytd ELSE 0 END AS ytd_delta_customer_churn,
        CASE WHEN ytd_cross_sell_flag = 1 THEN arr ELSE 0 END AS ytd_delta_cross_sell,

        CASE
            WHEN deactivation_helper = 0
             AND intermittent_churn_helper = 0
             AND ytd_product_churn_flag = 1
            THEN -arr_ytd ELSE 0
        END AS ytd_delta_downgrade,

        CASE WHEN ytd_upsell_flag = 1 THEN arr_ytd_delta ELSE 0 END AS ytd_delta_upsell,
        CASE WHEN ytd_downsell_flag = 1 THEN arr_ytd_delta ELSE 0 END AS ytd_delta_downsell

    FROM get_arr_business_flag
)

SELECT
    period_revenue_key AS delta_revenue_key,
    month_roll,
    customer_level_1,
    customer_level_2,
    product_level_1,
    product_level_2,
    entity_level_1,
    entity_level_2,
    other_level_1,
    other_level_2,
    revenue_type,

    lm_delta_customer_new,
    lm_delta_customer_churn,
    lm_delta_cross_sell,
    lm_delta_downgrade,
    lm_delta_upsell,
    lm_delta_downsell,

    l3m_delta_customer_new,
    l3m_delta_customer_churn,
    l3m_delta_cross_sell,
    l3m_delta_downgrade,
    l3m_delta_upsell,
    l3m_delta_downsell,

    ltm_delta_customer_new,
    ltm_delta_customer_churn,
    ltm_delta_cross_sell,
    ltm_delta_downgrade,
    ltm_delta_upsell,
    ltm_delta_downsell,

    ytd_delta_customer_new,
    ytd_delta_customer_churn,
    ytd_delta_cross_sell,
    ytd_delta_downgrade,
    ytd_delta_upsell,
    ytd_delta_downsell

FROM filling_delta;
