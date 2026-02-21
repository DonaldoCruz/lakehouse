
with date_spine as (
    {{
        dbt_utils.date_spine(
            datepart="day",
            start_date="cast('2016-01-01' as date)",
            end_date="cast('2019-12-31' as date)"
        )
    }}
),

final as (
    select 
        -- surrogate key (YYYYMMDD format)
        cast(date_format(date_day, '%Y%m%d') as integer) as date_sk,

        -- Date value
        date_day as date_actual,

        -- Date parts
        year(date_day) as year,
        quarter(date_day) as quarter,
        month(date_day) as month,
        day(date_day) as day,
        day_of_week(date_day) as day_of_week,
        day_of_year(date_day) as day_of_year,
        week_of_year(date_day) as week_of_year,

        -- Names
        date_format(date_day, '%W') as day_name,
        date_format(date_day, '%M') as month_name,
        date_format(date_day, '%b') as month_name_short,

        -- Flags
        case
            when day_of_week(date_day) in (1, 7) then true
            else false
        end as is_weekend,

        -- Fiscal calendar (assuming fiscal year = calendar year)
        year(date_day) as fiscal_year,
        quarter(date_day) as fiscal_quarter,

        -- Relative flags (useful for filtering)
        case 
            when date_day = current_date then true
            else false
        end as is_today,
        case 
            when date_day = current_date - interval '1' day then true
            else false
        end as is_yesterday
    
    from date_spine

)

select * from final