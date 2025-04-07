# SQL
11.Fetch the top 5 athletes who have won the most gold medals.

with t1 as 

(select  name, count(1) as gold_medal from athlete_events

where medal = 'Gold'

group by name

order by count(1) desc),

t2 as 

(select*, dense_rank()over (order by gold_medal desc) as rank

from t1)

select * from t2

where rank <=5


12.Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

with t1 as (select name, count(medal) as medals

from athlete_events

group by name

order by medals desc),

t2 as 

(select *, dense_rank()over(order by medals desc) as rnk

from t1)

select* from t2

where rnk <=5


13.Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

with t1 as (select b.region, count(medal) as medals

from athlete_events as a

join

noc_region as b

on a.noc = b.noc

group by b.region),

t2 as 

(select *, dense_rank()over (order by medals desc) rnk

from t1)

select * from t2 

where rnk <=5;


14. List down total gold, silver and bronze medals won by each country.

with t1 as (select b.region as country, a.medal, count(medal) as total_medals

from athlete_events as a

join noc_region as b

on a.noc = b.noc

where medal != 'NA'

group by country, a.medal

order by country,

 a.medal),

t2 as 

(select country, 

sum( case when medal = 'Gold' then total_medals else 0 end) as Gold,

sum(case when medal = 'Silver' then total_medals else 0 end) as silver,

sum(case when medal = 'Bronze' then total_medals else 0 end) as Bronze

from t1

group by country)

select * from t2

order by gold desc


15.List down total gold, silver and bronze medals won by each country corresponding to each olympic games.

with t1 as (select b.region as country, a.medal, count(medal) as total_medals

from athlete_events as a

join noc_region as b

on a.noc = b.noc

where medal != 'NA'

group by country, a.medal

order by country,

 a.medal),

t2 as 

(select country, 

sum( case when medal = 'Gold' then total_medals else 0 end) as Gold,

sum(case when medal = 'Silver' then total_medals else 0 end) as silver,

sum(case when medal = 'Bronze' then total_medals else 0 end) as Bronze

from t1

group by country),

t3 as 

(select country, sum(gold+silver+bronze) as total_medals from t2

group by country)

select t2.country, t2.gold, t2.silver, t2.bronze, t3.total_medals

from t2

join t3

on t2.country = t3.country

order by t2.gold desc


16.Identify which country won the most gold, most silver and most bronze medals in each olympic games.

WITH t1 AS (

  SELECT a.games, b.region AS country, a.medal, COUNT(medal) AS total_medals

  FROM athlete_events AS a

  JOIN noc_region AS b ON a.noc = b.noc

  WHERE medal != 'NA'

  GROUP BY games, country, a.medal

  ORDER BY games

),

t2 AS (

  SELECT games,

    MAX(CASE WHEN medal = 'Gold' THEN total_medals ELSE 0 END) AS max_gold,

    MAX(CASE WHEN medal = 'Silver' THEN total_medals ELSE 0 END) AS max_silver,

    MAX(CASE WHEN medal = 'Bronze' THEN total_medals ELSE 0 END) AS max_bronze

  FROM t1

  GROUP BY games

),

t3 AS (

  SELECT t1.games, t1.country, t1.medal, t1.total_medals

  FROM t1

  JOIN t2 ON t1.games = t2.games

  WHERE (t1.medal = 'Gold' AND t1.total_medals = t2.max_gold)

     OR (t1.medal = 'Silver' AND t1.total_medals = t2.max_silver)

     OR (t1.medal = 'Bronze' AND t1.total_medals = t2.max_bronze)

)

SELECT t2.games, 

  MAX(CASE WHEN t3.medal = 'Gold' THEN concat(t3.country," - ", t2.max_gold) END) AS max_gold_country,

  MAX(CASE WHEN t3.medal = 'Silver' THEN concat(t3.country," - ", t2.max_silver) END) AS max_silver_country,

  MAX(CASE WHEN t3.medal = 'Bronze' THEN concat(t3.country," - ", t2.max_bronze) END) AS max_bronze_country

