WITH date_dimension AS (

    -- Unknown
    SELECT
        -1                 AS date_key,
        DATE('9999-12-31') AS calendar_date,
        -1                 AS day_of_month,
        -1                 AS day_of_week,
        'UNKNOWN'          AS day_name,
        -1                 AS day_of_year,
        -1                 AS week_of_year,
        -1                 AS month,
        'UNKNOWN'          AS month_name,
        -1                 AS quarter,
        -1                 AS year,
        FALSE              AS is_weekend,
        FALSE              AS is_month_end,
        FALSE              AS is_quarter_end,
        FALSE              AS is_year_end

    UNION ALL

    -- Not Applicable
    SELECT
        -2                 AS date_key,
        DATE('9999-12-31') AS calendar_date,
        -2                 AS day_of_month,
        -2                 AS day_of_week,
        'Not Applicable'   AS day_name,
        -2                 AS day_of_year,
        -2                 AS week_of_year,
        -2                 AS month,
        'Not Applicable'   AS month_name,
        -2                 AS quarter,
        -2                 AS year,
        FALSE              AS is_weekend,
        FALSE              AS is_month_end,
        FALSE              AS is_quarter_end,
        FALSE              AS is_year_end

    UNION ALL

    -- Calendar dates
    SELECT
        CAST(date_format(d, 'yyyyMMdd') AS INT) AS date_key,
        d                                       AS calendar_date,
        day(d)                                  AS day_of_month,
        dayofweek(d)                            AS day_of_week,
        date_format(d, 'EEEE')                  AS day_name,
        dayofyear(d)                            AS day_of_year,
        weekofyear(d)                           AS week_of_year,
        month(d)                                AS month,
        date_format(d, 'MMMM')                  AS month_name,
        quarter(d)                              AS quarter,
        year(d)                                 AS year,

        dayofweek(d) IN (1, 7)                  AS is_weekend,

        d = last_day(d)                         AS is_month_end,

        month(d) IN (3, 6, 9, 12)
            AND d = last_day(d)                 AS is_quarter_end,

        month(d) = 12
            AND day(d) = 31                     AS is_year_end

    FROM (
        SELECT explode(
            sequence(
                DATE('2010-01-01'),
                DATE('2050-12-31'),
                INTERVAL 1 DAY
            )
        ) AS d
    )
)

SELECT *
FROM date_dimension