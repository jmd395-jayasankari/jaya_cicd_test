{% macro get_data_from_table(source_name, table_name) -%}
 
    --CTE for data type converstion and take required columns
    {{ table_name }} AS (

        {% set metadata_file = 'column_mapping' %}
 
        {% set source_columns = get_required_columns(metadata_file, table_name) %}
       
        {% set relation = source(source_name.lower(), table_name.lower()) %}
 
        {% set cols = adapter.get_columns_in_relation(relation) | map(attribute="name") | map('upper') | list %}
 
        SELECT
 
            {% for source_column in source_columns %}
 
                {% if source_column[3] | lower == 'float' or source_column[3] | lower == 'double' %}

                    COALESCE(NULLIF(TRIM({{ source_column[1] }}), ''), 0)::{{ source_column[3] }}    AS {{ source_column[2] }}
               
                {%- else -%}
                    -- NULLIF(TRIM({{ source_column[1] }}), '')::{{ source_column[3] }}                 AS {{ source_column[2] }}
                    NULLIF(REGEXP_REPLACE(TRIM({{ source_column[1] }}), '[\r\n]+', ''), '')::{{ source_column[3] }} AS {{ source_column[2] }}
                {%- endif -%}
 
                {%- if not loop.last -%} , {%- endif -%}  
 
            {% endfor %}
            
            FROM {{ source(source_name.lower(), table_name.lower()) }}

     ),
 
{%- endmacro -%}


{% macro get_required_columns(source_file, table_name) -%}
 
    {% set sql_statement %}
   
        SELECT
 
            source_table 
            , source_column
            , mapped_column
            , datatype
 
        FROM {{ ref(source_file) }}
        WHERE
            LOWER(source_table) = '{{ table_name.lower() }}'
           
    {% endset %}
 
    {% set results = run_query(sql_statement) %}
 
    {% if execute %}
        {% do return(results) %}
    {% endif %}
   
{% endmacro %}