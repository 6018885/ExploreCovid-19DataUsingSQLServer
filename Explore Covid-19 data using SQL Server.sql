SELECT * FROM Vaccination_Data;

SELECT * FROM Covid19_DeathStatistics;

SELECT  location,date,total_cases,new_cases,total_deaths,population

FROM Covid19_DeathStatistics
ORDER BY
    location,
    date;

ALTER TABLE Covid19_DeathStatistics
ALTER COLUMN total_deaths FLOAT;

ALTER TABLE Covid19_DeathStatistics
ALTER COLUMN total_cases FLOAT;

--Showing the DeathPercentage

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths / total_cases) * 100, 2) AS DeathPercentage
FROM Covid19_DeathStatistics
WHERE location LIKE '%jordan%' AND continent IS NOT NULL
ORDER BY location, date;


-- The rate of infection with the Covid 19 virus

SELECT location, date, total_cases, population, ROUND((total_cases / population) * 100, 2) AS InfectionRate
FROM Covid19_DeathStatistics
WHERE location LIKE '%jordan%' AND continent IS NOT NULL
ORDER BY location, date;


-- The highest infection rate in the world
SELECT
    location,
    population,
    MAX(total_cases) AS Totalcases,
    ROUND(MAX(total_cases / population) * 100, 2) AS PercentageOfCasesPerPopulation
FROM
    Covid19_DeathStatistics
WHERE
    continent IS NOT NULL
GROUP BY
    location,
    population
ORDER BY
    PercentageOfCasesPerPopulation DESC;


-- showing countries with highest death count per population

SELECT location, MAX(total_deaths) AS total_Deaths
FROM Covid19_DeathStatistics
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_Deaths DESC;



-- Sorting the number of deaths by continent and showing the Highest death per pupulation

SELECT continent, MAX(total_deaths) AS total_Deaths
FROM Covid19_DeathStatistics
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_Deaths DESC;


-- Global Deths Percentage

SELECT
    SUM(new_cases) AS Total_cases,
    SUM(new_deaths) AS Total_deaths,
    ROUND(SUM(new_deaths) / SUM(new_cases) * 100, 3) AS DeathPercentage
FROM
    Covid19_DeathStatistics
WHERE
    continent IS NOT NULL;


--Total number of people who took the vaccine

SELECT deth.continent,deth.location,deth.date,deth.population,vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY deth.location 
        ORDER BY deth.location, deth.date) AS PeopleWhoHaveBeenVaccinated
FROM
    Vaccination_Data vac JOIN Covid19_DeathStatistics deth
ON
    deth.location = vac.location
    AND deth.date = vac.date
WHERE
    deth.continent IS NOT NULL
    AND deth.location LIKE '%albania%'
--GROUP BY deth.location
ORDER BY
    deth.location,
    deth.date;



-- use CTE


WITH PopulVsVac (continent, location, date, population, new_vaccinations, PeopleWhoHaveBeenVaccinated)
AS
(
    SELECT
        deth.continent,
        deth.location,
        deth.date,
        deth.population,
        vac.new_vaccinations,
        SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY deth.location 
            ORDER BY deth.location, deth.date) AS PeopleWhoHaveBeenVaccinated
    FROM
        Vaccination_Data vac
    JOIN
        Covid19_DeathStatistics deth
    ON
        deth.location = vac.location
        AND deth.date = vac.date
    WHERE
        deth.continent IS NOT NULL
        AND deth.location LIKE '%JORDAN%'
)
SELECT
    *,
    ROUND((PeopleWhoHaveBeenVaccinated / population) * 100, 2) AS percentegpopvsvacc
--  MAX(ROUND((PeopleWhoHaveBeenVaccinated / population) * 100, 4)) OVER () AS MaxVaccinationPercentage
FROM
    PopulVsVac;


-- USE TEMP TABLE

DROP TABLE IF EXISTS #PercentPopVsVacc;
-- Create a temporary table
CREATE TABLE #PercentPopVsVacc
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    PeopleWhoHaveBeenVaccinated NUMERIC
);

INSERT INTO #PercentPopVsVacc
SELECT
    deth.continent,
    deth.location,
    deth.date,
    deth.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY deth.location 
        ORDER BY deth.location, deth.date) AS PeopleWhoHaveBeenVaccinated
FROM
    Vaccination_Data vac
JOIN
    Covid19_DeathStatistics deth
ON
    deth.location = vac.location
    AND deth.date = vac.date
WHERE
    deth.continent IS NOT NULL
    AND deth.location LIKE '%JORDAN%';

SELECT
    *,
    ROUND((PeopleWhoHaveBeenVaccinated / population) * 100, 2) AS percentegpopvsvacc
FROM
    #PercentPopVsVacc;



-----------------------
-- Create a view to visualize data Using (POWER BI)
-----------------------
CREATE VIEW DeathPercentage AS
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    ROUND((total_deaths / total_cases) * 100, 2) AS DeathPercentage
FROM
    [Covid19_DeathStatistics]
WHERE
    location LIKE '%jordan%' AND continent IS NOT NULL;
	--ORDER BY location, date;


-- Create a view to visualize infection rates
CREATE VIEW InfectionRate AS
SELECT
    location,
    date,
    total_cases,
    population,
    ROUND((total_cases / population) * 100, 2) AS InfectionRate
FROM
    [Covid19_DeathStatistics]
WHERE
    location LIKE '%jordan%' AND continent IS NOT NULL;
	--ORDER BY location, date;



-- Create a view to visualize the highest infection rate in the world
CREATE VIEW InfectionRateInTheWorld AS
SELECT
    location,
    population,
    MAX(total_cases) AS TotalCases,
    ROUND(MAX(total_cases / population) * 100, 2) AS PercentageOfCasesPerPopulation
FROM
    Covid19_DeathStatistics
WHERE
    continent IS NOT NULL
GROUP BY
    location,
    population;
	--ORDER BY
    -- PercentageOfCasesPerPopulation DESC;



-- Create a view to show countries with the highest death counts
CREATE VIEW HighestDeathPerCountry AS
SELECT
    location,
    MAX(total_deaths) AS TotalDeaths
FROM
    Covid19_DeathStatistics
WHERE
    continent IS NOT NULL --AND LOCATION  LIKE '%WORLD%'
GROUP BY
    location;
--order by total_Deaths desc


-- Create a view to show the highest death counts per continent
CREATE VIEW HighestDeathPerContinent AS
SELECT
    continent,
    MAX(total_deaths) AS TotalDeaths
FROM
    Covid19_DeathStatistics
WHERE
    continent IS NOT NULL
GROUP BY
    continent;
	--order by total_Deaths desc

-- Create a view to visualize the total number of people who took the vaccine
ALTER VIEW TotalPeopleTookVaccine AS
SELECT
    deth.continent,
    deth.location,
    deth.date,
    deth.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY deth.location
        ORDER BY deth.location, deth.date) AS PeopleWhoHaveBeenVaccinated
FROM
    Vaccination_Data vac
JOIN
    Covid19_DeathStatistics deth
ON
    deth.location = vac.location
    AND deth.date = vac.date
WHERE
    deth.continent IS NOT NULL;--and deth.location like '%albania%'
--GROUP BY deth.location
--order by 2,3
