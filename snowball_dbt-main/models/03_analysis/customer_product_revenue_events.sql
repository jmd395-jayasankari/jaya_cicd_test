WITH product_grew AS (

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
        arr,
        arr_lm,
        arr_l3m,
        arr_ltm,
        arr_ytd,

        CASE WHEN sum_arr_lm_delta > 0 THEN 1 ELSE 0 END AS product_grew_monthly,
        CASE WHEN sum_arr_lm_delta < 0 THEN 1 ELSE 0 END AS product_declined_monthly,

        CASE WHEN sum_arr_l3m_delta > 0 THEN 1 ELSE 0 END AS product_grew_quarterly,
        CASE WHEN sum_arr_l3m_delta < 0 THEN 1 ELSE 0 END AS product_declined_quarterly,

        CASE WHEN sum_arr_ltm_delta > 0 THEN 1 ELSE 0 END AS product_grew_yearly,
        CASE WHEN sum_arr_ltm_delta < 0 THEN 1 ELSE 0 END AS product_declined_yearly,

        CASE WHEN sum_arr_ytd_delta > 0 THEN 1 ELSE 0 END AS product_grew_ytd,
        CASE WHEN sum_arr_ytd_delta < 0 THEN 1 ELSE 0 END AS product_declined_ytd

    FROM period_revenue
)

, ranked_product AS (

    SELECT
        p1.period_revenue_key,

        p1.customer_level_1,
        p1.customer_level_2,
        p1.product_level_1,
        p1.product_level_2,
        p1.entity_level_1,
        p1.entity_level_2,
        p1.other_level_1,
        p1.other_level_2,

        p1.revenue_type,
        p1.arr,
        p1.arr_lm,
        p1.arr_l3m,
        p1.arr_ltm,
        p1.arr_ytd,
        p1.month_roll,

        c.lm_customer_new_flag,
        c.l3m_customer_new_flag,
        c.ltm_customer_new_flag,
        c.ytd_customer_new_flag,

        c.lm_customer_churn_flag,
        c.l3m_customer_churn_flag,
        c.ltm_customer_churn_flag,
        c.ytd_customer_churn_flag,

        p2.lm_product_existing_flag,
        p2.l3m_product_existing_flag,
        p2.ltm_product_existing_flag,
        p2.ytd_product_existing_flag,

        p2.lm_product_churn_flag,
        p2.l3m_product_churn_flag,
        p2.ltm_product_churn_flag,
        p2.ytd_product_churn_flag,

        p3.product_start_month,

        CASE
            WHEN c.lm_customer_existing_flag = 1
                 AND p3.product_start_month = p1.month_roll
            THEN 1 ELSE 0
        END AS lm_cross_sell_flag,

        CASE
            WHEN product_grew_monthly = 1
                 AND p2.lm_product_existing_flag = 1
            THEN 1 ELSE 0
        END AS lm_upsell_flag,

        CASE
            WHEN product_declined_monthly = 1
                 AND p2.lm_product_existing_flag = 1
            THEN 1 ELSE 0
        END AS lm_downsell_flag

    FROM period_revenue p1

    JOIN customer_lifecycle_events c
        ON p1.period_revenue_key = c.customer_lifecycle_events_key
        AND p1.revenue_type = c.revenue_type
        AND p1.month_roll = c.month_roll

    JOIN customer_product_lifecycle_events p2
        ON p1.period_revenue_key = p2.customer_product_lifecycle_events_key
        AND p1.revenue_type = p2.revenue_type
        AND p1.month_roll = p2.month_roll

    JOIN customer_product_contract p3
        ON p1.customer_level_1 = p3.customer_level_1
        AND p1.product_level_1 = p3.product_level_1
)

SELECT
    period_revenue_key AS customer_product_revenue_events_key,

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

    0 AS winback_helper,
    0 AS deactivation_helper,
    0 AS reactivation_helper,
    0 AS intermittent_churn_helper,

    CASE
        WHEN winback_helper = 0
         AND deactivation_helper = 0
         AND reactivation_helper = 0
         AND intermittent_churn_helper = 0
        THEN lm_cross_sell_flag ELSE 0
    END AS lm_cross_sell_flag,

    CASE
        WHEN winback_helper = 0
         AND deactivation_helper = 0
         AND reactivation_helper = 0
         AND intermittent_churn_helper = 0
        THEN lm_upsell_flag ELSE 0
    END AS lm_upsell_flag,

    CASE
        WHEN winback_helper = 0
         AND deactivation_helper = 0
         AND reactivation_helper = 0
         AND intermittent_churn_helper = 0
        THEN lm_downsell_flag ELSE 0
    END AS lm_downsell_flag

FROM ranked_product;
