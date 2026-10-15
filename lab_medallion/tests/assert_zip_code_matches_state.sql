{{ config(severity='warn') }}

-- The zip code must fall in one of the ranges of the state
select u.user_id, u.state, u.zip_code
from {{ ref('stg_users') }} u
where not exists (
    select 1
    from {{ ref('zip_ranges') }} r
    where r.state = u.state
      and u.zip_code between r.zip_min and r.zip_max
)
