
with source as (
    select * from {{ source('bronze', 'customers') }}
),

cleaned as (
    select
        customer_id,
        customer_unique_id,

        -- 
        trim(cast(customer_zip_code_prefix as varchar)) as zip_code_prefix,
        trim(customer_city) as city,
        trim(customer_state) as state,

        _ingested_at,
        _source_file 
    from 
        source
    where
        customer_id is not null
),

-- Deduplicate on customer_id (keep first occurrence)
deduplicated as (
    select 
        *,
        row_number() over (partition by customer_id order by _ingested_at) as rn
    from cleaned
)

select
    customer_id,
    customer_unique_id,
    zip_code_prefix,
    city,
    state,
    _ingested_at,
    _source_file
from deduplicated
where rn = 1

