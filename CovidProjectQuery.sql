SELECT * FROM PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select Data that we are going to be using

Select location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths$
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2


--Looking at Total Cases vs popluation
--Shows what percentage of popluation got Covid

Select location,date,population,total_cases,(total_cases/population)*100 as PercentofPopulation
FROM PortfolioProject..CovidDeaths$
where location like '%states%'
AND continent is not null
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--where location like '%states%'
--AND continent is not null
Group by location, population
order by PercentPopulationInfected desc



--This is showing countries with the highest death count per pooulation

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
----where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc


--Let's Break things down by continent
--Right way
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
----where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



--Showing the Continent with the highest death count per population 
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
----where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- Global Numbers

Select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


-- Loking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int))over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join  PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--USE CTE


WITH PopVsVac (Continent, location, date, population, New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int))over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join  PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopVsVac




--Temp Table
Drop table if exists #PercentPopulationVaccinated --only run if we want to make changes to the table
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int))over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join  PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location 
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated





-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int))over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join  PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


SELECT *FROM PercentPopulationVaccinated