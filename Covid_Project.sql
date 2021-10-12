Select *
From Covid_Project..CovidDeaths
Where location = 'Austria'
Order by 3,4


-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Covid_Project..CovidDeaths
Where continent is not null
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid_Project..CovidDeaths
Where continent is not null
--and location = 'Austria'
Order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, Population, total_cases, (total_cases/population)*100 as InfectedPercentage
From Covid_Project..CovidDeaths
Where continent is not null
--and location = 'Austria'
Order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as InfectedPercentage
From Covid_Project..CovidDeaths
Where continent is not null
Group by location, population
Order by InfectedPercentage desc


-- Showing countries with the highest Death Count per Population

Select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From Covid_Project..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- Let's break things down by continent
-- Showing the continents with the highest death rate

Select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From Covid_Project..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc


-- Global numbers
-- Showing global cases and Deathc per day

Select date, SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as_total_deaths, SUM(Cast(new_deaths as int))/ SUM(New_cases) * 100 as DeathPercentage
From Covid_Project..CovidDeaths
Where continent is not null
Group by date
Order by 1,2


-- Looking at total population vs vaccinations JOIN
-- 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population) *100 Error
From Covid_Project..CovidDeaths dea
Join Covid_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Use CTE

With PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population) *100
From Covid_Project..CovidDeaths dea
Join Covid_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/population) *100 as VaccinatedPercentage
From PopVsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population) *100
From Covid_Project..CovidDeaths dea
Join Covid_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *, (RollingPeopleVaccinated/population) * 100 as VaccinatedPercentage
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population) *100
From Covid_Project..CovidDeaths dea
Join Covid_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * from PercentPopulationVaccinated