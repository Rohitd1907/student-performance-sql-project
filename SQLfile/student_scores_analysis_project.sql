use students;
select * from student_scores;

/* Class Average Report */
select class, avg(score) as Average_score_per_class
from student_scores
group by class
order by Average_score_per_class desc;

/* Top-scorer in each class */
select name as top_scorer, class, score
from (select name, class, score,
rank() over(partition by class order by score desc) as rank_in_class
from student_scores) as ranked
where rank_in_class = 1;

/* Underperforming students */
with
avg_score_per_class as (
select class, avg(score) as avg_score from student_scores group by class)
select s.name, s.class, s.score, a.avg_score
from student_scores s
join avg_score_per_class a on s.class = a.class
where s.score < a.avg_score
order by class;

/* Score-distribution */
select name, class, score, 
case ntile(4) over(order by score desc)
when 1 then 'Top 25%'
when 2 then 'Upper Mid 25%'
when 3 then 'Lower Mid 25%'
else 'Bottom 25%'
end as score_band
from student_scores;

/* Honouring Top students */
with 
class_avg as (
select class, avg(score) as avg_score from student_scores group by class),
top_quartile as (
select name, class, score, 
ntile(4) over(order by score desc) as quartile
from student_scores)
select t.name, t.class, t.score, c.avg_score
from top_quartile t
join class_avg c on t.class = c.class
where quartile = 1 and t.score > c.avg_score;

/* Class Ranking Summary */
with
ranking_by_class as (
select name, class, score,
case dense_rank() over(partition by class order by score desc)
when 1 then '1st'
when 2 then '2nd'
when 3 then '3rd'
else 'others'
end as rank_group
from student_scores)
select class, rank_group, count(*) as student_count
from ranking_by_class
group by class, rank_group
order by class;

/* Score Gap Analysis */
with 
rank_by_desc_order as (
select name, class, score,
row_number() over(partition by class order by score desc) as desc_row
from student_scores),
rank_by_asc_order as (
select name, class, score,
row_number() over(partition by class order by score) as asc_row
from student_scores)
select d.class, d.name as top_scorer, d.score as top_score,
a.name as bottom_scorer, a.score as bottom_score,
d.score - a.score as score_gap
from rank_by_desc_order d
join rank_by_asc_order a on d.class = a.class
where desc_row = 1 and asc_row = 1;


