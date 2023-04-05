select * from dbo.CovidDeaths;

select * from dbo.CovidVaccinations;

--select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1,2;


--looking at total cases vs total deaths
--show likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage 
from dbo.CovidDeaths
where location like '%state%'
order by 1,2;


--looking at total cases vs population
--shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as infectedPopulation_Percentage 
from dbo.CovidDeaths
where location like '%state%'
order by 1,2;



--looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as infectedPopulation_Percentage 
from dbo.CovidDeaths
--where location like '%state%'
group by location, population
order by infectedPopulation_Percentage desc;



--showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as Totaldeathcount
from dbo.CovidDeaths
--where location like '%state%'
where continent is not null
group by location
order by Totaldeathcount desc;



--lets break things down by continent
select location, max(cast(total_deaths as int)) as Totaldeathcount
from dbo.CovidDeaths
--where location like '%state%'
where continent is null
group by location
order by Totaldeathcount desc;



--Global values
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
       sum(cast(new_deaths as int)) / sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
--where location like '%state%'
where continent is null
--group by location
order by 1,2;


--Looking at total populations vs vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;


--or (with cte)
with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *, (RollingPeopleVaccinated / population)*100 as PopVsVac_Percentage from PopVsVac;


--or (with temp table)
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *, (RollingPeopleVaccinated / population)*100 as PopVsVac_Percentage from #PercentPopulationVaccinated;



--Create view to store data for visualizations
create view PercentagePopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select * from PercentagePopulationVaccinated;