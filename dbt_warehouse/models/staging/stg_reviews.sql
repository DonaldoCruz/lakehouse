
with source as (
    select * from {{ source('bronze', 'reviews') }}
),

cleaned as (
    select
        review_id,
        order_id,

        cast(review_score as integer) as review_score,

        -- categorize review scores
        case 
            when cast(review_score as integer) >= 4 then 'positive'
            when cast(review_score as integer) = 3 then 'neutral'
            else 'negative'
        end as review_sentiment,

        -- Check if review has comment
        case
            when review_comment_message is not null and trim(review_comment_message) != ''
            then true
            else false
        end as has_comment,
        
        cast(review_creation_date as timestamp) as review_created_at,
        cast(review_answer_timestamp as timestamp) as review_answered_at,

        _ingested_at,
        _source_file

    from source
    where
        review_id is not null
        and order_id is not null
)
    
select * from cleaned
