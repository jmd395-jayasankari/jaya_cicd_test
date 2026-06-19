WITH get_churn_month_difference AS (

    SELECT
        m.monthly_revenue_key,

        m.customer_level_1,
        m.customer_level_2,
        m.product_level_1,
        m.product_level_2,

        m.month_roll,
        m.revenue_type,
        m.ytd_helper,

        p.product_start_month,
        p.product_end_month,
        p.product_churn_month,

        c.lm_customer_existing_flag,
        c.l3m_customer_existing_flag,
        c.ltm_customer_existing_flag,
        c.ytd_customer_existing_flag,

        DATEDIFF(MONTH, p.product_start_month, m.month_roll) AS product_start_month_difference,
        DATEDIFF(MONTH, p.product_churn_month, m.month_roll) AS product_churn_month_difference

    FROM monthly_revenue m

    INNER JOIN customer_product_contract p
        ON m.customer_level_1 = p.customer_level_1
        AND m.product_level_1 = p.product_level_1

    INNER JOIN customer_lifecycle_events c
        ON m.monthly_revenue_key = c.customer_lifecycle_events_key
        AND m.revenue_type = c.revenue_type
        AND m.month_roll = c.month_roll
        AND m.customer_level_1 = c.customer_level_1

    WHERE m.revenue_type IN ('Recurring', 'Re-occurring')
)

, product_lifecycle_flags AS (

    SELECT
        monthly_revenue_key,

        customer_level_1,
        customer_level_2,
        product_level_1,
        product_level_2,

        month_roll,
        revenue_type,

        CASE
            WHEN lm_customer_existing_flag = 1
                AND month_roll > product_start_month
                AND month_roll < product_churn_month
            THEN 1 ELSE 0
        END AS lm_product_existing_flag,

        CASE
            WHEN lm_customer_existing_flag = 1
                AND month_roll = product_churn_month
            THEN 1 ELSE 0
        END AS lm_product_churn_flag,

        CASE
            WHEN l3m_customer_existing_flag = 1
                AND product_start_month_difference >= 3
                AND month_roll < product_churn_month
            THEN 1 ELSE 0
        END AS l3m_product_existing_flag,

        CASE
            WHEN l3m_customer_existing_flag = 1
                AND product_churn_month_difference >= 0
                AND product_churn_month_difference < 3
            THEN 1 ELSE 0
        END AS l3m_product_churn_flag,

        CASE
            WHEN ltm_customer_existing_flag = 1
                AND product_start_month_difference >= 12
                AND month_roll < product_churn_month
            THEN 1 ELSE 0
        END AS ltm_product_existing_flag,

        CASE
            WHEN ltm_customer_existing_flag = 1
                AND product_churn_month_difference >= 0
                AND product_churn_month_difference < 12
            THEN 1 ELSE 0
        END AS ltm_product_churn_flag,

        CASE
            WHEN ytd_customer_existing_flag = 1
                AND product_start_month_difference >= ytd_helper
                AND month_roll < product_churn_month
            THEN 1 ELSE 0
        END AS ytd_product_existing_flag,

        CASE
            WHEN ytd_customer_existing_flag = 1
                AND product_churn_month_difference >= 0
                AND product_churn_month_difference < ytd_helper
            THEN 1 ELSE 0
        END AS ytd_product_churn_flag

    FROM get_churn_month_difference
)

SELECT
    monthly_revenue_key AS customer_product_lifecycle_events_key,

    customer_level_1,
    customer_level_2,
    product_level_1,
    product_level_2,

    month_roll,
    revenue_type,

    lm_product_churn_flag,
    lm_product_existing_flag,

    l3m_product_churn_flag,
    l3m_product_existing_flag,

    ltm_product_churn_flag,
    ltm_product_existing_flag,

    ytd_product_churn_flag,
    ytd_product_existing_flag

FROM product_lifecycle_flags;
