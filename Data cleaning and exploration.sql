1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
 select to_date(month_year, 'MM-YYYY') as date 
 from fresh_segments.interest_metrics
 order by date 
  
2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in 
chronological order (earliest to latest) with the null values appearing first?
https://learnsql.com/blog/how-to-order-rows-with-nulls/
with date_col as 
( select to_date(month_year, 'MM-YYYY') as date 
 from fresh_segments.interest_metrics
 order by date )

select date, count(*)
from date_col
group by date
order by date

3.What do you think we should do with these null values in the fresh_segments.interest_metrics
In the dataset there is explanation about created date and updated date in interest.map table. The NULL values in the 
both columns month_year and interest_id, states it can be the oldest part of the dataset and so I am going to eliminate 
all those 1194 entries out 14273 entries because all these 1194 entriess have been updated with new date

4.How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? 
What about the other way around?
CASE 1: 

with metrics as 
 (select to_date(month_year, 'MM-YYYY') as date, cast(interest_id as int) 
 from fresh_segments.interest_metrics
 order by date )
 
 select metric.interest_id, map.id
from (select distinct interest_id
	 from metrics) metric
left join 
        (select distinct id 
        from fresh_segments.interest_map) map
on metric.interest_id = map.id
where map.id is null and metric.interest_id is not null

CASE 2:

with metrics as 
 (select to_date(month_year, 'MM-YYYY') as date, cast(interest_id as int) 
 from fresh_segments.interest_metrics
 order by date )
 
 select count(*)
from (select distinct interest_id
	 from metrics) metric
right join 
        (select distinct id 
        from fresh_segments.interest_map) map
on metric.interest_id = map.id
where map.id is not null and metric.interest_id is null

we have 7 Ids in interest_map table which is not present in metrics table
interest_id	id
null	42400
null	47789
null	35964
null	40185
null	19598
null	40186
null	42010

5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table
select id, count(id)
from fresh_segments.interest_map
group by id
ORDER BY id

with metrics as 
 (select to_date(month_year, 'MM-YYYY') as date, cast(interest_id as int) 
 from fresh_segments.interest_metrics
 order by date )
 
6.Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? 
Do you think these values are valid and why?

select map.id, created_at, metric.interest_id, date
from (select date, interest_id 
      from metrics) metric 
join (select created_at, id 
      from fresh_segments.interest_map) map
on metric.interest_id = map.id and extract(month from metric.date)<extract(month from map.created_at) and extract(year from metric.date)<extract(year from map.created_at)

No there are no value where the month_year value is before the created_at value


      











