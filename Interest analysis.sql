1.Which interests have been present in all month_year dates in our dataset?
From this query we understand that every interest will come only once in a month_year
with metrics as 
 (select to_date(month_year, 'MM-YYYY') as date, cast(interest_id as int), composition, index_value, ranking, percentile_ranking 
 from fresh_segments.interest_metrics
 where month_year is not null
 order by date)
 
select date, interest_id, count(date)
from metrics 
group by date, interest_id
order by count(date) desc

There are totally 14 distinct month_year, so which group of interest_id gives the count of 14 has occured in the months
select interest_id, count(interest_id)
from metrics 
group by interest_id
order by count(interest_id) desc

2.Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - 
which total_months value passes the 90% cumulative percentage value?
with metrics as 
 (select to_date(month_year, 'MM-YYYY') as date, cast(interest_id as int), composition, index_value, ranking, percentile_ranking 
 from fresh_segments.interest_metrics
 where month_year is not null
 order by date)

select * 
from
    (select interest_id, id_cnt, date_cnt, round(((cast(id_cnt as numeric)/date_cnt)*100), 2)  as cum_perc
    from 
        (select interest_id, count(interest_id) as id_cnt, (select count(distinct date)
                                                            from metrics) as date_cnt					
        from metrics 
        group by interest_id) t1) t2
where cum_perc > 90
order by cum_perc

3.If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - 
how many total data points would we be removing?
with metrics as 
 (select to_date(month_year, 'MM-YYYY') as date, cast(interest_id as int), composition, index_value, ranking, percentile_ranking 
 from fresh_segments.interest_metrics
 where month_year is not null
 order by date),

cum_per as
      (
      select *
      from
          (select interest_id, id_cnt, date_cnt, round(((cast(id_cnt as numeric)/date_cnt)*100), 2)  as cum_perc
          from 
              (select interest_id, count(interest_id) as id_cnt, (select count(distinct date)
                                                                  from metrics) as date_cnt					
              from metrics 
              group by interest_id) t1) t2
      order by cum_perc
      )

select count(*)
from cum_per 
where cum_perc < 90

We have to remove 640 entries

4.Does this decision make sense to remove these data points from a business perspective? 
Use an example where there are all 14 months present to a removed interest example for your arguments - 
think about what it means to have less months present from a segment perspective.






5.After removing these interests - how many unique interests are there for each month?
with metrics as 
 (select to_date(month_year, 'MM-YYYY') as date, cast(interest_id as int), composition, index_value, ranking, percentile_ranking 
 from fresh_segments.interest_metrics
 where month_year is not null
 order by date),
 
cum_per_over_90 as
(
select * 
from
    (select interest_id, id_cnt, date_cnt, round(((cast(id_cnt as numeric)/date_cnt)*100), 2)  as cum_perc
    from 
        (select interest_id, count(interest_id) as id_cnt, (select count(distinct date)
                                                            from metrics) as date_cnt					
        from metrics 
        group by interest_id) t1) t2
where cum_perc > 90
order by cum_perc
)

select date, count(distinct c.interest_id)
from metrics m
join cum_per_over_90 c
on m.interest_id = c.interest_id
group by date

date						count
2018-07-01T00:00:00.000Z	541
2018-08-01T00:00:00.000Z	562
2018-09-01T00:00:00.000Z	562
2018-10-01T00:00:00.000Z	562
2018-11-01T00:00:00.000Z	562
2018-12-01T00:00:00.000Z	562
2019-01-01T00:00:00.000Z	560
2019-02-01T00:00:00.000Z	562
2019-03-01T00:00:00.000Z	562
2019-04-01T00:00:00.000Z	562
2019-05-01T00:00:00.000Z	540
2019-06-01T00:00:00.000Z	541
2019-07-01T00:00:00.000Z	546
2019-08-01T00:00:00.000Z	562







	