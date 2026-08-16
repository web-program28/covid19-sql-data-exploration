SELECT *
FROM PortofolioProject.coviddeaths_clean
ORDER BY location, `date`;

SELECT *
FROM PortofolioProject.covidvaccinations_clean
ORDER BY location, `date`;

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject.coviddeaths_clean
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows the percentage of reported COVID-19 cases that resulted in recorded deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortofolioProject.coviddeaths_clean
WHERE location LIKE '%states'
ORDER BY 1,2;

-- Looking at Total Cases VS Population
-- Show what percentage of population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortofolioProject.coviddeaths_clean
WHERE location LIKE '%states'
ORDER BY 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortofolioProject.coviddeaths_clean
-- WHERE location LIKE '%states'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortofolioProject.coviddeaths_clean
-- WHERE location LIKE '%states'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- LET'S BREAK THINGS DOWN BY CONTINENTS

SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM PortofolioProject.coviddeaths_clean
-- WHERE location LIKE '%states'
WHERE continent IS  NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Global Numbers
SELECT 
    `date`,
    SUM(new_cases) AS total_cases,
    SUM(cast(new_deaths AS SIGNED)) AS total_deaths,
    (SUM(CAST(new_deaths AS SIGNED)) /
	NULLIF(SUM(CAST(new_cases AS SIGNED)), 0)) * 100
    AS DeathPercentage
FROM PortofolioProject.coviddeaths_clean
WHERE continent IS NOT NULL
GROUP BY `date`
ORDER BY 1,2;


-- Looking at Total Population VS Vaccinations

SELECT 
    dea.continent,
    dea.location,
    dea.`date`,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED))
        OVER (
            PARTITION BY dea.location
            ORDER BY dea.`date`
        ) AS RollingPeopleVaccinated
FROM PortofolioProject.coviddeaths_clean AS dea
JOIN PortofolioProject.covidvaccinations_clean AS vac
    ON dea.location = vac.location
    AND dea.`date` = vac.`date`
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- USE CTE

WITH PopvsVac AS (
    SELECT 
        dea.continent,
        dea.location,
        dea.`date`,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS SIGNED))
            OVER (
                PARTITION BY dea.location
                ORDER BY dea.`date`
            ) AS RollingPeopleVaccinated
    FROM PortofolioProject.coviddeaths_clean AS dea
    JOIN PortofolioProject.covidvaccinations_clean AS vac
        ON dea.location = vac.location
        AND dea.`date` = vac.`date`
    WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;


-- Temp Table

DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinatedTemp;

CREATE TEMPORARY TABLE PercentPopulationVaccinatedTemp
(
    continent VARCHAR(255),
    location VARCHAR(255),
    `date` DATETIME,
    population BIGINT,
    New_Vaccinations BIGINT,
    RollingPeopleVaccinated BIGINT
);

INSERT INTO PercentPopulationVaccinatedTemp
SELECT 
    dea.continent,
    dea.location,
    dea.`date`,
    dea.population,
    CAST(vac.new_vaccinations AS SIGNED),
    SUM(CAST(vac.new_vaccinations AS SIGNED))
        OVER (
            PARTITION BY dea.location
            ORDER BY dea.`date`
        ) AS RollingPeopleVaccinated
FROM PortofolioProject.coviddeaths_clean AS dea
JOIN PortofolioProject.covidvaccinations_clean AS vac
    ON dea.location = vac.location
    AND dea.`date` = vac.`date`
WHERE dea.continent IS NOT NULL;

SELECT 
    *,
    ROUND(
        (RollingPeopleVaccinated / NULLIF(population, 0)) * 100,
        2
    ) AS VaccinationPercentage
FROM PopvsVac
ORDER BY location, `date`;

-- Creating View to Store Data for Later Visualizations

CREATE OR REPLACE VIEW vw_PercentPopulationVaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.`date`,
    dea.population,
    CAST(vac.new_vaccinations AS SIGNED) AS New_Vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED))
        OVER (
            PARTITION BY dea.location
            ORDER BY dea.`date`
        ) AS RollingPeopleVaccinated
