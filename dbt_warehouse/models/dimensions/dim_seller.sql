
with sellers as (
    select * from {{ ref('stg_sellers') }}
),

-- Get seller metrics
seller_metrics as (
    select
        seller_id,
        count(distinct order_id) as total_orders,
        count(*) as total_items_sold,
        sum(price) as total_revenue,
        avg(price) as avg_item_price
    from {{ ref('stg_order_items') }}
    group by seller_id
),

final as (
    select 

        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['s.seller_id']) }} as seller_sk,

        -- Natural key
        s.seller_id,

        -- Location
        s.zip_code_prefix,
        s.city,
        s.state,

        -- Performance metrics (Type 1 - always current)
        coalesce(m.total_orders, 0) as total_orders,
        coalesce(m.total_items_sold, 0) as total_items_sold,
        coalesce(m.total_revenue, 0) as total_revenue,
        coalesce(m.avg_item_price, 0) as avg_item_price,

        -- seller tier based on revenue
        case
            when coalesce(m.total_revenue, 0) >= 100000 then 'platinum'
            when coalesce(m.total_revenue, 0) >= 50000 then 'gold'
            when coalesce(m.total_revenue, 0) >= 10000 then 'silver'
            else 'bronze'
        end as seller_tier

    from sellers s
    left join seller_metrics m on s.seller_id = m.seller_id
        
)

select * from final