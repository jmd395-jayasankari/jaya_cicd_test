WITH get_product_start_end_month AS (

    SELECT DISTINCT

        customer_level_1,
        customer_level_2,
        product_level_1,
        product_level_2,
        entity_level_1,
        entity_level_2,
        other_level_1,
        other_level_2,

        MIN(month_roll) OVER (
            PARTITION BY 
                customer_level_1,
                customer_level_2,
                product_level_1,
                product_level_2
        ) AS product_start_month,

        MAX(month_roll) OVER (
            PARTITION BY 
                customer_level_1,
                customer_level_2,
                product_level_1,
                product_level_2
        ) AS product_end_month,

        DATEADD(
            MONTH,
            1,
            MAX(month_roll) OVER (
                PARTITION BY 
                    customer_level_1,
                    customer_level_2,
                    product_level_1,
                    product_level_2
            )
        ) AS product_churn_month

    FROM monthly_revenue

    WHERE arr <> 0
      AND revenue_type IN ('Recurring', 'Re-occurring')

)

SELECT DISTINCT

    customer_level_1,
    customer_level_2,
    product_level_1,
    product_level_2,
    entity_level_1,
    entity_level_2,
    other_level_1,
    other_level_2,

    product_start_month,
    product_end_month,
    product_churn_month

FROM get_product_start_end_month;
