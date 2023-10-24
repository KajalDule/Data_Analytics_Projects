

select * from dbo.CovidDeaths$ order by 3,4;

--select* from dbo.CovidVaccinations$ order by 3,4;

-- select the data 

select location, date, total_cases, new_cases, total_deaths, population
 from dbo.CovidDeaths$ order by 1, 2;

 -- looking at  Total cases Vs Total Deaths
 -- shows likelyhood of dying if you contract covid in your country
 select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from dbo.CovidDeaths$ 
 where location like '%india%'
 order by 1, 2


  -- looking at  Total cases Vs Population
  -- shows that percentage of population got covid

  select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
  from dbo.CovidDeaths$
 where location like '%india%'
 and continent is not null
  order by 1, 2


  -- country with high infection rates?

  select location, Population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as 
  percentPopulationInfected  from dbo.CovidDeaths$
   where continent is not null
  group by location, Population
  order by percentPopulationInfected desc


  select * from dbo.CovidDeaths$ 
  where continent is not null
  order by 3,4 


  -- showing countries with Highest Death count per population

  select location, max(cast(total_deaths as int)) as TotalDeathCount
  from dbo.CovidDeaths$
   where continent is not null
  group by location
  order by TotalDeathCount desc

  -- showing countries with Highest Death count per population (with Continent)

  select continent, max(cast(total_deaths as int)) as TotalDeathCount
  from dbo.CovidDeaths$
   where continent is not null
  group by continent
  order by TotalDeathCount desc

  ---- 
  --select location, max(cast(total_deaths as int)) as TotalDeathCount
  --from dbo.CovidDeaths$
  -- where continent is null
  --group by location
  --order by TotalDeathCount desc

  -- showing continent with highest death count

  select continent, max(cast(total_deaths as int)) as TotalDeathCount
  from dbo.CovidDeaths$
  where continent is not null
  group by continent
  order by TotalDeathCount desc

  -- global numbers

  select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as Total_deaths, 
  sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
  from dbo.CovidDeaths$
 -- where location like '%States%'
  where continent is not null
  --group by date
  order by 1,2

  -- Total_Cases: 150574977	, Total Deaths : 3180206	Death_Percentage : 2.11204149810363

-- looking at Total Population vs vaccinations

  select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations ,
  sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
  --(RollingPeopleVaccinated/population)*100
  from 
  CovidDeaths$ dea join dbo.CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
 where dea.continent is not null
  order by 2,3

  -- use CTE

  with PopVsVac( continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
  as 
  (select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations ,
  sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
  --(RollingPeopleVaccinated/population)*100
  from 
  CovidDeaths$ dea join dbo.CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  -- order by 2,3
  )
  select*, (RollingPeopleVaccinated/population)*100 from PopVsVac

  -- TEMP Table
  DROP TABLE if exists #PercentPopulationVaccinated
  CREATE TABLE #PercentPopulationVaccinated
  (
  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )
  insert into #PercentPopulationVaccinated
  select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations ,
  sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
  --(RollingPeopleVaccinated/population)*100
  from 
  CovidDeaths$ dea join dbo.CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  -- order by 2,3

   select*, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated

   -- create a view  to store the data for later visualization

   create view PercentPopulationVaccinated as 
   select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations ,
  sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
  --(RollingPeopleVaccinated/population)*100
  from 
  CovidDeaths$ dea join dbo.CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3

  select * from PercentPopulationVaccinated