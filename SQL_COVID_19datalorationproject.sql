/*Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types */

Select *
From covidds
Where continent is not null 
order by 3,4 

---------------------------------------------------------------------------------------------------------------------------------------------------
-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From covidds
Where continent is not null 
order by 1,2
---------------------------------------------------------------------------------------------------------------------------------------------------

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT 
    location,
    total_cases,
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM
    covidds
WHERE continent is not null -- and location like '%states%'
ORDER BY 1, 2
---------------------------------------------------------------------------------------------------------------------------------------------------

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS PercentPopulationInfected
FROM
    covidds
ORDER BY 1 , 2
GROUP BY location
---------------------------------------------------------------------------------------------------------------------------------------------------

-- lets see the death percentage in all the countries 

SELECT 
    location,
    SUM(total_cases) AS TotalCases,
    SUM(total_deaths) AS TotalDeaths,
    (SUM(total_deaths) / SUM(total_cases)) * 100 AS DeathPercentage
FROM
    covidds
WHERE
    continent IS NOT NULL
GROUP BY location
ORDER BY TotalCases DESC;
---------------------------------------------------------------------------------------------------------------------------------------------------

-- Countries with Highest Infection Rate compared to Population

SELECT 
    location,
    Population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM
    covidds
GROUP BY Location , Population
ORDER BY PercentPopulationInfected DESC
---------------------------------------------------------------------------------------------------------------------------------------------------

-- Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(Total_deaths AS SIGNED)) AS TotalDeathCount
FROM covidds
-- WHERE location LIKE 'India'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;
---------------------------------------------------------------------------------------------------------------------------------------------------

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population 

SELECT 
    continent,
    MAX(CAST(Total_deaths AS SIGNED)) AS TotalDeathCount
FROM
    covidds
WHERE
    continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;
---------------------------------------------------------------------------------------------------------------------------------------------------

-- GLOBAL NUMBERS
-- lets see all the cases and deaths and the percentage of deaths in the world

SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS SIGNED)) AS total_deaths,
    SUM(CAST(new_deaths AS SIGNED)) / SUM(New_Cases) * 100 AS DeathPercentage
FROM
    covidds
WHERE
    continent IS NOT NULL;
---------------------------------------------------------------------------------------------------------------------------------------------------
        
-- Total Population vs Vaccinations
-- Shows count of Population that has recieved at least one Covid Vaccine
-- joining the two tables

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM 
    covidvacs AS vac
        JOIN
    covidds AS dea ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL 
ORDER BY RollingPeopleVaccinated desc

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations,  RollingPeopleVaccinated) 
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS SIGNED)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM covidvacs AS vac
JOIN
covidds AS dea ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY RollingPeopleVaccinated desc
)
select *, (RollingPeopleVaccinated/Population)* 100  as VacinatedPerc from PopvsVac


