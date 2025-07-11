
use HatchMsg
go

drop table if exists ServerMetrics
CREATE TABLE ServerMetrics (
    Timestamp DATETIME2,
    ServerName VARCHAR(50),
    CPUUsage DECIMAL(5,2),
    MemoryUsage DECIMAL(5,2),
    DiskIO INT
);

-- Insert hourly server metrics for last 30 days
WITH HourSeries AS (
    SELECT CAST('2025-06-08 00:00:00' AS DATETIME2) AS Timestamp
    UNION ALL
    SELECT DATEADD(HOUR, 1, Timestamp)
    FROM HourSeries
    WHERE Timestamp < '2025-07-08 00:00:00'
)
INSERT INTO ServerMetrics (Timestamp, ServerName, CPUUsage, MemoryUsage, DiskIO)
SELECT 
    h.Timestamp,
    'SERVER-' + CAST((ABS(CHECKSUM(NEWID())) % 3) + 1 AS VARCHAR(1)) AS ServerName,
    ROUND(20 + (30 * SIN(DATEPART(HOUR, h.Timestamp) * PI() / 12)) + (ABS(CHECKSUM(NEWID())) % 20), 2) AS CPUUsage,
    ROUND(40 + (20 * COS(DATEPART(HOUR, h.Timestamp) * PI() / 12)) + (ABS(CHECKSUM(NEWID())) % 15), 2) AS MemoryUsage,
    100 + (ABS(CHECKSUM(NEWID())) % 200) AS DiskIO
FROM HourSeries h
OPTION (MAXRECURSION 0);

-- Start Concepts

drop table if exists tempdb..#temp

select *
	,row_number() over(order by Timestamp) as read_order
	,lag(Timestamp, 1, null) over(order by Timestamp) as lag_Timestamp
	,lead(Timestamp, 1, null) over(order by Timestamp) as lead_Timestamp
	,lag(CPUUsage, 1, 0) over(order by Timestamp) as lag_CPUUsage
	,lead(CPUUsage, 1, null) over(order by Timestamp) as lead_CPUUsage
	--Running Avgs
	,avg(CPUUsage) over(order by Timestamp rows between 6 preceding and current row) as MovingCPUAvg
	,ntile(4) over(order by CPUUsage desc) as CPUTiers
	--,avg(CPUUsage) over(order by Timestamp range between 14400 preceding and current row) as MovingCPUAvgRange
into #temp
from HatchMsg.dbo.ServerMetrics

select top 100 *
from #temp
order by read_order


--------------------------
--Agg by Half Day
select 
	 datepart(hour, timestamp)%4 as DaySplit
	,avg(CPUUsage)
	,stdev(CPUUsage)
from HatchMsg.dbo.ServerMetrics
group by datepart(hour, timestamp)%4
order by 1



