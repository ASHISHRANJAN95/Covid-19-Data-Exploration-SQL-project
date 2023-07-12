

---select the data that we are going to be using 

--select location, date, total_cases, new_cases, total_deaths, population
--From portfolioproject..CovidDeaths
--order by 1,2

--Looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From portfolioproject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at the total cases vs population 
-- shows what percentage of populatyion got covid

select location, date, total_cases, population, (total_cases/population)*100 as Deathpercentage
From portfolioproject..CovidDeaths
--where location like '%india%'
order by 1,2

-- looking at counties with highest infection rate compared to population

select location,Population,date,MAX( total_cases) as Highestinfectioncount, MAX((total_cases/population))*100 as percentpopulationinfected
From portfolioproject..CovidDeaths
--where location like '%states%'
Group by location, population, date
order by percentpopulationinfected desc 

-- showing countries with highest death counts per population

select Location,MAX(cast (Total_deaths as int)) as totaldeathcount
From portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by totaldeathcount desc 

-- lets break things down by continent 

select location,MAX(cast (Total_deaths as int)) as totaldeathcount
From portfolioproject..CovidDeaths
--where location like '%states%'
where continent is null
and location not in ('world', 'European Union', 'International')
Group by location
order by totaldeathcount desc 

--Lets break things down by continent 

select continent,MAX(cast (Total_deaths as int)) as totaldeathcount
From portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by totaldeathcount desc

--global Numbers

select  date, SUM(new_cases) as Total_cases,SUM(cast (new_deaths as int)) as Total_deaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100  as Deathpercentage
From portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

select SUM(new_cases) as Total_cases,SUM(cast (new_deaths as int)) as Total_deaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100  as Deathpercentage
From portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

-- looking at total population vs vaccination

select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
From portfolioproject..CovidDeaths dea
join portfolioproject..Covidvaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 1,2,3

  --Using CTE

  with popvsvac (continent,location,date, population,new_vaccinations, rollingpeoplevaccinated)
  as
  (
  select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
From portfolioproject..CovidDeaths dea
join portfolioproject..Covidvaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
 -- order by 1,2,3
  )
  select *, (rollingpeoplevaccinated/population)*100
  From popvsvac

  ---Using TEMP Table

  Drop table if exists #percentpopulationvaccinated
  create table #percentpopulationvaccinated
  (
  continent nvarchar (255),
  location nvarchar (255),
  date datetime,
  population numeric,
  new_vaccinated numeric,
  rollingpeoplevaccinated numeric
  )

  insert into #percentpopulationvaccinated
   select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
From portfolioproject..CovidDeaths dea
join portfolioproject..Covidvaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null

   select *, (rollingpeoplevaccinated/population)*100
  From #percentpopulationvaccinated

--- creating view to store data for later visualization

Create View 
percentpopulationvaccinatedview as 
 Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
From portfolioproject..CovidDeaths dea
join portfolioproject..Covidvaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
 -- order by 1,2,3

 select *
 from #percentpopulationvaccinated








