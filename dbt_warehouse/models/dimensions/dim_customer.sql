
with snapshot as (
    select * from {{ ref('snap_customer') }}
),

final as (
    select  

        {{ dbt_utils.generate_surrogate_key(['customer_id', 'dbt_valid_from']) }} as customer_sk,

        -- Natural key
        customer_id,
        customer_unique_id,

        -- Location attributes
        zip_code_prefix,
        city,
        state,

        -- SCD Type 2 metadata
        dbt_valid_from as valid_from,
        dbt_valid_to as valid_to,
        case 
            when dbt_valid_to is null then true 
            else false 
        end as is_current,

        -- Audit
        dbt_updated_at as updated_at

    from snapshot
)
    
select * from final