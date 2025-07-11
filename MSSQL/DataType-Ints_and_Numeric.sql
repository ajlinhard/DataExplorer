

select parse('123' as int)
	,cast('123' as int)
	,cast('123' as numeric(10,2))
	,cast(123 as varchar(max))
	,cast(123 as char(3))


select parse('123.' as int)
select cast('123.' as int)

---------------------------------
--Nulls During Aggregations
---------------------------------
;with ts_avg as
(
select num = 4
union
select null
union
select 2
)
select avg(num) as avg_WO_nulls
	,avg(isnull(num,0)) as avg_W_nulls
from ts_avg
