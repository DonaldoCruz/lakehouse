
with source as (
    select * from {{ source('bronze', 'products') }}
),
    
translations as (
    select * from {{ source('bronze', 'category_translation') }}
),

cleaned as (
    select
        p.product_id,

        -- Translate category to English
        coalesce(t.product_category_name_english, p.product_category_name, 'unknown') as category,
        p.product_category_name as category_portuguese,

        -- product dimensions
        cast(p.product_name_length as integer) as name_length,
        cast(p.product_description_length as integer) as description_length,
        cast(p.product_photos_qty as integer) as photos_count,
        
        -- physical attributes
        cast(p.product_weight_g as decimal(10, 2)) as weight_grams,
        cast(p.product_length_cm as decimal(10, 2)) as length_cm,
        cast(p.product_height_cm as decimal(10, 2)) as height_cm,
        cast(p.product_width_cm as decimal(10, 2)) as width_cm,
        
        -- Calculated: volume in cubic cm
        ( cast(p.product_length_cm as decimal(10, 2)) *
        cast(p.product_height_cm as decimal(10, 2)) *
        cast(p.product_width_cm as decimal(10, 2)) ) as volume_cubic_cm,
        
        p._ingested_at,
        p._source_file

    from source p
    left join translations t
        on p.product_category_name = t.product_category_name
    where p.product_id is not null
)

select * from cleaned