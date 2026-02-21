
/*
    Order fact table - grain is one row per order.

    Contains:
    -   Foreign keys to dimensions
    -   Degenerate dimensions
    -   Measures
*/
with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select
        order_id,
        count(*) as item_count,
        sum(price) as subtotal,
        sum(freight_value) as freight_total,
        sum(total_item_value) as order_total,
        count(distinct seller_id) as seller_count,
        count(distinct product_id) as unique_products
    from {{ ref('stg_order_items') }}
    group by order_id
),

payments as (
    select
        order_id,
        sum(cast(payment_value as decimal(10, 2))) as payment_total,
        count(*) as payment_count,
        max(payment_installments) as max_installments
    from {{ source('bronze', 'payments') }}
    group by order_id
),

reviews as (
    select
        order_id,
        review_score,
        review_sentiment,
        has_comment
    from {{ ref('stg_reviews') }}
),

customers as (
    select customer_id, customer_sk
    from {{ ref('dim_customer') }}
    where is_current = true
),

final as (
    select
        c.customer_sk,
        cast(date_format(o.order_date, '%Y%m%d') as integer) as order_date_sk,

        -- Degenerate dimension
        o.order_id,

        -- order attributes
        o.order_status,
        
        -- Timestamps
        o.order_purchased_at,
        o.order_approved_at,
        o.order_shipped_at,
        o.order_delivered_at,
        
        -- Delivery metrics
        date_diff('day', o.order_purchased_at, o.order_delivered_at) as days_to_deliver,
        date_diff('day', o.order_purchased_at, o.order_shipped_at) as days_to_ship,

        case
            when o.order_delivered_at <= o.order_estimated_delivery_at then true
            else false
        end as delivered_on_time,
        
        -- Order measures
        coalesce(oi.item_count, 0) as item_count,
        coalesce(oi.subtotal, 0) as subtotal,
        coalesce(oi.freight_total, 0) as freight_total,
        coalesce(oi.order_total, 0) as order_total,
        coalesce(oi.seller_count, 0) as seller_count,
        coalesce(oi.unique_products, 0) as unique_products,
    

        -- Payment measures
        coalesce(p.payment_total, 0) as payment_total,
        coalesce(p.payment_count, 0) as payment_count,
        coalesce(p.max_installments, 0) as max_installments,
    
        -- Review measures
        r.review_score,
        r.review_sentiment,
        coalesce(r.has_comment, false) as has_review_comment,
    
        -- Audit
        current_timestamp as loaded_at
    
    from orders o
    left join order_items oi on o.order_id = oi.order_id
    left join payments p on o.order_id = p.order_id
    left join reviews r on o.order_id = r.order_id
    left join customers c on o.customer_id = c.customer_id
)

select * from final