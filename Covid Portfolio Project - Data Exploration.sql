--Exploring the Data from Covid19 

--skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types)

select * from CovidDeaths
order by 3,4


--select * from CovidVaccinations$
--order by 3,4

--I selected data that I will be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2


--looking at total cases vs total deaths
--shows the likelyhood of dying if someone contracted covid in Canada 
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from CovidDeaths where location like '%Canada%'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got infected with covid
select location, date, total_cases, population, (total_cases/population) * 100 as CasePercentage
from CovidDeaths where location like '%Canada%'
order by 1,2

select location, date, total_cases, new_cases, population, (total_cases/population) * 100 as CasePercentage
from CovidDeaths 
--where location like '%Canada%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentOfPopulationInfected
from CovidDeaths
Group by location, population
order by 4 desc


--showing Countries with Highest Death Count per population
select location, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
--removes data that shows location as continents
where continent is not null 
Group by location
order by HighestDeathCount desc


-- I break things down by continent
--showing continents with the highest death count

select continent, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
--removes data that shows location as continents
where continent is not null 
Group by continent
order by HighestDeathCount desc

--extracts data where location is continent

select location, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
--removes data that shows location as continents
where continent is null 
Group by location
order by HighestDeathCount desc


--Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths 
--where location like '%Canada%'
where continent is not null
group by date
order by 1,2


select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths 
--where location like '%Canada%'
where continent is not null
order by 1,2

--Looking at Total Population vs Vaccinations

select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
sum(convert(int,CV.new_vaccinations)) over (partition by CD.location order by CD.date) as RollingSumOfPeopleVaccinated
from CovidDeaths CD 
join CovidVaccinations$ CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
order by 2,3


--Use CTE to perform calculation on Partition By in prevous query

with popVSvac 
(Continent, location, date, Population, PeopleVaccinated, RollingSumOfPeopleVaccinated) as
(
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
sum(convert(int,CV.new_vaccinations)) over (partition by CD.location order by CD.date) as RollingSumOfPeopleVaccinated
from CovidDeaths CD 
join CovidVaccinations$ CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
--order by 1,2
)
--shows percentage of population that has received at least one covid Vaccine using CTE

Select *, ( RollingSumOfPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
from popVSvac

--shows total percentage of the population per location that has received covid vaccine using CTE

with popVSvacc 
(Continent, location, date, Population, PeopleVaccinated, RollingSumOfPeopleVaccinated) as
(
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
sum(convert(int,CV.new_vaccinations)) over (partition by CD.location order by CD.date) as RollingSumOfPeopleVaccinated
from CovidDeaths CD 
join CovidVaccinations$ CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null)

Select Continent, Location, Population, max( RollingSumOfPeopleVaccinated/Population)*100 as TotalPercentagePopulationVaccinated
from popVSvacc
Group by Continent, Location, Population
order by 4 desc


--Using Temp Table to perform calculation on Partition By in Previous Query

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
location nvarchar(255), 
date datetime,
Population numeric,
PeopleVaccinated numeric, 
RollingSumOfPeopleVaccinated numeric) 

Insert into #PercentPopulationVaccinated

select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
sum(convert(int,CV.new_vaccinations)) over (partition by CD.location order by CD.date) as RollingSumOfPeopleVaccinated
from CovidDeaths CD 
join CovidVaccinations$ CV
on CD.location = CV.location
and CD.date = CV.date
--where CD.continent is not null
--order by 1,2

Select *, ( RollingSumOfPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
from #PercentPopulationVaccinated

--Creating View to store data for later visualizations

create view PercentPopulationVaccinated as 
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
sum(convert(int,CV.new_vaccinations)) over (partition by CD.location order by CD.date) as RollingSumOfPeopleVaccinated
from CovidDeaths CD 
join CovidVaccinations$ CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
--order by 1,2

select * 
from  PercentPopulationVaccinated