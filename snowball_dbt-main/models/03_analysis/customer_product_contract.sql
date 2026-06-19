{{ 
    config(
        tags=['analysis']
        ) 
}}
 
 /* This stored procedure calculates the start, end, and anticipated churn months for each customer-product pair based on recurring monthly_revenue data and product details*/

WITH get_product_start_end_month AS (

    SELECT

        {{ get_dimension_from_table('monthly_revenue', 'customer_level') }} 
        , {{ get_dimension_from_table('monthly_revenue', 'product_level') }}   
        , MIN(month_roll) OVER (PARTITION BY  {{ get_dimension_from_table('monthly_revenue', 'customer_level') }} , {{ get_dimension_from_table('monthly_revenue', 'product_level') }} )                 AS product_start_month
        , MAX(month_roll) OVER (PARTITION BY  {{ get_dimension_from_table('monthly_revenue', 'customer_level') }} , {{ get_dimension_from_table('monthly_revenue', 'product_level') }} )                 AS product_end_month
        , DATEADD(MONTH, 1, MAX(month_roll) OVER (PARTITION BY customer_level_1, product_level_1))                                                                                                       AS product_churn_month
    
    FROM {{ ref('monthly_revenue') }} AS r
    WHERE
        arr <> 0
        AND revenue_type IN ('Recurring','Re-occurring')
     WHERE
        arr <> 0
        AND revenue_type IN ('Recurring','Re-occurring')

)

SELECT
    
    {{ get_dimension_from_table('monthly_revenue', 'customer_level') }} 
    , {{ get_dimension_from_table('monthly_revenue', 'product_level') }}   
    , product_start_month
    , product_end_month
    , product_churn_month

FROM 
    get_product_start_end_month

GROUP BY
    {{ get_dimension_from_table('monthly_revenue', 'customer_level') }} 
    , {{ get_dimension_from_table('monthly_revenue', 'product_level') }}   
    , product_start_month
    , product_end_month
    , product_churn_month
