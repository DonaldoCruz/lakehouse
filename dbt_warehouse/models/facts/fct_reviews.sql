
with reviews as (
    select * from {{ ref('stg_reviews') }}
),

orders as (
    select 
        order_id,
        customer_id,
        order_date
    from {{ ref('stg_orders') }}
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
        c.customer_sk,
        cast(date_format(o.order_date, '%Y%m%d') as integer) as order_date_sk,
        cast(date_format(r.review_created_at, '%Y%m%d') as integer) as review_date_sk,
        
        -- Degenerate dimensions
        r.review_id,
        r.order_id,

        -- Measures
        r.review_score,

        -- Attributes
        r.review_sentiment,
        r.has_comment,

        -- Response time
        date_diff('hour', r.review_created_at, r.review_answered_at) as hours_to_respond,
        
        -- Timestamps
        r.review_created_at,
        r.review_answered_at,

        -- Audit
        current_timestamp as loaded_at

    from reviews r
    left join orders o on r.order_id = o.order_id
    left join customers c on o.customer_id = c.customer_id
)

select * from final