select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4
--select * from PortfolioProject..CovidVaccination
--order by 3,4

select Location, date, total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2
--Looking at Death Percentage
select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2
--looking at how percentage of population got infected
select Location, date, total_cases,population,(total_cases/population)*100 as PopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
order by 1,2
--Looking at which country has hisghest infection rate
select Location,  max(total_cases),population,max((total_cases/population))*100 as PopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
group by Location,population
order by PopulationInfected desc
--Showing country with highest death count per population
select Location,  max(cast (total_deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location
order by DeathCount desc
--Let's Break by Continent

-- Continent with Highest Death Count
select continent,  max(cast (total_deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by DeathCount desc

--Global Numbers
select SUM(new_cases)as Total_Cases,SUM(cast(new_deaths as int))as Total_Deaths, SUM(cast(New_Deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


-- Looking at Total Population and Vaccination
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated /population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--CTE
with PopvsVac (continent, location,date,population, new_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated /population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated /population)*100
from PopvsVac

--Temp Table

drop table if exists #PercentagePeopleVaccinated
create table #PercentagePeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentagePeopleVaccinated
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated /population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
select * ,(RollingPeopleVaccinated /population)*100
from #PercentagePeopleVaccinated


create view PercentageofPeopleVaccinated as
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated /population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from PercentageofPeopleVaccinated 