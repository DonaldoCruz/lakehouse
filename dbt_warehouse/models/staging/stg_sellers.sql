
with source as (
    select * from {{ source('bronze', 'sellers') }}
),

cleaned as (
    select 
        seller_id,
        trim(cast(seller_zip_code_prefix as varchar)) as zip_code_prefix,
        trim(lower(seller_city)) as city,
        trim(upper(seller_state)) as state,
    
        _ingested_at,
        _source_file
    from source
    where
        seller_id is not null
)

select * from cleaned
