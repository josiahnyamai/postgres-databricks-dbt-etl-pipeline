WITH store_dimension AS (

    -- Unknown Store
    SELECT
        CAST('-1' AS STRING)                     AS store_sk,
        -1                                       AS store_id,
        'UNKNOWN'                                AS store_name,
        'UNKNOWN'                                AS city,
        'UNKNOWN'                                AS province,
        'UNKNOWN'                                AS country,
        CAST('1900-01-01 00:00:00' AS TIMESTAMP) AS valid_from,
        CAST('9999-12-31 23:59:59' AS TIMESTAMP) AS valid_to,
        TRUE                                     AS is_current,
        current_timestamp()                      AS row_created_ts,
        'SYSTEM'                                 AS source_system

    UNION ALL

    -- Not Applicable Store
    SELECT
        CAST('-2' AS STRING)                     AS store_sk,
        -2                                       AS store_id,
        'Not Applicable'                         AS store_name,
        'Not Applicable'                         AS city,
        'Not Applicable'                         AS province,
        'Not Applicable'                         AS country,
        CAST('1900-01-01 00:00:00' AS TIMESTAMP) AS valid_from,
        CAST('9999-12-31 23:59:59' AS TIMESTAMP) AS valid_to,
        TRUE                                     AS is_current,
        current_timestamp()                      AS row_created_ts,
        'SYSTEM'                                 AS source_system

    UNION ALL

    -- Actual store records from SCD2 snapshot
    SELECT
        {{ dbt_utils.generate_surrogate_key(['store_id','dbt_valid_from']) }} AS store_sk,
        store_id,
        store_name,
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

        current_timestamp() AS row_created_ts,

        source_system

    FROM {{ ref('dim_store_snapshot') }}
)

SELECT *
FROM store_dimension