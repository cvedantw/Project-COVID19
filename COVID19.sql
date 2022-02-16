-- Creating a database named covid19 & imported data from excel into 2 tables covid_deaths & covid_vaccinations
create database covid19;
use covid19;

-- EXPLORING COVID DEATHS DATA

-- There are instances where the continent name is null and the location name in those same instances have values as continent name (Ex: location = Asia, Europe..)
select 
location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
where continent is not null
order by location, date;


-- Calculating the Infection Percentage (Cases vs Population OR % of population getting infected due to COVID19)
select 
location, date, total_cases, population, (total_cases/population)*100 as population_infection_percentage
from covid_deaths
where continent is not null
order by location, date;


-- Calculating the Death Percentage (Deaths vs Population OR % of population dying due to COVID19)
select 
location, date, total_cases, total_deaths, population, (total_deaths/population)*100 as population_death_percentage
from covid_deaths
where continent is not null
order by location, date;


-- Looking at Total Cases vs Total Deaths (% of infected people who are dying OR likelihood of dying if one gets infected)
select 
location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
from covid_deaths
where continent is not null
order by location, date;


-- Looking at countries with the highest infection rate compared to population
select 
location, population, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population)*100) as highest_infection_percentage
from covid_deaths
where continent is not null
group by location, population
order by highest_infection_percentage desc;


-- Looking at countries with highest death count
-- There is an issue with the data type of total_deaths as it was imported as nvarchar, hence casting it as an integer
select 
location, population, MAX(cast(total_deaths as int)) as Highest_death_count
from covid_deaths
where continent is not null
group by location, population
order by highest_death_count desc;

-- Exploring some stats by CONTINENTS
select 
continent, MAX(cast(total_deaths as int)) as Highest_death_count
from covid_deaths
where continent is not null
group by continent
order by highest_death_count desc;

-- Exploring Global new cases & new deaths by date

select
date, SUM(new_cases) as Total_new_cases, SUM(cast(new_deaths as int)) as Total_new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from covid_deaths
where continent is not null
group by date
order by date;


-- EXPLORING COVID VACCINATIONS DATA

-- Joining the covid deaths & vaccination tables to look at total population vs total vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_vacc_number
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by location, date;

-- Calculating the percentage of population vaccinated on any given day (creating a temp table popvacc)

with popvacc (continent, location, date, population, new_vaccinations, rolling_vac_number)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_vacc_number
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select * , (rolling_vac_number/population)*100 as Population_vaccinated
from popvacc;


-- Creating a temporary table percentpopvacc with the above data
drop table if exists percentpopvacc
create table percentpopvacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into percentpopvacc
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(numeric, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_vacc_number
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date

select * , (rollingpeoplevaccinated/population)*100 from percentpopvacc;


-- Creating view to store data for future visualization

create view population_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(numeric, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_vacc_number
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date

