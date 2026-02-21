
with source as (
  select * from {{source('bronze', 'order_items') }}
),

cleaned as (
    select 
        order_id,
        order_item_id,
        product_id,
        seller_id,

        -- Clean numberic fields
        cast(price as decimal(18, 2)) as price,
        cast(freight_value as decimal(18, 2)) as freight_value,

        -- Calculated field
        cast(price as decimal(18, 2)) + cast(freight_value as decimal(18, 2)) as total_item_value,

        -- Cleaning datetimes
        cast(shipping_limit_date as timestamp) as shipping_limit_at,

        -- Metadata
        _ingested_at,
        _source_file
    from source
    where
        order_id is not null
        and product_id is not null

)
select * from cleaned