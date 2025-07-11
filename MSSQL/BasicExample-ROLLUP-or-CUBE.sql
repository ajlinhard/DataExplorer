

create table #temp_data
(
	trans_id int identity(1,1)
	,region varchar(20) not null
	,category varchar(30) null default('Clothing')
	,[product] varchar(100)
	,sales numeric(7,2) not null
	constraint sales_pos check (sales >= 0.0)
)


insert into #temp_data
values
    ('North', 'Electronics', 'Laptop', 1500), -- 1
    ('North', 'Electronics', 'Phone', 800),
    ('North', 'Clothing', 'Shirt', 50),
    ('North', 'Clothing', 'Pants', 80),
    ('South', 'Electronics', 'Laptop', 1600),
    ('South', 'Electronics', 'Tablet', 400),
    ('South', 'Clothing', 'Shirt', 45),
    ('South', 'Clothing', 'Dress', 120),
    ('West', 'Electronics', 'Phone', 750),
    ('West', 'Electronics', 'Laptop', 1550),
    ('West', 'Clothing', 'Pants', 85),
    ('East', 'Electronics', 'Tablet', 420),
    ('East', 'Clothing', 'Shirt', 55),
    ('East', 'Clothing', 'Dress', 110) -- 14


select region, category, [product]
	,count(1) as tot_sales
	,avg(sales) as avg_sale_price
	,count(distinct sales) as dist_prices
from #temp_data
group by rollup(region, category, [product])
order by region, category, [product]


select region, category, [product]
	,count(1) as tot_sales
	,avg(sales) as avg_sale_price
	,count(distinct sales) as dist_prices
from #temp_data
group by cube(region, category, [product])
order by region, category, [product]