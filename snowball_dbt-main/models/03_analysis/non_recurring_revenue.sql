WITH 

revenue AS (

    SELECT

        monthly_revenue_key
        , {{ get_dimension_from_table('monthly_revenue', 'customer', 'm') }} 
        , {{ get_dimension_from_table('monthly_revenue', 'product', 'm') }} 
        , {{ get_dimension_from_table('monthly_revenue', 'entity', 'm') }} 
        , {{ get_dimension_from_table('monthly_revenue', 'other', 'm') }} 
        , month_roll
        , arr
        , mrr
        , volume
        , ytd_helper
        , revenue_type

    FROM {{ ref('monthly_revenue') }} AS m

    WHERE revenue_type IN ('Non-Recurring')
        
),

churn_month AS (

    SELECT

        customer_level_1,
        -- customer_level_2,
        MIN(month_roll)                      AS customer_join_month,
        MAX(month_roll)                      AS customer_end_month,
        DATEADD(MONTH, 1, MAX(month_roll))   AS customer_churn_month 

    FROM revenue
    WHERE
        mrr <> 0.00
        AND revenue_type = 'Non-Recurring'

    GROUP BY 
        customer_level_1
        -- ,customer_level_2

),

product_churn_month AS (

    SELECT

        customer_level_1,
        -- customer_level_2,
        product_level_1,
        -- product_level_2,
        MIN(month_roll)                      AS product_start_month,
        MAX(month_roll)                      AS product_end_month,
        DATEADD(MONTH, 1, MAX(month_roll))   AS product_churn_month 
        
    FROM
        revenue
    WHERE mrr <> 0
        AND revenue_type = 'Non-Recurring'

    GROUP BY
        customer_level_1,
        -- customer_level_2,
        product_level_1
        -- product_level_2

),

non_recurring_revenue AS (

    SELECT

        monthly_revenue_key        AS revenue_key
        , {{ get_dimension_from_table('monthly_revenue', 'customer', 'r') }} 
        , {{ get_dimension_from_table('monthly_revenue', 'product', 'r') }} 
        , {{ get_dimension_from_table('monthly_revenue', 'entity', 'r') }} 
        , {{ get_dimension_from_table('monthly_revenue', 'other', 'r') }} 
        , month_roll,
        arr,
        mrr,
        customer_join_month,
        product_start_month,
        COALESCE(LAG(arr, 12) OVER (PARTITION BY monthly_revenue_key ORDER BY month_roll), 0)      AS arr_ltm,
        CASE
            WHEN DATEDIFF(MONTH, c.customer_join_month, month_roll) < 12
                AND month_roll >= customer_join_month
            THEN arr 
            ELSE 0 
        END AS new_customer,
        CASE
            WHEN DATEDIFF(MONTH, pc.product_start_month, month_roll) < 12
                AND month_roll >= product_start_month
                AND DATEDIFF(MONTH, c.customer_join_month, month_roll) >= 12
            THEN arr 
            ELSE 0 
        END AS cross_sell,
        revenue_type

    FROM revenue AS r

    INNER JOIN 
        churn_month AS c
    ON r.customer_level_1 = c.customer_level_1

    INNER JOIN 
        product_churn_month AS pc 
    ON r.customer_level_1 = pc.customer_level_1
        AND r.product_level_1 = pc.product_level_1

)

SELECT * FROM non_recurring_revenue
