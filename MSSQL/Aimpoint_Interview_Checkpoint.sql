-- Avoid using keyboard shortcuts such as F5 or CTRL/CMD+R to run your code as this may cause the browser to refresh and your work to be lost.

--Tables
	--world_happiness_index_2015
	--world_happiness_index_2016
	--world_happiness_index_2017
	--world_happiness_index_2018
	--world_happiness_index_2019
   
-- Columns
  -- country
  -- ,region
  -- ,happiness_rank
  -- ,happiness_score
  -- ,economy_gdp_per_capita
  -- ,family
  -- ,health_life_expectancy
  -- ,freedom
  -- ,trust_government_corruption
  -- ,generosity
  -- ,dystopia_residual
  -- ,perceptions_of_corruption

-------------------------------------
-- Task 1 (Part 1)
-------------------------------------

-- Write SQL here, including comments explaining your thought process:
--TO DO:
  --Combine all the data with union alls, 
  --I need to get the correct region for each country in, 
  	--best approach is via a CTE that is a distinct list to join
    --Add 2016 region if time to test for duplicates. If no time note the enhancement
  --Establish the same order for all columns to avoid mismatched data.
  	-- This is particularly likely since most columns are float.
  --Look for additional columns in each year table.
  --Establish missing columns and create placeholder of 0.0 per the instructions.
  
create view vw_world_happiness_index_consolidated  as
with country_regions as
(
  select distinct country, region --distinct is just for safety
  from world_happiness_index_2015
)
select --has all 11 colunmns
	'2015' as year,
    *,
    0.0 as perceptions_of_corruption --from 2018 and 2019
from world_happiness_index_2015
union all
select --has all 11 columns
	'2016' as year,
    *,
    0.0 as perceptions_of_corruption --from 2018 and 2019
from world_happiness_index_2016
union all
select --no region and diff order columns
	'2017' as year
    ,a.country
    ,b.region
    ,happiness_rank
    ,happiness_score
    ,economy_gdp_per_capita
    ,family
    ,health_life_expectancy
    ,freedom
    ,trust_government_corruption
    ,generosity
    ,dystopia_residual
    ,0.0 as perceptions_of_corruption --from 2018 and 2019
from world_happiness_index_2017 a
left join country_regions b --include even if null
	on a.country = b.country
union all
select 
	'2018' as year
    ,a.country
    ,b.region
    ,a.overall_rank -- happiness_rank
    ,a.score --happiness_score
    ,a.gdp_per_capita --economy_gdp_per_capita
    ,family
    ,health_life_expectancy
    ,freedom
    ,0.0 --trust_government_corruption
    ,generosity
    ,0.0 --dystopia_residual
    ,perceptions_of_corruption
from world_happiness_index_2018 a
left join country_regions b --include even if null
	on a.country = b.country
union all 
select 
	'2019' as year
    ,a.country
    ,b.region
    ,a.overall_rank -- happiness_rank
    ,a.score --happiness_score
    ,a.gdp_per_capita --economy_gdp_per_capita
    ,family
    ,health_life_expectancy
    ,freedom
    ,0.0 --trust_government_corruption
    ,generosity
    ,0.0 --dystopia_residual
    ,perceptions_of_corruption
from world_happiness_index_2019 a
left join country_regions b --include even if null
	on a.country = b.country;

-- select * from vw_world_happiness_index_consolidated;
-------------------------------------
-- Task 1 (Part 2)
-------------------------------------
-- Answer 1: see query results
select country, region
from vw_world_happiness_index_consolidated
where region is null;

-- Answer 2:
--If you are referring to in within the view including all countries, then the difference is a left join to the table when joining to the region lookup table I made with the CTE.

-- Answer 3: 782
select count(*) from vw_world_happiness_index_consolidated;
-------------------------------------
-- Task 2
-------------------------------------

-- Write SQL here, including comments explaining your thought process:

    
-- Adhoc query for quick investigation
-- select * from vw_world_happiness_index_consolidated order by year, happiness_rank limit 50;
    

--For the first query we need to rank the records with a window function partitioning by year and ordering by the reverse of the happiness rank to get a bottom 10 ranking list
	--filter by 10 for both happiness_rank and reverse happiness rank.
	--order by year, then ranking for a nice view
;with vw_with_reverse_rank as
(
  select * 
  	,rank() over(partition by year order by happiness_rank desc) as reverse_happiness_rank
  from vw_world_happiness_index_consolidated 
) 
select *
from vw_with_reverse_rank
where happiness_rank <= 10 or reverse_happiness_rank <= 10
order by year, happiness_rank;

  
  
  --For the second query we will need create an aggregation of the scores and ranking. Then rank based off the aggregation.
  	--Now the happiness ranking has multiple options of purely highest avg rank or highest score, or a more complex combination.
    	--NOTE: rank can have ties but will space out to include only 10
        --If the client wanted tight 1-10 with option of ties I would use dense rank.
    --I provided the option but went with avg_score since this makes most sense to me.
    
;with agg_of_scores as
(
  select country
  	,avg(cast(happiness_rank as float)) as avg_happiness_rank
  	,avg(happiness_score) as avg_happiness_score
  from vw_world_happiness_index_consolidated 
  group by country
),
ranked_agg_of_scores as
(
	select *
  		,rank() over(order by avg_happiness_rank) happy_all_time_rank
  		,rank() over(order by avg_happiness_score) happy_score_all_time_rank
  	from agg_of_scores
) 
select 
  
-- select *
-- 	,rank() over(partition by year order by 
-- from vw_world_happiness_index_consolidated;




-------------------------------------
-- Task 3
-------------------------------------

-- Write SQL here, including comments explaining your thought process:




