{{ 
    config(
        tags=['analysis']
        ) 
}}
 
/* This Stored Procedure calculates the join month, end month, and churn month for each customer based on their revenue records*/

SELECT
    
    {{ get_dimension_from_table('monthly_revenue', 'customer_level') }} 
    , MIN(month_roll)                                                 AS customer_join_month
    , MAX(month_roll)                                                 AS customer_end_month
    , DATEADD(MONTH, 1, MAX(month_roll))                              AS customer_churn_month

FROM {{ ref('monthly_revenue') }}
FROM {{ ref('monthly_revenue') }}
    FROM {{ ref('monthly_revenue') }}

WHERE
    arr <> 0.0
    AND revenue_type IN ('Recurring','Re-occurring')

GROUP BY 
    {{ get_dimension_from_table('monthly_revenue', 'customer_level') }} 

