Select *
From coviddb..CovidDeaths
Where continent is not null 
order by 3,4

Select *
From coviddb..covidvaccinations
Where continent is not null 
order by 3,4


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country


SELECT location, date,total_cases,total_deaths,(CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
FROM
    coviddb..CovidDeaths
WHERE
    location LIKE '%states%'
    AND continent IS NOT NULL
ORDER BY
    1, 2;

	-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From coviddb..CovidDeaths
Where location like '%india%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddb..CovidDeaths
--Where location like '%india%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From coviddb..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From coviddb..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From coviddb..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

WITH popvsvac(continent,location,date,population,new_vaccinations,rollingpeoplevaccinated) 
as 
	(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location order by dea.location,dea.date)	as rollingpeoplevaccinated
 -- , (rollingpeoplevaccinated/population)*100
FROM coviddb..coviddeaths AS dea
JOIN coviddb..covidvaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
select * , (RollingPeopleVaccinated/Population)*100 as percentage_total
from popvsvac
 

 -- Using Temp Table to perform Calculation on Partition By in previous quer

 drop table if exists #percentpopulationvaccinated
 create table #percentpopulationvaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric , 
 new_vaccinations numeric,
 rollingpeoplevaccinated numeric
 )


 insert into  #percentpopulationvaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location order by dea.location,dea.date)	as rollingpeoplevaccinated
 -- , (rollingpeoplevaccinated/population)*100
FROM coviddb..coviddeaths AS dea
JOIN coviddb..covidvaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

select * , (RollingPeopleVaccinated/Population)*100 as percentage_total
from #percentpopulationvaccinated


--create view to store data for later visualtions


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddb..coviddeaths as dea 
Join coviddb..covidvaccinations as vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated 