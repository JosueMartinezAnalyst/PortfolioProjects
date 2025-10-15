Select *
FROM PorfolioProject ..CovidDeaths
Where continent is not null
order by 3,4
--Select *
--FROM PorfolioProject ..CovidVacinations
--order by 3,4

-- Here I am going to select the data that I am going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PorfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PorfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Looking at the percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as PerfectangePopulationInfected
From PorfolioProject..CovidDeaths
Where continent is not null
--where location like '%states%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PerfectangePopulationInfected
From PorfolioProject..CovidDeaths
--where location like '%states%'
Group By location, population
order by PerfectangePopulationInfected desc


--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths
--where location like '%states%'
Where continent is null
Group By location
order by TotalDeathCount desc


--Now we break it down by continent 

-- Showing Continents with the Highest Death Count per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group By continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS for Each Day, cases, death, and global death percentage

Select date, SUM(new_cases) as GlobalCases, SUM(cast(new_deaths as int)) as GlobalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From PorfolioProject..CovidDeaths
--Where location like '%states%' 
where continent is not null
Group by date
order by 1,2

--Total Global Cases, Deaths, and Percetange of Global Population that Died of Covid

Select SUM(new_cases) as GlobalCases, SUM(cast(new_deaths as int)) as GlobalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From PorfolioProject..CovidDeaths
--Where location like '%states%' 
where continent is not null
--Group By Date
order by 1,2


--Looking at Total Population vs Vaccinations and new_vaccinations means per day, partion by dea.location is added
-- as to not have the rolling sum by day continue over a new location and gets neatly separated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated --(RollingPeopleVaccinated/Population)*100 I'll use a CTE and TempTable example for this
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVacinations vac
     On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


--Using CTE to see Percetange of the population vaccinated by day


with PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated --,(RollingPeopleVaccinated/Population)*100 I'll use a CTE and TempTable example for this
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVacinations vac
     On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPopulationPercentage
From PopvsVac




--Now using a TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated --,(RollingPeopleVaccinated/Population)*100 I'll use a CTE and TempTable example for this
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVacinations vac
     On dea.location = vac.location and dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPopulationPercentage
From #PercentPopulationVaccinated



--Creating multiple views to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated --,(RollingPeopleVaccinated/Population)*100 I'll use a CTE and TempTable example for this
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVacinations vac
     On dea.location = vac.location and dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3

Create View GlobalNumbers as
Select date, SUM(new_cases) as GlobalCases, SUM(cast(new_deaths as int)) as GlobalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From PorfolioProject..CovidDeaths
--Where location like '%states%' 
where continent is not null
Group by date 
-- order by 1,2

Create View GlobalDeath as
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group By continent
--order by TotalDeathCount desc
