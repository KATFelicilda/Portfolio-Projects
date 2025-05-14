/* 7-day SQL Sprint: SQL Daily Worksheets */


/* DAY 01: WRITING MY FIRST QUERIES */
-- 1. Show the total cumulative cases per day on a national level

select
  N.country
  , N.date as date_reported
  , N.total_confirmed_cases
from `bigquery-public-data.covid19_italy.national_trends` N;

-- 2. How many distinct provinces per region are recorded? Show the code, name, and abbreviation per province as well as the region name.

select distinct
  P.region_code
  , P.name as region_name
  , P.province_code
  , P.province_name
  , P.province_abbreviation
from `bigquery-public-data.covid19_italy.data_by_province` P;

-- 3. Show the increase in current cases per day in region code = 6.

select
  R.date as date_reported
  , R.new_current_confirmed_cases as daily_increase_in_active_cases
from `bigquery-public-data.covid19_italy.data_by_region` R
where
  R.region_code = "6";

-- 4. Show the positivity rate and fatality rate for each day, on a national level. Take note that positivity rate = total cases/total performed, while  fatality rate = total deaths/total cases.

select
  N.date
  , (N.total_confirmed_cases/N.tests_performed) AS positivity_rate
  , (N.deaths/N.total_confirmed_cases) AS fatality_rate
from `bigquery-public-data.covid19_italy.national_trends` N;

    -- or to display the rates in percent:

select
  N.date
  , N.total_confirmed_cases
  , N.tests_performed
  , N.deaths
  -- here I learned about round() and safe_divide() functions.
  , round(safe_divide(N.total_confirmed_cases, N.tests_performed)*100, 2) AS positivity_rate
  , round(safe_divide(N.deaths, N.total_confirmed_cases)*100, 2) AS fatality_rate
from `bigquery-public-data.covid19_italy.national_trends` N;

-- 5. Which region and days  recorded more than 10000 in current hospitalized patients? Show the split between hospitalized with symptoms and hospitalized in intensive care.

select
  R.date
  , R.region_code
  , R.region_name
  , R.total_hospitalized_patients
  , R.hospitalized_patients_symptoms AS hospitalized_with_symptoms
  , R.hospitalized_patients_intensive_care AS hospitalized_in_intensive_care
from `bigquery-public-data.covid19_italy.data_by_region` R
where R.total_hospitalized_patients > 10000;

-- 6. What is the hospitalization rate on a national level, for December 25, 2020? Note the ff: Hospitalization rate = total current hospitalized/total current cases. To filter by date, you have to convert the date column into a date. It’s currently a timestamp. To do that, just add the function DATE(). For ex: Date(date) will return just the date (without the time) of the date column.

select
  date(N.date) AS date_reported --converted timestamp to date format
  , round((N.total_hospitalized_patients)/(N.total_current_confirmed_cases), 2) as hospitalization_rate
  , round((N.total_hospitalized_patients)/(N.total_current_confirmed_cases)*100, 2) as hospitalization_percent_rate --for displaying the rate in percent
from `bigquery-public-data.covid19_italy.national_trends` N
where
  date(N.date) = '2020-12-25';

/* END OF DAY 01: WRITING MY FIRST QUERIES */

/* DAY 02: MASTERING THE FUNDAMENTALS */

-- 1. *Get the daily positivity rate for each region. Show data only for October 20, 2020 – October 25, 2020 and order results by date then by region name.*



-- 2. *From your answer in 1 (i.e. using the same columns and conditions), which region and date registered the highest positivity rate? Adjust your query accordingly* 



-- 3. *Show the total confirmed cases for each province in Veneto (5), for Nov 30, 2020,  Dec 31, 2020 and Jan 31, 2021 only.*



-- 4. *Which day had the highest positivity rate in the month of December 2020, for* Toscana (9)

select
  date(R.date) as date_reported
  , R.region_code
  , R.region_name
  , round((R.total_confirmed_cases/R.tests_performed)*100, 2) as positivity_rate
from `bigquery-public-data.covid19_italy.data_by_region` R
where
  R.region_code = '9'
  and (date(R.date) between date('2020-12-01') and
  ('2020-12-31'))
order by
  4 desc
Limit 1;

-- 5. *Which days registered the highest increase of current confirmed cases Consider  June 2020, October 2020, December 2020, and March 2021, in Sicilia (19) and Basilicata (17) only.*

select
  date(R.date) as date_reported
  , R.region_code
  , R.region_name
  , R.new_current_confirmed_cases
