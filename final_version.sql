select * from coviddeaths
where continent is null 

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1, 2

-- looking at total cases versus total deaths 
-- shows the probability of dying if you get the covid 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where location like '%States%' 
order by 1 , 2

-- looking at the total cases versus population 
-- shows what percent of population got covid
select location, date, total_cases, population, (total_cases/population) * 100 as death_percentage
from coviddeaths
-- where location like '%States%' 
order by 1 , 2

-- the countries with highest infection rates compared to the population 
select location, population, max(total_cases) as highest_infection_count,  max(total_cases/population) * 100 as infected_percentage_of_population
from coviddeaths
-- where location like '%States%'
group by location, population
order by infected_percentage_of_population desc

-- showing countries with highest death count per population
select location,  max(total_deaths) as total_death_count
from coviddeaths
-- where location like '%States%'
where continent is not null 
group by location
having max(total_deaths) is not null
order by total_death_count desc


-- calculate deaths by continent -- 

select location,  max(total_deaths) as total_death_count
from coviddeaths
-- where location like '%States%'
where continent is null 
group by location
order by total_death_count desc

-- Global numbers

select date, sum(total_cases) -- sum(total_deaths), (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where continent is not null
group by date
order by 1 , 2

-- checking the sum of new_Cases and new_deaths globally

select date, sum(new_cases) as total_cases, cast(sum(new_deaths)as float) as total_deaths, 
(cast(sum(new_deaths)as float)/sum(new_cases)) * 100 as death_percentage
from coviddeaths
where continent is not null
group by date
order by 1 , 2

--total deaths without specific date across the world 

select sum(new_cases) as total_cases, cast(sum(new_deaths)as float) as total_deaths, 
(cast(sum(new_deaths)as float)/sum(new_cases)) * 100 as death_percentage
from coviddeaths
where continent is not null
-- group by date
order by 1 , 2

-- JOINING two vaccinations and deaths tables
--total population versus vaccinations
-- important query

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated -- (RollingPeopleVaccinated/population)*100
from coviddeaths as dea
join covidvaccinations as vac
on vac.location =dea.location 
and vac.date = dea.date
where dea.continent is not null 
order by 2,3;


-- USE CTE (COMMON TABLE EXPRESSION)
-- CTE more acts as temporary place let you grab the info

with PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as 
--we are putting the query above (the previous query in a paranthesis below)
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated -- (RollingPeopleVaccinated/population)*100
from coviddeaths as dea
join covidvaccinations as vac
on vac.location =dea.location 
and vac.date = dea.date
where dea.continent is not null 
order by 2,3
)
select *, (RollingPeopleVaccinated/population) *100 from PopvsVac

--Temp Table

drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
continent varchar(200),
location varchar(200),
date timestamp,
population numeric,
New_vaccinations numeric
)
	

insert into PercentPopulationVaccinated 
(dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated) -- (RollingPeopleVaccinated/population)*100
from coviddeaths as dea
join covidvaccinations as vac
on vac.location =dea.location 
and vac.date = dea.date
where dea.continent is not null 
order by 2,3

select *, (RollingPeopleVaccinated/population) *100 from #PercentPopulationVaccinated


-- Create a VIEW 

select sum(new_cases) as total_cases, cast(sum(new_deaths)as float) as total_deaths, 
(cast(sum(new_deaths)as float)/sum(new_cases)) * 100 as death_percentage
from coviddeaths
where continent is not null
-- group by date
order by 1 , 2


--Create a VIEW to store data for alter visualization

create view Percent_Population_Vaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated -- (RollingPeopleVaccinated/population)*100
from coviddeaths as dea
join covidvaccinations as vac
on vac.location =dea.location 
and vac.date = dea.date
where dea.continent is not null 
-- order by 2,3






