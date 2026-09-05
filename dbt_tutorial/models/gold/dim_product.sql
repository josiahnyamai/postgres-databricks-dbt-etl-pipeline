WITH product_dimension AS (

    -- Unknown Product
    SELECT
        CAST('-1' AS STRING)                     AS product_sk,
        -1                                       AS product_id,
        'UNKNOWN'                                AS product_name,
        'UNKNOWN'                                AS category,
        'UNKNOWN'                                AS brand,
        CAST(0.00 AS DECIMAL(18,2))              AS price,
        CAST('1900-01-01 00:00:00' AS TIMESTAMP) AS valid_from,
        CAST('9999-12-31 23:59:59' AS TIMESTAMP) AS valid_to,
        TRUE                                     AS is_current,
        current_timestamp()                      AS row_created_ts,
        'SYSTEM'                                 AS source_system

    UNION ALL

    -- Not Applicable Product
    SELECT
        CAST('-2' AS STRING)                     AS product_sk,
        -2                                       AS product_id,
        'Not Applicable'                         AS product_name,
        'Not Applicable'                         AS category,
        'Not Applicable'                         AS brand,
        CAST(0.00 AS DECIMAL(18,2))              AS price,
        CAST('1900-01-01 00:00:00' AS TIMESTAMP) AS valid_from,
        CAST('9999-12-31 23:59:59' AS TIMESTAMP) AS valid_to,
        TRUE                                     AS is_current,
        current_timestamp()                      AS row_created_ts,
        'SYSTEM'                                 AS source_system

    UNION ALL

    -- Actual Product Records
    SELECT
        {{ dbt_utils.generate_surrogate_key(['product_id', 'dbt_valid_from']) }} AS product_sk,
        product_id,
        product_name,
        category,
        brand,
        price,
        dbt_valid_from AS valid_from,
        COALESCE(
            dbt_valid_to,
            CAST('9999-12-31 23:59:59' AS TIMESTAMP)
        ) AS valid_to,

        CASE
            WHEN dbt_valid_to IS NULL THEN TRUE
            ELSE FALSE
        END AS is_current,

        current_timestamp() AS row_created_ts,

        source_system

    FROM {{ ref('dim_product_snapshot') }}
)

SELECT *
FROM product_dimension