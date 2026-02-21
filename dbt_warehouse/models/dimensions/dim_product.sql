
with products as (
    select * from {{ ref('stg_products') }}
),

final as (

    select
        -- surrogate key
        {{ dbt_utils.generate_surrogate_key(['product_id']) }} as product_sk,

        -- Natural key
        product_id,

        -- Attributes
        category,
        category_portuguese,

        -- Product details
        name_length,
        description_length,
        photos_count,

        -- Physical attributes
        weight_grams,
        length_cm,
        height_cm,
        width_cm,
        volume_cubic_cm,

        -- Size classification
        case
            when weight_grams < 500 then 'small'
            when weight_grams < 2000 then 'medium'
            when weight_grams < 10000 then 'large'
            else 'extra_large'
        end as size_category,

        -- Audit
        _ingested_at as loaded_at
        
    from products
)

select * from final