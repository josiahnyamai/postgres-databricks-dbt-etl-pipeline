{% snapshot dim_customer_snapshot %}

{{
    config(
        target_catalog='gold_layer',
        target_schema='dimensional_model_dev',
        unique_key='customer_id',
        strategy='timestamp',
        updated_at='updated_timestamp'
    )
}}

SELECT
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    city,
    province,
    country,
    updated_timestamp,
    source_system

FROM {{ source('walmart_bronze', 'customers') }}

{% endsnapshot %}