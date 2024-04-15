-- август 2021 - при активации карты вам начисляется бонус 100 рублей,
-- который можно потратить со следующей покупкой, при текущей покупке от 1000 рублей
-- февраль 2022 - увеличили бонус до 200 рублей, а сумму покупки до 1500 рублей
-- конец мая 2022 - полная отмена акции

--Выводим все данные из таблицы

select *
from bonuscheques b


--Когортный анализ LTV

with a as (
    select card, first_value(to_char(datetime, 'YYYY-MM'))
            over(partition by card order by datetime) as cohort, extract(days from datetime - first_value(datetime) 
        over(partition by card order by datetime)) as diff, summ
    from bonuscheques b
    where card like '2000%'
)
select
	cohort,
	count(distinct card) as cnt,
	max(diff) as max_diff,
	sum(case when diff = 0 then summ end) / count(distinct card) as "0",
	case
		when max(diff) >= 30 then sum(case when diff <= 30 then summ end) / count(distinct card)
	end as "30",
	case
		when max(diff) >= 60 then sum(case when diff <= 60 then summ end) / count(distinct card)
	end as "60",
	case
		when max(diff) >= 90 then sum(case when diff <= 90 then summ end) / count(distinct card)
	end as "90",
	case
		when max(diff) >= 180 then sum(case when diff <= 180 then summ end) / count(distinct card)
	end as "180",
	case
		when max(diff) >= 300 then sum(case when diff <= 300 then summ end) / count(distinct card)
	end as "300"
from
	a
group by
	cohort
order by
	cohort
	
	
--Проверяем сами себя

with a as (
select
	card,
	first_value(datetime) over(partition by card order by datetime) as cohort,
	datetime,
	summ
from bonuscheques b
where card like '2000%'
order by card
)
select sum(summ) / count(distinct card)
from a
where to_char(cohort, 'YYYY-MM') = '2021-07' and extract(days from (datetime - cohort)) <= 0
