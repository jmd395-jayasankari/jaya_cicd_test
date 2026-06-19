WITH filtered_revenue AS (

    SELECT
        customer_level_1,
        customer_level_2,
        customer_level_3,

        month_roll,
        arr,
        revenue_type

    FROM monthly_revenue

    WHERE arr <> 0.0
      AND revenue_type IN ('Recurring', 'Re-occurring')
)

SELECT

    customer_level_1,
    customer_level_2,
    customer_level_3,

    MIN(month_roll) AS customer_join_month,
    MAX(month_roll) AS customer_end_month,
    DATEADD(MONTH, 1, MAX(month_roll)) AS customer_churn_month

FROM filtered_revenue

GROUP BY
    customer_level_1,
    customer_level_2,
    customer_level_3;
