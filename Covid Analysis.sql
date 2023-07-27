SELECT *
FROM Project..[Covid Deaths]
ORDER BY 3,4

SELECT *
FROM Project..[Covid Vaccinations]
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Project..[Covid Deaths]
ORDER BY 1,2

--TOTAL DEATHS VS TOTAL CASES

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From Project..[Covid Deaths]
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

--TOTAL CASES VS POPULATION:

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
From Project..[Covid Deaths]
WHERE location like '%states%'
ORDER BY 1,2

--Countries with Highest Infection Rate:
SELECT location, population, max(total_cases) AS HighestInfectionCount, max((total_cases/population))*100 AS PercentPopulationInfected
From Project..[Covid Deaths]
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Covid Deaths]
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--DIVISION AS PER CONTINENT:

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Covid Deaths]
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS:
SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100
FROM [Covid Deaths]
WHERE continent is not null
GROUP BY date
order by 1,2

SELECT *
FROM [Covid Deaths] dea
JOIN [Covid Vaccinations] vac
   ON dea.location = vac.location 
   and dea.date = vac.date

--TOTAL POPULATION VS VACCINATIONS:

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
FROM [Covid Deaths] dea
JOIN [Covid Vaccinations] vac
   ON dea.location = vac.location 
   and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USING COMMON TABLE EXPRESSIONS:

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [Covid Deaths] dea
JOIN [Covid Vaccinations] vac
   ON dea.location = vac.location 
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE:
DROP TABLE IF exists #PercentPopulationVaccinated
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [Covid Deaths] dea
JOIN [Covid Vaccinations] vac
   ON dea.location = vac.location 
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS:

CREATE View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [Covid Deaths] dea
JOIN [Covid Vaccinations] vac
   ON dea.location = vac.location 
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated