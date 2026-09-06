WITH order_item_base AS (

    SELECT
        oi.order_item_id,
        oi.order_id,
        oi.product_id,
        oi.quantity,
        oi.unit_price,
        oi.line_amount,

        o.customer_id,
        o.store_id,
        o.order_timestamp,
        o.payment_method,
        o.order_status,
        o.total_amount,

        oi.updated_timestamp AS updated_timestamp,
        oi.source_system

    FROM {{ source('walmart_bronze', 'order_items') }} oi

    INNER JOIN {{ source('walmart_bronze', 'orders') }} o
        ON oi.order_id = o.order_id
    
    {% if is_incremental() %}

    WHERE oi.updated_timestamp > (
        SELECT COALESCE(MAX(updated_timestamp), CAST('1900-01-01' AS TIMESTAMP))
        FROM {{ this }}
    )

    {% endif %}

),

fact AS (

    SELECT
        oi.order_item_id,
        oi.order_id,

        -- Dimension surrogate keys
        COALESCE(c.customer_sk, '-1') AS customer_sk,
        COALESCE(p.product_sk, '-1') AS product_sk,
        COALESCE(s.store_sk, '-1') AS store_sk,

        -- Date dimension
        COALESCE(d.date_key, '-1') AS order_date_sk,

        -- Order timestamp and extracted time
        DATE_FORMAT(oi.order_timestamp, 'HH:mm:ss') AS order_time_stamp,

        -- Measures
        oi.quantity,
        oi.unit_price,
        oi.line_amount,

        -- Order attributes
        oi.payment_method,
        oi.order_status,

        -- Audit columns
        oi.updated_timestamp,
        CURRENT_TIMESTAMP() AS row_created_ts,
        oi.source_system

    FROM order_item_base oi

    LEFT JOIN {{ ref('dim_customer') }} c
        ON oi.customer_id = c.customer_id
        AND oi.order_timestamp >= c.valid_from
        AND oi.order_timestamp < c.valid_to

    LEFT JOIN {{ ref('dim_product') }} p
        ON oi.product_id = p.product_id
        AND oi.order_timestamp >= p.valid_from
        AND oi.order_timestamp < p.valid_to

    LEFT JOIN {{ ref('dim_store') }} s
        ON oi.store_id = s.store_id
        AND oi.order_timestamp >= s.valid_from
        AND oi.order_timestamp < s.valid_to

    LEFT JOIN {{ ref('dim_date') }} d
        ON CAST(oi.order_timestamp AS DATE) = d.calendar_date

)

SELECT *
FROM fact
