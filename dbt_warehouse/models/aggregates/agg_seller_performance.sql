
with items as (
    select * from {{ ref('fct_order_items') }}
),

orders as (
    select * from {{ ref('fct_orders') }}
),

seller_items as (
    select
        i.seller_sk,
        
        -- Volume metrics
        count(*) as items_sold,
        count(distinct i.order_id) as orders_fulfilled,
        
        -- Revenue metrics
        sum(i.price) as total_revenue,
        sum(i.freight_value) as total_freight,
        avg(i.price) as avg_item_price,
        
        -- Product diversity
        count(distinct i.product_sk) as unique_products
    from items i
    group by i.seller_sk
),

seller_reviews as (
    select
        i.seller_sk,
        avg(o.review_score) as avg_review_score,
        count(case when o.review_sentiment = 'positive' then 1 end) as positive_reviews,
        count(case when o.review_sentiment = 'negative' then 1 end) as negative_reviews
    from items i
    inner join orders o on i.order_id = o.order_id
    where o.review_score is not null
    group by i.seller_sk
),

final as (
    select
        si.seller_sk,
        s.seller_id,
        s.city as seller_city,
        s.state as seller_state,
        s.seller_tier,
        
        -- Volume
        si.items_sold,
        si.orders_fulfilled,
        si.unique_products,
        
        -- Revenue
        si.total_revenue,
        si.total_freight,
        si.avg_item_price,
        
        -- Avg items per order
        cast(si.items_sold as decimal(10,2)) / nullif(si.orders_fulfilled, 0) as avg_items_per_order,
        
        -- Reviews
        sr.avg_review_score,
        sr.positive_reviews,
        sr.negative_reviews,
        
        -- Audit
        current_timestamp as refreshed_at
        
    from seller_items si
    left join {{ ref('dim_seller') }} s on si.seller_sk = s.seller_sk
    left join seller_reviews sr on si.seller_sk = sr.seller_sk
)

select * from final