SELECT * 
FROM [PortfolioProject ]..CovidDeaths
--where statement removes the cells that are null
WHERE Continent is NOT NULL
ORDER BY 3,4

--Select Data that we need to use
SELECT location, date, total_cases, new_cases, total_deaths population
FROM [PortfolioProject ]..CovidDeaths
ORDER BY 1,2

-- Looking at Total cases vs New cases
--Shows the liklihood of dying if you contrect covid in your country 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM [PortfolioProject ]..CovidDeaths
WHERE location like 'nigeria'
ORDER BY 1,2

-- Looking at Total cases vs New cases
-- Using United state and Nigeria
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM [PortfolioProject ]..CovidDeaths
WHERE location like 'nigeria' OR location Like '%states%'
ORDER BY 1,2

-- Looking at total cases vs Population
-- Shows what percentage of population got covid 
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentageofInfestedpopulation
FROM [PortfolioProject ]..CovidDeaths
WHERE location like '%nigeria%'
ORDER BY 1,2

-- Looking at countries with highest population rate compared to population
SELECT location, 
		population, 
		Max(total_cases) AS HighestInfestionCount, 
		MAX((total_cases/population))*100 AS PercentInfestedpopulation
FROM [PortfolioProject ]..CovidDeaths
--WHERE location like '%nigeria%'
GROUP BY location,population
ORDER BY PercentInfestedpopulation DESC

-- Showing the countries with hiest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [PortfolioProject ]..CovidDeaths
WHERE continent is not NULL
--WHERE location like '%nigeria%'
GROUP BY location
ORDER BY TotalDeathCount DESC


-----BREAKING DOWN BY CONTINENT-------

-- Showing the continent with highest death count per population(IS NULL/location)
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [PortfolioProject ]..CovidDeaths
WHERE continent is NULL
--WHERE location like '%nigeria%'
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing the continent with highest death count per population(IS not NULL/continent)
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [PortfolioProject ]..CovidDeaths
WHERE continent is not NULL
--WHERE location like '%nigeria%'
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS 
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeath, SUM(CAST(total_deaths as int))/SUM(New_cases)*100 AS Death_Percentage
FROM [PortfolioProject ]..CovidDeaths
WHERE Continent is not NULL
--WHERE location like '%nigeria%' 
GROUP BY date
ORDER BY 1, 2



----Looking into Total population and vaccination
SELECT *
from [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVaccination vac
	ON dea.location = vac.location 
	AND dea.date = vac.date

SELECT dea.continent,  
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS Rollingvaccinated
		-- OR USE(CONVERT(INT,vac.new_vaccinations)
		,(
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVaccination vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

----Using CTE
--columns in the WITH much be the same as column in the SELECT
--Allows RollingVaccinated(a new created column) to be used for aggreagation in the same query)
WITH popvsVac(continent, location, date, population, new_vaccinations, Rollingvaccinated)
AS
(
SELECT dea.continent,  
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS Rollingvaccinated
		-- OR USE(CONVERT(INT,vac.new_vaccinations)
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVaccination vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not NULL
---ORDER BY 2,3
)
SELECT *, (Rollingvaccinated/population)*100 AS RollingPercent
FROM popvsVac
ORDER BY RollingPercent DESC





---TEMP TABLE 
--- droptable allows you to drop a table you just created in case you need to make changes
DROP TABLE if exists #PercentPopulationVaccinat
CREATE TABLE #PercentPopulationVaccinat
(
Continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
Rollingvaccinated numeric
)  

INSERT INTO #PercentPopulationVaccinat 
SELECT dea.continent,  
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS Rollingvaccinated
		-- OR USE(CONVERT(INT,vac.new_vaccinations)
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVaccination vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
--WHERE dea.continent is not NULL
---ORDER BY 2,3
 
SELECT *, (Rollingvaccinated/population)*100 AS RollingPercent
FROM #PercentPopulationVaccinat

---Creating view to store data for 
CREATE VIEW PercentPopulationVaccinat AS
SELECT dea.continent,  
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS Rollingvaccinated
		-- OR USE(CONVERT(INT,vac.new_vaccinations)
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVaccination vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
	WHERE dea.continent is NOT NULL 

	SELECT *
	FROM PercentPopulationVaccinat

	--- I'm working on my first repository   -----
	SELECT * 
	FROM PercentPopulationVaccinat
