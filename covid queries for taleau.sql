-- Queries for visualization

--1
select
sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from covid_deaths
where continent is not null
order by total_cases, total_deaths;


--2
select location as continent, SUM(cast(new_deaths as int)) as total_death_count
from covid_deaths
where continent is null 
and location not in ('World', 'European Union', 'International' , 'Upper middle income' , 'high income' , 'lower middle income' , 'low income')
group by location
order by total_death_count desc;


--3
select 
location, population, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population)*100) as population_infection_percentage
from covid_deaths
group by location, population
order by population_infection_percentage desc;


--4
select 
location, population, date, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population)*100) as population_infection_percentage
from covid_deaths
group by location, population, date
order by population_infection_percentage desc;