from `bigquery-public-data.covid19_italy.data_by_region` R
where
  R.region_code IN ('19', '17')
  and (
  date(R.date) between date('2020-06-01') and date('2020-06-30')
  or date(R.date) between date('2020-10-01') and date('2020-10-31')
  or date(R.date) between date('2020-12-01') and date('2020-12-31')
  or date(R.date) between date('2021-03-01') and date('2021-03-31')
  )
order by
  4 desc;

-- 6. *Which days and regions had a negative increase in current confirmed cases? Consider only region names that start with the letter ‘P’, and January 01 – October 25 for both years 2020 and 2021 only. Sort output by date.*

select
  date(R.date) as date_reported
  , R.region_code
  , R.region_name
  , R.new_current_confirmed_cases
from `bigquery-public-data.covid19_italy.data_by_region` R
where
  R.new_current_confirmed_cases < 0
  and R.region_name like 'P%'
  and (
  date(R.date) between date('2020-01-01') and date('2020-10-25')
  or date(R.date) between date('2021-01-01') and date('2021-10-25')
  )
order by 1;

-- 7. *From your answer in the previous question (i.e. using the same columns and conditions), which day and region registered the lowest case count? Adjust your query accordingly.*

select
  date(R.date) as date_reported
  , R.region_code
  , R.region_name
  , R.new_current_confirmed_cases
from `bigquery-public-data.covid19_italy.data_by_region` R
where
  R.new_current_confirmed_cases < 0
  and R.region_name like 'P%'
  and (
  date(R.date) between date('2020-01-01') and date('2020-10-25')
  or date(R.date) between date('2021-01-01') and date('2021-10-25')
  )
order by
  4 asc
limit 1;

/* END OF DAY 02: MASTERING THE FUNDAMENTALS */

/* DAY 03: AGGREGATE FUNCTIONS */

-- 1. Show the monthly increase of cases per regions per months of July 2021 to September 2021. Sort results by region name, then by date.

select
  R.region_code
  , R.region_name
  , date_trunc(date(R.date), month) as month_reported
  , sum(R.new_total_confirmed_cases) as monthly_increase_of_cases
from `bigquery-public-data.covid19_italy.data_by_region` R
where
  date(R.date) between date('2021-07-01') and date('2021-09-30')
group by 1,2,3
order by 2,3;

-- 2. From the previous question, which regions and month registered an increase of more than 10000?

select
  R.region_code
  , R.region_name
  , date_trunc(date(R.date), month) as month_reported
  , sum(R.new_total_confirmed_cases) as monthly_increase_of_cases
from `bigquery-public-data.covid19_italy.data_by_region` R
where
  date(R.date) between date('2021-07-01') and date('2021-09-30')
group by 1,2,3
having sum(R.new_total_confirmed_cases) > 10000
order by 2,3;

-- 3. Which regions have an average fatality rate of less than 5%? Consider only days where total cases > 0, and sort results from highest fatality rate to lowest.

select
  R.region_code
  , R.region_name
  , round(avg((R.deaths/R.total_confirmed_cases)*100), 2) as avg_fatality_rate
from `bigquery-public-data.covid19_italy.data_by_region` R
where
  R.total_confirmed_cases > 0
group by 1,2
having avg((R.deaths/R.total_confirmed_cases)*100) < 5
order by 3 desc;

/* END OF DAY 03: AGGREGATE FUNCTIONS */

/* DAY 04: JOINs */

-- Which region had the highest contribution in total current national cases, as of October 31, 2021?

select
  R.region_name
  , R.total_current_confirmed_cases as regional_cases
  , N.total_current_confirmed_cases as national_cases
  , round(R.total_current_confirmed_cases / N.total_current_confirmed_cases * 100, 2) as pct_contribution
from `bigquery-public-data.covid19_italy.data_by_region` R
  join `bigquery-public-data.covid19_italy.national_trends` N
    on date(R.date) = date(N.date)
where date(R.date) = '2021-10-31'
order by pct_contribution desc
limit 1;

-- Which province had the highest contribution to total national cases, for November 01, 2021?

select
  P.province_name
  , P.confirmed_cases as province_total_cases
  , N.total_confirmed_cases as national_total_cases
  , round(P.confirmed_cases / N.total_confirmed_cases * 100, 2) as pct_contribution
from `bigquery-public-data.covid19_italy.data_by_province` P
  join `bigquery-public-data.covid19_italy.national_trends` N
    on date(P.date) = date(N.date)
where date(P.date) = '2021-11-01'
order by pct_contribution desc
limit 1;

-- For October 10,2021, show the contribution of each province to regional and national total cases. Exclude any instances where there is no match in region.

