
with source as (
  select * from {{ source('bronze', 'orders') }}
),

cleaned as (
  select
    order_id,
    customer_id,
    order_status,

    -- Parse timestamps
    cast(order_purchase_timestamp as timestamp) as order_purchased_at,
    cast(order_approved_at as timestamp) as order_approved_at,
    cast(order_delivered_carrier_date as timestamp) as order_shipped_at,
    cast(order_delivered_customer_date as timestamp) as order_delivered_at,
    cast(order_estimated_delivery_date as timestamp) as order_estimated_delivery_at,

    -- Calculate derived field
    date(cast(order_purchase_timestamp as timestamp)) as order_date,

    -- Metadata
    _ingested_at,
    _source_file 
  from source
  where 
    order_id is not null
  
)

select * from cleaned