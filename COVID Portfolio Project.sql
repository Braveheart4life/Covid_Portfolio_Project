select * from coviddeaths$ 
select top 5 * from CovidVaccinations$
select * from ['owid-covid-data$']

select * from coviddeaths$ where continent is not NULL order by 3, 4


--1: Select Data that we are going to be using

    select [location], [date], total_cases, new_cases, total_deaths, population 
    from coviddeaths$
    order by 1,2


--2: Looking at the Total Cases vs Total Deaths
-- Shows the percentage of being killed by covid per country

select [location], [date], total_cases, total_deaths, (total_deaths/total_cases)* 100 as Percentage_deaths
    from coviddeaths$
    where [location] = 'canada'
    order by 1,2


--3: Total Cases vs Population
-- Shows the percentage of population with covid per country (Canada)

select [location], [date], total_cases, population, (total_cases/population)* 100 as Percentage_Infected_population
    from coviddeaths$
    where [location] = 'canada'
    order by 1,2


--4: Looking at countries with highest infected rate compared to poplulation

select [location], max(total_cases) as HighestInfectionCount, max((total_cases/population))* 100 as Percentage_Infected_population
    from coviddeaths$
    --where [location] = 'canada'
    group by  [location], population
    order by Percentage_Infected_population DESC


--5: Showing countries with the highest death count per population

select 
    [location], 
    population, 
    MAX(cast(total_deaths as int)) as Total_Death_Count, 
    round(max((total_deaths/total_cases))* 100,1) as Percentage_death_per_infected
from coviddeaths$
where continent is not null --this 'WHERE' clause is used because continent with no null values excludes asia, africa, europe, etc
group BY [location], population
order by Total_Death_Count DESC 


--6: lets break it down by continent

    select 
        continent,  
        MAX(cast(total_deaths as int)) as Total_Death_Count
    from coviddeaths$
    where continent is not NULL 
    group BY continent
    order by Total_Death_Count DESC 


--7: showing continents with the highest death count per population

select 
    continent, 
    max(cast(total_deaths as int)) as total_deaths
from coviddeaths$ 
where continent is not NULL
and total_deaths is not null
group by continent
order by total_deaths DESC

--8: ICU numbers per country
select
    [location] AS Country,
     sum(cast(icu_patients as int)) as Total_ICU_Patients
from coviddeaths$ 
where icu_patients is not null
group by [location]

--9: Total new cases vs total deaths overtime
   
select 
--cast(date as DATE) as date,
    SUM(new_cases) as NewCases, 
    SUM(cast(new_deaths as int)) as Sum_Of_Death,
    round(SUM(cast(new_deaths as int))/SUM(new_cases) * 100,1) as percent_of_deaths
from coviddeaths$
where continent is not NULL
and new_cases is not NULL
--group by DATE
order by 1,2


--10: Countries Total Population vs Vaccinated Population

SELECT 
        CD.LOCATION,
        MAX(CD.POPULATION) AS TOTAL_POPULATION, 
        MAX(CAST(CV.PEOPLE_VACCINATED AS FLOAT)) AS TOTAL_VACCINATED,
        ROUND((MAX(CAST(CV.PEOPLE_VACCINATED AS FLOAT))*1.0)/(MAX(CD.POPULATION))* 100,1) AS PERCENTAGE_VACCINATED
FROM COVIDDEATHS$ CD 
JOIN COVIDVACCINATIONS$ CV
ON CD.LOCATION = CV.LOCATION
AND CD.DATE = CV.DATE 
WHERE CV.PEOPLE_VACCINATED IS NOT NULL
AND CD.LOCATION NOT LIKE '%INCOME'
GROUP BY CD.LOCATION 
ORDER BY 1


--11: TOTAL POPULATION VS NEW_VACCINATIONS; use cte 

WITH NewTest (continent, location, date, population, new_vaccinations, Increasing_Vac_Count) 
as
(
    SELECT 
        CD.CONTINENT,
        CD.LOCATION,
        CD.DATE,
        CD.POPULATION AS TOTAL_POPULATION,
        CV.NEW_VACCINATIONS,
        SUM(CONVERT(BIGINT, CV.NEW_VACCINATIONS)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION, CD.DATE) AS Increasing_Vac_Count
        --(Increasing_Vac_Count/POPULATION) * 100
    FROM COVIDDEATHS$ CD 
    JOIN COVIDVACCINATIONS$ CV
        ON CD.LOCATION = CV.LOCATION
        AND CD.DATE = CV.DATE 
    WHERE CD.CONTINENT IS NOT NULL
    AND CV.NEW_VACCINATIONS IS NOT NULL
        AND CD.LOCATION NOT LIKE '%INCOME'
    --ORDER BY 2,3
) 
SELECT * FROM NewTest



--12: CREATE A TEMPORARY TABLE to store CTE
DROP Table if exists #PERCENT_POPULATION_VACCINATION
CREATE TABLE #PERCENT_POPULATION_VACCINATION
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
Increasing_Vac_Count numeric
)
insert into #PERCENT_POPULATION_VACCINATION
SELECT 
        CD.CONTINENT,
        CD.LOCATION,
        CD.DATE,
        CD.POPULATION AS TOTAL_POPULATION,
        CV.NEW_VACCINATIONS,
        SUM(CONVERT(BIGINT, CV.NEW_VACCINATIONS)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION, CD.DATE) AS Increasing_Vac_Count
        --,(Increasing_Vac_Count/POPULATION) * 100
    FROM COVIDDEATHS$ CD 
    JOIN COVIDVACCINATIONS$ CV
        ON CD.LOCATION = CV.LOCATION
        AND CD.DATE = CV.DATE 
    WHERE CD.CONTINENT IS NOT NULL
    AND CV.NEW_VACCINATIONS IS NOT NULL
        AND CD.LOCATION NOT LIKE '%INCOME'
    --ORDER BY 2,3   
    
    SELECT *, 
    (Increasing_Vac_Count/POPULATION) * 100
    FROM #PERCENT_POPULATION_VACCINATION
    
--13: create view to store data for visualizations    
CREATE VIEW Percent_of_Vacc_Population AS
SELECT 
        CD.CONTINENT,
        CD.LOCATION,
        CD.DATE,
        CD.POPULATION AS TOTAL_POPULATION,
        CV.NEW_VACCINATIONS,
        SUM(CONVERT(BIGINT, CV.NEW_VACCINATIONS)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION, CD.DATE) AS Increasing_Vac_Count
        --(Increasing_Vac_Count/POPULATION) * 100
    FROM COVIDDEATHS$ CD 
    JOIN COVIDVACCINATIONS$ CV
        ON CD.LOCATION = CV.LOCATION
        AND CD.DATE = CV.DATE 
    WHERE CD.CONTINENT IS NOT NULL
    AND CV.NEW_VACCINATIONS IS NOT NULL
        AND CD.LOCATION NOT LIKE '%INCOME'
    --ORDER BY 2,3

select * FROM Percent_of_Vacc_Population
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   
     