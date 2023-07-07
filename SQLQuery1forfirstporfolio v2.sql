select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVaccinations$
where continent is not null
order by 3,4

--select data that were going to use
select location, date, total_cases,new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--shows the likelihood of dying if you contact covid in your country


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%Nigeria%'
order by 1,2


-- i used these to change the columns i needed to int;
--ALTER TABLE PortfolioProject..CovidDeaths$
--ALTER COLUMN total_cases float;

--ALTER TABLE PortfolioProject..CovidDeaths$
--ALTER COLUMN total_deaths float;


--looking at the total cases vs Population
-- shows what percentage of te population got covid
select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
from PortfolioProject..CovidDeaths$
where location like '%Nigeria%'
order by 1,2


--looking at countries with highest infection rate compared to population.

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as CasePercentage
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
group by location, population
order by CasePercentage desc


--looking at countries with the highest death rate compared to population

select location, population, max(total_deaths) as HighestDeathCount, max((total_deaths/population))*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
group by location, population
order by DeathPercentage desc

--looking at countries with the highest death counts

select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc


--BREAKING THINGS DOWN BY CONTINENT!!!

--looking at CONTINENTS with the highest death count

select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc

--his wrong way

select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

--death percentage of the world per day

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) TotalDeaths, 
case when sum(new_cases) <> 0 then
sum(cast(new_deaths as int))/ sum(new_cases)*100 
else 00
END AS DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is  not null
group by date
order by 1

--numbers for the whole world 'no date'


select  sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) TotalDeaths, 
case when sum(new_cases) <> 0 then
sum(cast(new_deaths as int))/ sum(new_cases)*100 
else 00
END AS DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is  not null
order by 1

--joining the two tabbels together
--looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use CTE so we can see the percentage of  people vaccinated
WITH POPVSVAC
AS (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM POPVSVAC

--he also did the same but with temptable

drop table if exists #PercentpopulationVaccinated
create table #PercentpopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentpopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentpopulationVaccinated




--creating view to store data for later visualizations

create view PercentpopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentpopulationVaccinated


--create more views





