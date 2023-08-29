select * from PortfolioProjects..CovidDeaths
where continent is not null
order by 3,4 

--select * from PortfolioProjects..CovidVaccinations 
--order by 3,4

--selecting data we are going to be using

select location,date,total_cases,new_cases,total_deaths,population 
from PortfolioProjects..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases Vs Total Deaths
--shows Chances of dying if you contract covid-19 in your Country
select location,date,total_cases,total_deaths,(CAST(total_deaths as float)/NULLIF(cast(total_cases as float),0))*100 as Total_deaths_percentage
from PortfolioProjects..CovidDeaths where location like '%states%' and continent is not null
order by 1,2

--Looking at the Total Cases VS The Population
--shows what percentage of Population got Covid-19
select location,date,population,total_cases,(CAST(total_cases as float)/NULLIF(cast(population as float),0))*100 as Total_cases_percentage
from PortfolioProjects..CovidDeaths 
--where location like '%states%'
where continent is not null
order by 1,2

--Looking at Countries With Highest Infection Rate Compared To Population
select location,population,max(total_cases) as highest_infection_count,max((CAST(total_cases as float)/NULLIF(cast(population as float),0)))*100 as Total_population_infected
from PortfolioProjects..CovidDeaths 
--where location like '%states%'
where continent is not null
group by location,population
order by Total_population_infected desc


--Showing Countries with Highest Death Count per Population
select location,max(cast(total_deaths as float)) as Total_death_count
from PortfolioProjects..CovidDeaths 
--where location like '%states%'
where continent is not null
group by location
order by Total_death_count desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--showing Continents with the Highest Death Count Per Population
select continent,max(cast(total_deaths as float)) as Total_death_count
from PortfolioProjects..CovidDeaths 
--where location like '%states%'
where continent is not null
group by continent
order by Total_death_count desc

select location,max(cast(total_deaths as float)) as Total_death_count
from PortfolioProjects..CovidDeaths 
--where location like '%states%'
where continent is null
group by location
order by Total_death_count desc



--Breaking Of Global Numbers

select date,sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_Deaths,
(sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100) as Deaths_Percentage
from PortfolioProjects..CovidDeaths
 where continent is not null
 group by date
order by 1,2

select sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_Deaths,
(sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100) as Deaths_Percentage
from PortfolioProjects..CovidDeaths
 where continent is not null
order by 1,2


--JOINING TABLES
select * From PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
on dea.location=vac.location
and dea.date =vac.date

--Looking at Total Population VS Vaccinations

   select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
From PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
on dea.location=vac.location
and dea.date =vac.date
where dea.continent is not null
order by 2,3

--Looking at Total Population VS Vaccinations with Sum(New_Vaccinations) Partitioned By Location

  select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
  sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by 
  dea.location,dea.date) as Rolling_Peoples_Vaccinated
From PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
on dea.location=vac.location
and dea.date =vac.date
where dea.continent is not null
order by 2,3


--USE CTE
with Population_VS_Vaccination(continent,Location,Date,Population,New_Vaccinations,Rolling_Peoples_Vaccinated)
as
(
 select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
  sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by 
  dea.location,dea.date) as Rolling_Peoples_Vaccinated
From PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
on dea.location=vac.location
and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)
select *,(Rolling_Peoples_Vaccinated/Population)*100 as Percentage_of_people_Vaccinated
from Population_VS_Vaccination


--USE TEMP Table
drop table if exists #Percent_Population_Vaccinated
Create table #Percent_Population_Vaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Peoples_Vaccinated numeric
)
Insert into #Percent_Population_Vaccinated
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
  sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by 
  dea.location,dea.date) as Rolling_Peoples_Vaccinated
From PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
on dea.location=vac.location
and dea.date =vac.date
where dea.continent is not null
--order by 2,3

select *,(Rolling_Peoples_Vaccinated/Population)*100 as Percentage_of_people_Vaccinated
from #Percent_Population_Vaccinated
order by 1,2,3


--Creating View To Store Data For Later Visulizations
Create view Total_Population_VS_Vaccinations as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
  sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by 
  dea.location,dea.date) as Rolling_Peoples_Vaccinated
From PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
on dea.location=vac.location
and dea.date =vac.date
where dea.continent is not null
--order by 2,3

CREATE VIEW Total_Pop_VS_Vacc as
 select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
From PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
on dea.location=vac.location
and dea.date =vac.date
where dea.continent is not null
--order by 2,3

create view Death_percentage as
select sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_Deaths,
(sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100) as Deaths_Percentage
from PortfolioProjects..CovidDeaths
 where continent is not null
--order by 1,2


create view Death_percentage1 as 
select date,sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_Deaths,
(sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100) as Deaths_Percentage
from PortfolioProjects..CovidDeaths
 where continent is not null
 group by date
--order by 1,2


Create view Total_death_Count_By_Location as 
select location,max(cast(total_deaths as float)) as Total_death_count
from PortfolioProjects..CovidDeaths 
--where location like '%states%'
where continent is null
group by location
--order by Total_death_count desc


Create view Total_death_count_by_continent as 
select continent,max(cast(total_deaths as float)) as Total_death_count
from PortfolioProjects..CovidDeaths 
--where location like '%states%'
where continent is not null
group by continent
--order by Total_death_count desc


Create view Highesht_infected_Countries as 
select location,population,max(total_cases) as highest_infection_count,max((CAST(total_cases as float)/NULLIF(cast(population as float),0)))*100 as Total_population_infected
from PortfolioProjects..CovidDeaths 
--where location like '%states%'
where continent is not null
group by location,population
--order by Total_population_infected desc


Create view Chances_Of_Dying_By_Covid_in_The_Country as
select location,date,total_cases,total_deaths,(CAST(total_deaths as float)/NULLIF(cast(total_cases as float),0))*100 as Total_deaths_percentage
from PortfolioProjects..CovidDeaths where location like '%states%' and continent is not null
--order by 1,2