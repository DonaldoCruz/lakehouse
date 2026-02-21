
with orders as (
    select *
    from {{ ref('fct_orders') }}
    where order_status = 'delivered'
),

daily as (
    select
        order_date_sk,

        -- Order counts
        count(*) as order_count,
        count(distinct customer_sk) as unique_customers,

        -- Revenue metrics
        sum(order_total) as total_revenue,
        sum(subtotal) as total_subtotal,
        sum(freight_total) as total_freight,
        avg(order_total) as avg_order_value,
        
        -- Item metrics
        sum(item_count) as total_items,
        avg(item_count) as avg_items_per_order,
        
        -- Delivery metrics
        avg(days_to_deliver) as avg_days_to_deliver,
        sum(case when delivered_on_time then 1 else 0 end) as on_time_deliveries,
        cast(sum(case when delivered_on_time then 1 else 0 end) as decimal(10,4)) / nullif(count(*), 0) as on_time_rate,
        
        -- Review metrics
        avg(review_score) as avg_review_score,
        count(case when review_sentiment = 'positive' then 1 end) as positive_reviews,
        count(case when review_sentiment = 'negative' then 1 end) as negative_reviews,
        
        -- Audit
        current_timestamp as refreshed_at
    
    from orders
    group by order_date_sk
)
    
select
    d.*,
    dd.date_actual,
    dd.year,
    dd.month,
    dd.month_name,
    dd.day_of_week,
    dd.day_name,
    dd.is_weekend
from daily d
left join {{ ref('dim_date') }} dd on d.order_date_sk = dd.date_sk