
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID-19 in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
AND location = 'malaysia'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentages of population got COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
AND location = 'malaysia'
ORDER BY 1,2


-- Looking at countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS 
	   PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--AND location = 'malaysia'
GROUP BY location, population
ORDER BY 4 DESC


-- Showing countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--@@@ LET'S BREAK THINGS DOWN BY CONTINENT @@@--


-- Showing continents with the Highest Death Count per Population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- THIS IS THE RIGHT ONE --
--SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
--FROM PortfolioProject..CovidDeaths
--WHERE continent is null
--GROUP BY location
--ORDER BY TotalDeathCount DESC


-- Looking at continents with Highest Infection Rate compared to Population

SELECT continent, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS 
	   PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 3 DESC


-- Looking at Total Cases vs Population
-- Shows what percentages of population got COVID

SELECT continent, date, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2



-- GLOBAL NUMBERS

SELECT /*date,*/ SUM(new_cases) as TotalNewCases, SUM(CAST(new_deaths as int)) as TotalNewDeaths, 
	   SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
--AND location like 'malaysia'
--GROUP BY date
ORDER BY 1,2

--BY DATE
SELECT date, SUM(new_cases) as TotalNewCases, SUM(CAST(new_deaths as int)) as TotalNewDeaths, 
	   SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
--AND location like 'malaysia'
GROUP BY date
ORDER BY 1,2


--@@@@@ FROM COVID VACCINATIONS @@@@@--

SELECT *
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


-- Looking at Total Population vs Vaccinations(per day)

SELECT dea.continent, dea.location, dea.date, dea.population, CONVERT(bigint,vac.new_vaccinations)
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
   dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
AND dea.location like 'malaysia'
ORDER BY 2,3 

--@@ USE CTE @@--
-- We want to know how many people in that country are vaccinated

-- With and SELECT must have same no. of column list
With PopvsVac (Continent, Location, Date, Population, NewVaccin, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, CONVERT(bigint,vac.new_vaccinations)
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
   dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
FROM PopvsVac
Where Location = 'malaysia'


--@@ USE TEMP TABLE @@--

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, CONVERT(bigint,vac.new_vaccinations)
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
   dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--AND dea.location like 'malaysia'
ORDER BY 2,3 

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
FROM #PercentPopulationVaccinated
Where Location = 'malaysia'



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, /*CONVERT(bigint,vac.new_vaccinations) 
	   as*/ new_vaccinations,
	   SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
	   dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--AND dea.location like 'malaysia'
--ORDER BY 2,3 


SELECT *
FROM PercentPopulationVaccinated


