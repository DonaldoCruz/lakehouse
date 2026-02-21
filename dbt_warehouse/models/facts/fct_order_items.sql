
with order_items as (
    select * from {{ ref('stg_order_items') }}
),

orders as (
    select
        order_id,
        customer_id,
        order_status,
        order_date
    from {{ ref('stg_orders') }}
),

products as (
    select 
        product_id, 
        product_sk
    from {{ ref('dim_product') }}
),

sellers as (
    select
        seller_id,
        seller_sk
    from {{ ref('dim_seller') }}
),

customers as (
    select
        customer_id,
        customer_sk
    from {{ ref('dim_customer') }}
    where is_current = true
),

final as (
    select
        -- Surrogate keys
        p.product_sk,
        s.seller_sk,
        c.customer_sk,
        cast(date_format(o.order_date, '%Y%m%d') as integer) as order_date_sk,

        -- Degenerate dimensions
        oi.order_id,
        oi.order_item_id,

        -- Measures
        oi.price,
        oi.freight_value,
        oi.total_item_value,

        -- Item sequence
        oi.order_item_id as item_sequence,

        -- Shipping
        oi.shipping_limit_at,

        -- Order context
        o.order_status,

        --Audit
        current_timestamp as loaded_at
    from order_items oi
    inner join orders o on oi.order_id = o.order_id
    left join products p on oi.product_id = p.product_id
    left join sellers s on oi.seller_id = s.seller_id
    left join customers c on o.customer_id = c.customer_id
)

select * from final
