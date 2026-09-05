{% snapshot dim_store_snapshot %}

{{
    config(
        target_catalog='gold_layer',
        target_schema='dimensional_model_dev',
        unique_key='store_id',
        strategy='timestamp',
        updated_at='updated_timestamp'
    )
}}

SELECT
    store_id,
    store_name,
    city,
    province,
    country,
    updated_timestamp,
    source_system

FROM {{ source('walmart_bronze', 'stores') }}

{% endsnapshot %}