SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_id', 'dbt_valid_from']) }}  AS customer_sk,
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    city,
    province,
    country,        
    dbt_valid_from AS valid_from,

    COALESCE(
        dbt_valid_to,
        CAST('9999-12-31 23:59:59' AS TIMESTAMP)
    ) AS valid_to,

    CASE
        WHEN dbt_valid_to IS NULL THEN TRUE
        ELSE FALSE
    END AS is_current,

    source_system

FROM {{ref('dim_customer_snapshot')}}