select *
from PortifolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortifolioProject..CovidVaccinations
--order by 3,4

--select the data that are we going to be using 
select location,date,total_cases,new_cases,total_deaths,population
from PortifolioProject..CovidDeaths
order by 1,2

-- Looking at Total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
select  location,total_cases,total_deaths,date,round((total_deaths/total_cases)*100,2) as Deathpercentage
from PortifolioProject..CovidDeaths
where location  like 'Tuni%'
order by 1,2

--Looking at total cases vs population
--shows what percentage of population got covid
select  location,total_cases,population,date,round((total_cases/population)*100,2) as casespercentage
from PortifolioProject..CovidDeaths
--where location  like 'Tuni%'
order by 1,2

--country with the highest infection
select  location,max(total_cases) as HighestInfectionCount,population,max(round((total_cases/population)*100,2)) as PercentPopulationInfected
from PortifolioProject..CovidDeaths
--where location  like 'Tuni%'
group by population,location
order by HighestInfectionCount desc

-- let's break thinks down by continent 
select continent ,max(cast(total_deaths as int))  as HighestDeathCount
from PortifolioProject..CovidDeaths
--where locatcontinention  like 'Tuni%'
where continent is not null
group by continent
order by HighestDeathCount desc






--showing countries with highest death count per population
select  location,max(cast(total_deaths as int))  as HighestDeathCount
from PortifolioProject..CovidDeaths
--where location  like 'Tuni%'
where continent is not null
group by location
order by HighestDeathCount desc

--showing continents with the highest death count per population

select continent ,max(cast(total_deaths as int))  as HighestDeathCount
from PortifolioProject..CovidDeaths
--where locatcontinention  like 'Tuni%'
where continent is not null
group by continent
order by HighestDeathCount desc


--global numbers
select  sum(new_cases) as total_new_cases,sum(cast(new_deaths as int)) as total_new_death,sum(cast(new_deaths as int))/sum(new_cases) as Deathpercentage
from PortifolioProject..CovidDeaths
--where location  like 'Tuni%'
where continent   is not null  
--group by date 
order by 1,2


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeapleVaccinated
--,(RollingPeapleVaccinated/population)*100 
from PortifolioProject..CovidDeaths dea 
JOIN 
 PortifolioProject..CovidVaccinations vac
 ON dea.location=vac.location and dea.date=vac.date

 where dea.continent   is not null  

 order by 2,3


 --use CTE

 with PopvsVac(continent,location,date,population,new_vaccination,RollingPeapleVaccinated)
 as 

(
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeapleVaccinated
--,(RollingPeapleVaccinated/population)*100 
from PortifolioProject..CovidDeaths dea 
JOIN 
 PortifolioProject..CovidVaccinations vac
 ON dea.location=vac.location and dea.date=vac.date

where dea.continent   is not null  

--order by 2,3
)
select *,(RollingPeapleVaccinated/population)*100  
from PopvsVac


---Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeapleVaccinated numeric

)
insert into #PercentPopulationVaccinated 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeapleVaccinated
--,(RollingPeapleVaccinated/population)*100 
from PortifolioProject..CovidDeaths dea 
JOIN 
 PortifolioProject..CovidVaccinations vac
 ON dea.location=vac.location and dea.date=vac.date

--where dea.continent   is not null  
select *,(RollingPeapleVaccinated/population)*100  
from #PercentPopulationVaccinated



--------------creating view to store data for later visualizations

create View PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeapleVaccinated
--,(RollingPeapleVaccinated/population)*100 
from PortifolioProject..CovidDeaths dea 
JOIN 
 PortifolioProject..CovidVaccinations vac
 ON dea.location=vac.location and dea.date=vac.date
where dea.continent   is not null 
--order by 2,3



select * 
from PercentPopulationVaccinated