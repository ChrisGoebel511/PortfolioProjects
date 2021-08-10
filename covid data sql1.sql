Select*	
From [Portfolio Project]..[Covid Deaths]
Where continent is not null
order by 3,4

--Select*	
--From [Portfolio Project]..[Covid Vacc]
--Where continent is not null
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..[Covid Deaths]
Where continent is not null
order by 1,2

--Total Cases vs Total Deaths
--Shows chances of death by country
Select Location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
From [Portfolio Project]..[Covid Deaths]
Where location like '%states%'
and continent is not null
order by 1,2


--Total Cases vs Population

Select Location,continent, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..[Covid Deaths]
Where location like '%states%'
--and continent is not null
order by 1,2


--Highest inf rate Countries

Select Location, population, MAX(total_cases) as HighestInfectioncount, Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..[Covid Deaths]
--Where location like '%states%'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


--Contrast Highest Death Count Per Pop.

Select Location, population, MAX(cast(total_deaths as int)) as Totaldeathcount
From [Portfolio Project]..[Covid Deaths]
--Where location like '%states%'
Where continent is not null
Group by Location, Population
order by Totaldeathcount desc

--Now By Continent

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[Covid Deaths]
--Where location like '%states&%'
Where continent is null
Group by location
order by TotalDeathCount desc


--Continents with highest death count

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[Covid Deaths]
--Where location like '%states&%'
Where continent is null
Group by location
order by TotalDeathCount desc

--Global


Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From [Portfolio Project]..[Covid Deaths]
--Where location like '%states%'
where continent is not null
group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From [Portfolio Project]..[Covid Deaths]
--Where location like '%states%'
where continent is not null
--group by date
order by 1,2


Select*
From [Portfolio Project]..[Covid Deaths] dea
Join [Portfolio Project]..[Covid Vacc] vac
	On dea.location = vac.location
	and dea.date = vac.date

	--Loking at total pop vs vacc

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..[Covid Deaths] dea
Join [Portfolio Project]..[Covid Vacc] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--cte
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..[Covid Deaths] dea
Join [Portfolio Project]..[Covid Vacc] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--temptable


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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..[Covid Deaths] dea
Join [Portfolio Project]..[Covid Vacc] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--create view for later visualization


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..[Covid Deaths] dea
Join [Portfolio Project]..[Covid Vacc] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..[Covid Deaths] dea
Join [Portfolio Project]..[Covid Vacc] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select*
From PercentPopulationVaccinated