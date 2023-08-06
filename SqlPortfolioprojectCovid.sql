Select *
From [Portfolio Project]..Coviddeaths
where continent is not null 
Order By 3,4

Select *
From [Portfolio Project]..covidvaccinations
where continent is not null	
Order By 3,4


--Looking at death rate (total cases vs total deaths)

--changing the data type of some columns as we need to perform divisions 

Alter table [Portfolio Project]..coviddeaths
Alter column total_cases float 

Alter table [Portfolio Project]..coviddeaths
Alter column total_deaths float

Select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as 'death_rate(%)'
From [Portfolio Project]..Coviddeaths
Where location like '%australia%'
Order By 1,2

--It shows the likelihood of dying if contracted Covid in any country

--Looking at the total cases vs population

Select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as 'Cases_per_population'
From [Portfolio Project]..Coviddeaths
Where location like '%australia%'
Order By 1,2

--shows what percentage of the total population contracted Covid in any country

--looking for countries with the highest infection rate

Select location, population, max(total_cases) as overalltotalcases, max((total_cases/population))*100 as 'MaxCases_per_population'
From [Portfolio Project]..Coviddeaths
Group by location, population
Order By MaxCases_per_population desc

--showing the countires with the highest cases and death count

Select location, max(total_cases) as Totalcasescount, max(total_deaths) as Totaldeathcount
From [Portfolio Project]..Coviddeaths
where continent is not null
Group by location
Order By Totalcasescount desc

--showing the continents with the highest cases and death count

Select location, max(total_cases) as Totalcasescount, max(total_deaths) as Totaldeathcount
From [Portfolio Project]..Coviddeaths
where continent is null and location not like'%income%'
Group by location
Order By Totalcasescount desc

-- showing the working class with highest cases and death count

Select location, max(total_cases) as Totalcasescount, max(total_deaths) as Totaldeathcount
From [Portfolio Project]..Coviddeaths
where continent is null and location like'%income%'
Group by location
Order By Totalcasescount desc

--Working on both coviddeaths and covidvaccinations table

--looking at the total population vs total vaccination

Alter table [Portfolio Project]..covidvaccinations
Alter column new_vaccinations float 

Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dth.location Order by dth.location, dth.date) as Rollingvaccinated
from [Portfolio Project]..coviddeaths dth
join [Portfolio Project]..covidvaccinations vac
on dth.location = vac.location
and dth.date = vac.date 
where dth.continent is not null 
order by 2,3

--using CTE, calculating the vaccination rate over time

With popuvsvac (continent, location, date, population, new_vaccinations, Rollingvaccinated)
as
(
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dth.location Order by dth.location, dth.date) as Rollingvaccinated
from [Portfolio Project]..coviddeaths dth
join [Portfolio Project]..covidvaccinations vac
on dth.location = vac.location
and dth.date = vac.date 
where dth.continent is not null
--order by 2,3
)

select*, (Rollingvaccinated/population) *100 as vacrate
from popuvsvac


--Using TEMP table


Drop Table if exists #VaccinationRate
Create Table #VaccinationRate
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinatinos float,
Rollingvaccinated float)

Insert into #VaccinationRate 

Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dth.location Order by dth.location, dth.date) as Rollingvaccinated
from [Portfolio Project]..coviddeaths dth
join [Portfolio Project]..covidvaccinations vac
on dth.location = vac.location
and dth.date = vac.date 
--where dth.continent is not null

select *
from #VaccinationRate


--creating view for visualization purpose later

Create view Vaccinationrate as
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dth.location Order by dth.location, dth.date) as Rollingvaccinated
from [Portfolio Project]..coviddeaths dth
join [Portfolio Project]..covidvaccinations vac
on dth.location = vac.location
and dth.date = vac.date 
where dth.continent is not null


Select *
from Vaccinationrate 