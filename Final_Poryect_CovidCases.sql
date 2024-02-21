Select *
From PortfolioProyect..CovidDeaths
Where continent is not null
order by  3,4

--Select *
--From PortfolioProyect..CovidVaccinations
--order by  3,4

--Select Data that we are going to be using

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProyect..CovidDeaths
order by 1,2


-- Looking at total cases vs Total deaths
-- Shows the likelihood of dying if you contract covid in the country you live  (Spain my case)
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProyect..CovidDeaths
where location like '%Spain%'
order by 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of population got covid
Select location,date,population,total_cases,(total_cases/population)*100 as infected
From PortfolioProyect..CovidDeaths
where location like '%Spain%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
Select location,population,MAX(total_cases)as HighestInfectionCount,Max((total_cases/population))*100 as PercentofPopulationInfected
From PortfolioProyect..CovidDeaths
where location like '%Spain%'
Group by population, location
order by PercentofPopulationInfected desc


--Showing Countries with the Highest Death count per Population
Select location,MAX(cast(total_deaths as int))as totalDeathCount--,Max((total_deaths/population))*100 as PercentofPopulationDead
From PortfolioProyect..CovidDeaths
--where location like '%Spain%'
Where continent is not null
Group by location
order by  totalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT
Select continent,MAX(cast(total_deaths as int))as totalDeathCount--,Max((total_deaths/population))*100 as PercentofPopulationDead
From PortfolioProyect..CovidDeaths
--where location like '%Spain%'
Where continent is not  null
Group by continent
order by  totalDeathCount desc

--Showing the Continents with the Highest Death Counts

Select continent,MAX(cast(total_deaths as int))as totalDeathCount--,Max((total_deaths/population))*100 as PercentofPopulationDead
From PortfolioProyect..CovidDeaths
--where location like '%Spain%'
Where continent is not  null
Group by continent
order by  totalDeathCount desc



--GLOBAL NUMBERS
Select sum(new_cases)as TotalCases,sum(cast(new_deaths as int))as TotalDeaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as  DeathPercentage
From PortfolioProyect..CovidDeaths
--where location like '%Spain%'
Where continent is not  null
--Group by date
order by 1,2



--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int))over (partition by dea.location Order by dea.location, 
dea.date)as TotalVaccByDate
From PortfolioProyect..CovidDeaths as dea
Join PortfolioProyect..CovidVaccinations as vac
     On dea.location = vac.location
	 AND dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac(Continent, location, date, population,new_vaccinantion, TotalVaccByDate)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int))over (partition by dea.location Order by dea.location, 
dea.date)as TotalVaccByDate
From PortfolioProyect..CovidDeaths as dea
Join PortfolioProyect..CovidVaccinations as vac
     On dea.location = vac.location
	 AND dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select * , (TotalVaccByDate/population)*100
From PopvsVac


-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVaccByDate numeric

)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int))over (partition by dea.location Order by dea.location, 
dea.date)as TotalVaccByDate
From PortfolioProyect..CovidDeaths as dea
Join PortfolioProyect..CovidVaccinations as vac
     On dea.location = vac.location
	 AND dea.date = vac.date
Where dea.continent is not null
order by 2,3

Select * , (TotalVaccByDate/population)*100 as PercentagePeopleVacc
From #PercentPopulationVaccinated


--Creating view to store data por later visualization

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int))over (partition by dea.location Order by dea.location, 
dea.date)as TotalVaccByDate
From PortfolioProyect..CovidDeaths as dea
Join PortfolioProyect..CovidVaccinations as vac
     On dea.location = vac.location
	 AND dea.date = vac.date
Where dea.continent is not null
--order by 2,3



Select * 
From PercentPopulationVaccinated