select
  P.province_name
 , P.name as region
  , P.confirmed_cases as province_cases
  , R.total_confirmed_cases as regional_cases
  , N.total_confirmed_cases as national_cases
  , round(P.confirmed_cases / R.total_confirmed_cases * 100, 2) as pct_of_region
  , round(P.confirmed_cases / N.total_confirmed_cases * 100, 2) as pct_of_nation
from `bigquery-public-data.covid19_italy.data_by_province` P
  join `bigquery-public-data.covid19_italy.data_by_region` R
    on date(P.date) = date(R.date) and P.name = R.region_name
  join `bigquery-public-data.covid19_italy.national_trends` N
    on date(P.date) = date(N.date)
where date(P.date) = '2021-10-10'
order by pct_of_region desc;

/* END OF DAY 04: JOINs */

/* DAY 05: Conditionals and Subqueries */

-- 1. What percentage of the total historical case increase did the increases from October 2020 to December 2020 make up (i.e. sum of October 2020 to December 2020 increase/sum of all increase). Show for each region. 

-- shorter code:
select 
    N.region_code 
    , N.region_name 
    , sum(if(date(N.date) between date('2020-10-01') and date('2020-12-31'),N.new_total_confirmed_cases,0))/sum(N.new_total_confirmed_cases) * 100 as pct 
from `bigquery-public-data.covid19_italy.data_by_region` N
group by 1,2
order by pct desc;

-- Percentage contribution of Oct–Dec 2020 increases to total increase per region
select
  total.region_code,
  total.region_name,
  round( (oct_dec.total_cases * 100.0) / total.total_cases, 2 ) as pct_oct_dec_contrib
from (
  select
    region_code,
    region_name,
    sum(new_total_confirmed_cases) as total_cases
  from `bigquery-public-data.covid19_italy.data_by_region`
  group by region_code, region_name
) as total
join (
  select
    region_code,
    SUM(new_total_confirmed_cases) as total_cases
  from `bigquery-public-data.covid19_italy.data_by_region`
  where date(date) between '2020-10-01' and '2020-12-31'
  group by region_code
) as oct_dec
on total.region_code = oct_dec.region_code
order by pct_oct_dec_contrib desc;


-- 2. Let Sector 1 = regions 1,2,3,4; Sector 2 = regions 5,6,7,8,9,10, Sector 3 = regions 11,12,13, Sector 4 = all other regions. Show each sector’s average increase in cases per month, from Jan 2021 to Oct 2021 

select
  case
    when region_code in ('1','2','3','4') then 'Sector 1'
    when region_code in ('5','6','7','8','9','10') then 'Sector 2'
    when region_code in ('11','12','13') then 'Sector 3'
    else 'Sector 4'
  end as sector
  , date_trunc(date(date), MONTH) as month_reported
  , round(avg(new_total_confirmed_cases), 2) as avg_case_increase
from `bigquery-public-data.covid19_italy.data_by_region`
where date(date) between '2021-01-01' and '2021-10-31'
group by sector, month_reported
order by avg_case_increase desc;

-- 3. Get total case increase (not the cumulative count) per province, per month.

-- A more concise method by grouping the data by province and month and subtracting the minimum from the maximum confirmed_cases to simulate monthly increases:
select
  date_trunc(date(date), month) as month_reported
  , province_code
  , province_name
  , max(confirmed_cases) - min(confirmed_cases) as monthly_case_increase
from `bigquery-public-data.covid19_italy.data_by_province`
where confirmed_cases is not null
group by province_code, province_name, month_reported
order by province_name, month_reported;

-- A more granular approach using CTEs:
with d1 as (
  select 
    date(p.date) as date
    , p.province_code
    , p.province_name
    , p.confirmed_cases as d1_confirmed_cases
  from `bigquery-public-data.covid19_italy.data_by_province` p
)
, d0 as (
  select 
    date(p.date) as date
    , p.province_code
    , p.province_name
    , p.confirmed_cases as d0_confirmed_cases
  from `bigquery-public-data.covid19_italy.data_by_province` p
)
, main as (
  select 
    d0.date
    , d0.province_code
    , d0.province_name
    , d1.d1_confirmed_cases
    , d0.d0_confirmed_cases
    , d0.d0_confirmed_cases - d1.d1_confirmed_cases as case_increase
  from d0
  left join d1 
    on d0.date = (d1.date + 1)
    and d0.province_code = d1.province_code
)
select 
  date_trunc(m.date, month) as month_reported
  , m.province_code
  , m.province_name
  , sum(m.case_increase) as case_increase
from main m
group by province_code, province_name, month_reported
order by province_name, month_reported;
