{% snapshot dim_product_snapshot %}

{{
    config(
        target_catalog='gold_layer',
        target_schema='dimensional_model_dev',
        unique_key='product_id',
        strategy='timestamp',
        updated_at='updated_timestamp'
    )
}}

SELECT
    product_id,
    product_name,
    category,
    brand,
    price,
    updated_timestamp,
    source_system

FROM {{ source('walmart_bronze', 'products') }}

{% endsnapshot %}