The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.

1.What is the top 10 interests by the average composition for each month?

with metrics as 
 (select to_date(month_year, 'MM-YYYY') as date, cast(interest_id as int), composition, index_value, ranking, percentile_ranking 
 from fresh_segments.interest_metrics
 where month_year is not null
 order by date)

select *
from 
    (select *, rank() over(partition by date
                          order by avg_composition desc
                          ) as ac_rank
    from                      
        (select date, interest_id, (composition/index_value) as avg_composition
        from metrics) t1) t2
where ac_rank <= 10 

2. For all of these top 10 interests - which interest appears the most often?
select interest_id, count(interest_id) as most_common
from
    (select *
    from 
        (select *, rank() over(partition by date
                              order by avg_composition desc
                              ) as ac_rank
        from                      
            (select date, interest_id, (composition/index_value) as avg_composition
            from metrics) t1) t2
    where ac_rank <= 10) t3
group by interest_id
order by most_common desc

interest_id		most_common
7541			10
6065			10
5969			10

3.What is the average of the average composition for the top 10 interests for each month?
with metrics as 
 (select to_date(month_year, 'MM-YYYY') as date, cast(interest_id as int), composition, index_value, ranking, percentile_ranking 
 from fresh_segments.interest_metrics
 where month_year is not null
 order by date)

select distinct date,avg_avg_composition
from 
    (select date, avg(avg_composition) over(partition by date) as avg_avg_composition
    from 
        (select *, rank() over(partition by date
                               order by avg_composition desc
                               ) as ac_rank
        from                      
             (select date, interest_id, (composition/index_value) as avg_composition
              from metrics) t1) t2
    where ac_rank <= 10) t3
order by date

date						avg_avg_composition
2018-07-01T00:00:00.000Z	6.03812307760671
2018-08-01T00:00:00.000Z	5.944802742825548
2018-09-01T00:00:00.000Z	6.894502223584145
2018-10-01T00:00:00.000Z	7.065649859921907
2018-11-01T00:00:00.000Z	6.623172076611762
2018-12-01T00:00:00.000Z	6.651402114895364
2019-01-01T00:00:00.000Z	6.3981629187816225
2019-02-01T00:00:00.000Z	6.579529239885337
2019-03-01T00:00:00.000Z	6.169322368105214
2019-04-01T00:00:00.000Z	5.7493865062854175
2019-05-01T00:00:00.000Z	3.5351401131374045
2019-06-01T00:00:00.000Z	2.4253057847615076
2019-07-01T00:00:00.000Z	2.764865701700349
2019-08-01T00:00:00.000Z	2.631945827450902

We could see the average composition value is going down.

4.What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and 
include the previous top ranking interests in the same output shown below.

with metrics as 
 (select to_date(month_year, 'MM-YYYY') as date, cast(interest_id as int), composition, index_value, ranking, percentile_ranking, composition/index_value as avg_composition 
 from fresh_segments.interest_metrics
 where month_year is not null
 order by date)

select date, interest_name, maximum, round(cast(three_month_avg as numeric), 2) 
from
    (select *, avg(maximum) over(partition by ''
                                order by date
                                rows between 2 preceding and current row) as three_month_avg
    from                            
        (select t1.date, interest_name, maximum
        from 
            (select m1.date, interest_id, m1.maximum
            from
                (select date, max(avg_composition) as maximum
                from metrics
                group by date) m1
            join metrics m2
            on m1.maximum = m2.avg_composition) t1 
        join fresh_segments.interest_map map 
        on t1.interest_id = map.id) t2) t3
where date between '2018-09-01' and '2019-08-01'	

date						interest_name				maximum				round
2018-09-01T00:00:00.000Z	Work Comes First Travelers	8.263636363636364	7.61
2018-10-01T00:00:00.000Z	Work Comes First Travelers	9.135135135135135	8.20
2018-11-01T00:00:00.000Z	Work Comes First Travelers	8.27659574468085	8.56
2018-12-01T00:00:00.000Z	Work Comes First Travelers	8.313725490196079	8.58
2019-01-01T00:00:00.000Z	Work Comes First Travelers	7.657258064516128	8.08
2019-02-01T00:00:00.000Z	Work Comes First Travelers	7.6625000000000005	7.88
2019-03-01T00:00:00.000Z	Alabama Trip Planners		6.543046357615895	7.29
2019-04-01T00:00:00.000Z	Solar Energy Researchers	6.275862068965518	6.83
2019-05-01T00:00:00.000Z	Readers of Honduran Content	4.409090909090909	5.74
2019-06-01T00:00:00.000Z	Las Vegas Trip Planners		2.7650602409638556	4.48
2019-07-01T00:00:00.000Z	Las Vegas Trip Planners		2.8175675675675675	3.33
2019-08-01T00:00:00.000Z	Cosmetics and Beauty Shopp	2.728476821192053	2.77

5.Provide a possible reason why the max average composition might change from month to month? 
Could it signal something is not quite right with the overall business model for Fresh Segments?
