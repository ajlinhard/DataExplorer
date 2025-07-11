
drop table if exists #temp_base
create table #temp_base
(
	ID int identity(1,1)
	,col1 varchar(max)
	,col2 char(4)
	,insert_timestamp datetime default(getdate())
	,update_timestamp datetime2 default(getdate())
	,updt_cnt int
	,avg_seconds_between numeric(10,4)
	,avg_diff as (datediff(second, insert_timestamp, update_timestamp))
)

drop table if exists #temp_action1
select col1 = 'Customer 1'
	,col2 = 'I'
into #temp_action1

select * from #temp_base

----------------------------------------------------
--Action 1
----------------------------------------------------
merge #temp_base as t
using #temp_action1 as s
on t.col1 = s.col1
when not matched by target
	then insert (col1, col2, updt_cnt)
		values(s.col1
		,s.col2
		,1
		)
when matched 
	then update
	set col2 = s.col2
		,updt_cnt = t.updt_cnt + 1;

select * from #temp_base

----------------------------------------------------
--Action 2
----------------------------------------------------
drop table if exists #temp_action2
select col1 = 'Customer 2'
	,col2 = 'I'
	,updt_cnt = 0
into #temp_action2

union

select col1 = 'Customer 1'
	, col2 = 'U'
	,updt_cnt = -1

waitfor delay '00:00:02'

raiserror('Executing Action 2', 0, 1) with nowait;

merge #temp_base as t
using #temp_action2 as s
on t.col1 = s.col1
when matched and (s.updt_cnt >= 0 or s.updt_cnt = -1)
	then update
		set col2 = s.col2
			,update_timestamp = getdate()
			,updt_cnt = t.updt_cnt + 1
			,avg_seconds_between = (isnull(t.avg_seconds_between,0) * t.updt_cnt) + datediff(second, t.update_timestamp, getdate()) / (t.updt_cnt)
when not matched by target
	then insert(col1, col2, updt_cnt)
		values (s.col1, s.col2, s.updt_cnt)
			;

select *
	,(avg_seconds_between * updt_cnt) + datediff(second, update_timestamp, getdate())
from #temp_base