FROM PortofolioProject.coviddeaths_clean AS dea
JOIN PortofolioProject.covidvaccinations_clean AS vac
    ON dea.location = vac.location
    AND dea.`date` = vac.`date`
WHERE dea.continent IS NOT NULL;

-- ORIGINAL ANALYSIS 1
-- COVID-19 Trend in Indonesia
SELECT
    location,
    `date`,
    total_cases,
    new_cases,
    total_deaths,
    population,
    ROUND((total_cases / NULLIF(population, 0)) * 100, 2) 
        AS PercentPopulationInfected,
    ROUND((total_deaths / NULLIF(total_cases, 0)) * 100, 2) 
        AS DeathPercentage
FROM PortofolioProject.coviddeaths_clean
WHERE location = 'Indonesia'
ORDER BY `date`;

-- ORIGINAL ANALYSIS 2
-- Top 10 Countries by Infection Rate
SELECT
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    ROUND(
        MAX(total_cases / NULLIF(population, 0)) * 100,
        2
    ) AS PercentPopulationInfected
FROM PortofolioProject.coviddeaths_clean
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC
LIMIT 10;

-- ORIGINAL ANALYSIS 3
-- Top 10 Countries by Total Deaths
SELECT
    location,
    MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM PortofolioProject.coviddeaths_clean
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
LIMIT 10;

-- ORIGINAL ANALYSIS 4
-- Global Monthly COVID-19 Trend
SELECT
    DATE_FORMAT(`date`, '%Y-%m') AS Month,
    SUM(CAST(new_cases AS SIGNED)) AS MonthlyCases,
    SUM(CAST(new_deaths AS SIGNED)) AS MonthlyDeaths,
    ROUND(
        (
            SUM(CAST(new_deaths AS SIGNED))
            /
            NULLIF(SUM(CAST(new_cases AS SIGNED)), 0)
        ) * 100,
        2
    ) AS MonthlyDeathPercentage
FROM PortofolioProject.coviddeaths_clean
WHERE continent IS NOT NULL
GROUP BY DATE_FORMAT(`date`, '%Y-%m')
ORDER BY Month;

-- ORIGINAL ANALYSIS 5
-- Southeast Asia COVID-19 Comparison
SELECT
    location,
    population,
    MAX(CAST(total_cases AS SIGNED)) AS TotalCases,
    MAX(CAST(total_deaths AS SIGNED)) AS TotalDeaths,

    ROUND(
        (
            MAX(CAST(total_cases AS SIGNED))
            / NULLIF(population, 0)
        ) * 100,
        2
    ) AS PercentPopulationInfected,

    ROUND(
        (
            MAX(CAST(total_deaths AS SIGNED))
            / NULLIF(MAX(CAST(total_cases AS SIGNED)), 0)
        ) * 100,
        2
    ) AS DeathPercentage

FROM PortofolioProject.coviddeaths_clean
WHERE location IN (
    'Indonesia',
    'Malaysia',
    'Singapore',
    'Thailand',
    'Philippines',
    'Vietnam',
    'Cambodia',
    'Myanmar',
    'Laos',
    'Brunei'
)
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- ORIGINAL ANALYSIS 6
-- Vaccination Progress in Indonesia

WITH VaccinationProgress AS (
    SELECT
        dea.continent,
        dea.location,
        dea.`date`,
        dea.population,
        vac.new_vaccinations,

        SUM(CAST(vac.new_vaccinations AS SIGNED))
            OVER (
                PARTITION BY dea.location
                ORDER BY dea.`date`
            ) AS RollingVaccinationDoses

    FROM PortofolioProject.coviddeaths_clean AS dea
    JOIN PortofolioProject.covidvaccinations_clean AS vac
        ON dea.location = vac.location
        AND dea.`date` = vac.`date`

    WHERE dea.continent IS NOT NULL
)

SELECT
    continent,
    location,
    `date`,
    population,
    new_vaccinations,
    RollingVaccinationDoses,

    ROUND(
        (RollingVaccinationDoses / NULLIF(population, 0)) * 100,
        2
    ) AS VaccinationDosesPer100People

FROM VaccinationProgress
WHERE location = 'Indonesia'
  AND new_vaccinations IS NOT NULL
ORDER BY `date`;
