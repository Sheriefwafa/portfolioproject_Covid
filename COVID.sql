SELECT * FROM `eminent-hall-382514.Covid.Covid_Deaths` 
ORDER BY 3,4
SELECT * FROM `eminent-hall-382514.Covid.Covid_Vaccinations` 


## Select the data that we are going to be using 

Select Location, date, new_cases, total_cases, total_deaths, population
From `eminent-hall-382514.Covid.Covid_Deaths` 
ORDER BY 1,2

## Looking at Total_Cases VS Total_deaths
## Shows liklihood of dying if you contract covid in your country


SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
From `eminent-hall-382514.Covid.Covid_Deaths`  
order by 1,2 


## Looking at Total_cases vs Population
## Shows what percentage of population got Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS Percentpopulationinfected
From `eminent-hall-382514.Covid.Covid_Deaths`  
order by 1,2 


##Looking at Countries with Highest infection rate compared to Population 


SELECT Location, population, MAX(total_cases) as Highestinfectioncount, MAX((total_cases/population))*100 as Percentpopulationinfected
From `eminent-hall-382514.Covid.Covid_Deaths` 
GROUP BY Location, population 
order by Percentpopulationinfected desc


## Showing countries with highest death count per population 


SELECT Location, MAX(total_deaths) as Totaldeathcount
From `eminent-hall-382514.Covid.Covid_Deaths`
where continent is not NULL 
and location not in ('World, Europian union', 'International')
GROUP BY Location
order by Totaldeathcount desc


## Showing continents with the Highest death count per population


select continent, MAX(total_deaths) AS Totaldeathcount
From `eminent-hall-382514.Covid.Covid_Deaths`
where continent is not NULL 
GROUP BY continent
order by Totaldeathcount desc


## Global Numbers


SELECT date, SUM(new_cases), ## (total_deaths/total_cases)*100 AS Deathpercentage
From `eminent-hall-382514.Covid.Covid_Deaths`  
where continent is not null
group by date
order by 1,2 

SELECT date, SUM(new_deaths), ## (total_deaths/total_cases)*100 AS Deathpercentage
From `eminent-hall-382514.Covid.Covid_Deaths`  
where continent is not null
group by date
order by 1,2 


SELECT date, SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as Deathpercentage
From `eminent-hall-382514.Covid.Covid_Deaths`  
where continent is not null
group by date
order by 1,2 

SELECT SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as Deathpercentage
From `eminent-hall-382514.Covid.Covid_Deaths`  
where continent is not null
## group by date
order by 1,2 



## Looking at Total population vs vaccination

select *
From `eminent-hall-382514.Covid.Covid_Deaths`  dea
join `eminent-hall-382514.Covid.Covid_Vaccinations` vac
ON dea.location = vac.location
and dea.date = vac.date


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated, (Rollingpeoplevaccinated/population)*100
From `eminent-hall-382514.Covid.Covid_Deaths`  dea
join `eminent-hall-382514.Covid.Covid_Vaccinations` vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3 




## USE CTE


with popvsvac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
AS 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated, ##(Rollingpeoplevaccinated/population)*100
From `eminent-hall-382514.Covid.Covid_Deaths`  dea
join `eminent-hall-382514.Covid.Covid_Vaccinations` vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
## order by 2,3 
)

select*, (Rollingpeoplevaccinated/population)*100
From popvsvac





## Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
