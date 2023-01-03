-- Looking at total cases vs total deaths

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) AS DeathPercentage
FROM portfolioproject..CovidDeaths
WHERE location = 'United States'
order by 1, 2


--Looking at total cases on a per capita basis.

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/population)*100, 2) AS PerCapita
FROM portfolioproject..CovidDeaths
WHERE location = 'United States'
order by 1, 2


-- looking at countries with hightest infection rates.

SELECT location,population, MAX(total_cases) as HighestInfectionCount, ROUND(MAX((total_cases/population))*100,2) AS PercentPopInfected
FROM portfolioproject..CovidDeaths
GROUP BY location, population
order by PercentPopInfected DESC

--Highest Death count per country

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM portfolioproject..CovidDeaths 
WHERE continent is not null
GROUP BY location
order by TotalDeathCount DESC


--Highest Death count per continent

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM portfolioproject..CovidDeaths 
WHERE continent is null
GROUP BY location
order by TotalDeathCount DESC

--Global numbers

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM portfolioproject..CovidDeaths 
WHERE continent is not null
--GROUP BY date
order by 1, 2


--JOIN

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS vaccines
FROM portfolioproject..CovidDeaths  dea
  JOIN portfolioproject..CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
  ORDER BY 2,3


--CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, ROUND((RollingPeopleVaccinated/population)*100,2)
FROM PopvsVac


-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated

-- creating view to store data for later visualizations.

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3



--Creating a view for Highest Death count per country

Create View Highest_death_Count_Per_Country AS
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM portfolioproject..CovidDeaths 
WHERE continent is not null
GROUP BY location
--order by TotalDeathCount DESC