FROM t2

JOIN t3 ON t2.games = t3.games

GROUP BY t2.games;


17.Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.

WITH t1 AS (

  SELECT a.games, b.region AS country, a.medal, COUNT(medal) AS total_medals

  FROM athlete_events AS a

  JOIN noc_region AS b ON a.noc = b.noc

  WHERE medal != 'NA'

  GROUP BY games, country, a.medal

  ORDER BY games

),

t2 AS (

  SELECT games,

    MAX(CASE WHEN medal = 'Gold' THEN total_medals ELSE 0 END) AS max_gold,

    MAX(CASE WHEN medal = 'Silver' THEN total_medals ELSE 0 END) AS max_silver,

    MAX(CASE WHEN medal = 'Bronze' THEN total_medals ELSE 0 END) AS max_bronze

  FROM t1

  GROUP BY games

),

t3 AS (

  SELECT t1.games, t1.country, t1.medal, t1.total_medals

  FROM t1

  JOIN t2 ON t1.games = t2.games

  WHERE (t1.medal = 'Gold' AND t1.total_medals = t2.max_gold)

     OR (t1.medal = 'Silver' AND t1.total_medals = t2.max_silver)

     OR (t1.medal = 'Bronze' AND t1.total_medals = t2.max_bronze)

),

t4 AS (

  SELECT t2.games, 

    MAX(CASE WHEN t3.medal = 'Gold' THEN CONCAT(t3.country, " - ", t2.max_gold) END) AS max_gold_country,

    MAX(CASE WHEN t3.medal = 'Silver' THEN CONCAT(t3.country, " - ", t2.max_silver) END) AS max_silver_country,

    MAX(CASE WHEN t3.medal = 'Bronze' THEN CONCAT(t3.country, " - ", t2.max_bronze) END) AS max_bronze_country

  FROM t2

  JOIN t3 ON t2.games = t3.games

  GROUP BY t2.games

),

t5 AS (

  SELECT t4.games, t4.max_gold_country, t4.max_silver_country, t4.max_bronze_country,

    MAX(t3.total_medals) AS highest_total_medals

  FROM t4

  JOIN t3 ON t4.games = t3.games

  GROUP BY t4.games

)

select t5.games, t5.max_gold_country, t5.max_silver_country, t5.max_bronze_country, concat(t3.country, " - ", t5.highest_total_medals) as max_total_medals

from t5

join t3 on t5.games = t3.games


18. Which countries have never won gold medal but have won silver/bronze medals?

With
T1 As
(select region,
sum(case when Medal='Gold' then 1 else 0 end) as Gold,
sum(case when Medal= 'Silver' then 1 else 0 end) as Silver,
sum(case when Medal= 'Bronze' then 1 else 0 end) as Bronze
from athlete_events as a join noc_region as b
on a.noc=b.noc
group by region)
Select Region,Gold,Silver,Bronze From T1 Where Gold = 0 And (Silver > 0 or Bronze > 0)


19. In which Sport/event, India has won highest medals?

with t1 as (
select b.region as region, a.sport, count(a.medal) as total_medals
from athlete_events as a
join noc_region as b
on a.noc = b.noc 
group by b.region,a.sport
order by total_medals desc)
select region, sport , total_medals as highest_medals 
from t1 
where region = 'india'
limit 1

(here if the highest is two sports with same medals which means use dense_rank)


20. Break down all olympic games where India won medal for Hockey and how many medals in each olympic games?

with t1 as (
select b.region, a.games, a.sport, count(a.medal) as medal
from athlete_events as a
join noc_region as b
on a.noc = b.noc
group by b.region, a.games, a.sport
order by a.games)
select region, sport, games, medal
from t1
where region = 'india' and sport = 'hockey' and medal >=1
