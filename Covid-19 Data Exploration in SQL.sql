/* Covid-19 Data Exploration 

Skills Used: 
Aggregate Functions 
Converting Data Types
Joins
CTE's
Windows Functions
Temp Tables
Creating Views

*/

Select *
From master..CovidDeaths$
Where continent is not null
Order by 3,4



-- Select Data

Select location, date, total_cases, new_cases, total_deaths, population
From master..CovidDeaths$
Where continent is not null
Order by 1,2



-- What are the global statistics of cases and deaths?

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From master..CovidDeaths$
-- Where location like '%states%' 
Where continent is not null and total_cases is not null
Group by date
Order by 1,2



-- Which countries had the highest infection rates?

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPopulationPercentage
From master..CovidDeaths$
-- Where location like '%states%' 
Group by location, population
Order by InfectedPopulationPercentage desc



-- What is the percentage of a country's population infected with Covid-19 by date? 

Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
From master..CovidDeaths$
-- Where location like '%states%'
Order by 1,2



-- Which countries had the highest death counts?

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From master..CovidDeaths$
-- Where location like '%states%' 
Where continent is not null
Group by location
Order by TotalDeathCount desc



-- What is the likelihood of dying from Covid-19 by country?

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From master..CovidDeaths$
Where location like '%states%' and continent is not null
Order by 1,2



-- Which continents had the highest death count?

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From master..CovidDeaths$
-- Where location like '%states%' 
Where continent is not null
Group by continent
Order by TotalDeathCount desc



-- What amount of a country's population recieved at least one dose of the vaccine?

Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations, 
SUM(CONVERT(int, vaccines.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, 
deaths.date) as RollingVaccinationCount
From master..CovidDeaths$ deaths
Join master..CovidVaccinations$ vaccines
On deaths.location = vaccines.location and deaths.date = vaccines.date
Where deaths.continent is not null
Order By 2,3



-- Using CTE to perform calculaton on 'partition by' in previous query

With PopulationVsVaccinations (Continent, location, date, population, new_vaccinations, RollingVaccinationCount) 
as 
( 
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations, 
SUM(CONVERT(int, vaccines.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, 
deaths.date) as RollingVaccinationCount
From master..CovidDeaths$ deaths
Join master..CovidVaccinations$ vaccines
On deaths.location = vaccines.location and deaths.date = vaccines.date
Where deaths.continent is not null
)
Select *, (RollingVaccinationCount/population)*100
From PopulationVsVaccinations



-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingVaccinationCount numeric
)



Insert into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations, 
SUM(CONVERT(int, vaccines.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, 
deaths.date) as RollingVaccinationCount
From master..CovidDeaths$ deaths
Join master..CovidVaccinations$ vaccines
On deaths.location = vaccines.location and deaths.date = vaccines.date
Where deaths.continent is not null

Select *, (RollingVaccinationCount/population)*100
From #PercentPopulationVaccinated



-- Create views for visualizations

Create View GlobalStatistics as 
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From master..CovidDeaths$
-- Where location like '%states%' 
Where continent is not null and total_cases is not null
Group by date



Create View CountriesWithHighestInfectionRates as 
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPopulationPercentage
From master..CovidDeaths$
-- Where location like '%states%' 
Group by location, population



Create View CountryPopulationInfectionsbyDate as
Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
From master..CovidDeaths$



Create View CountriesWithHighestDeaths as
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From master..CovidDeaths$
-- Where location like '%states%' 
Where continent is not null
Group by location



Create View LikelihoodofDyingbyCountry as
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From master..CovidDeaths$
Where location like '%states%' and continent is not null



Create View ContinentsWithHighestDeathCount as 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From master..CovidDeaths$
-- Where location like '%states%' 
Where continent is not null
Group by continent



Create View PercentPopulationVaccinated as 
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations, 
SUM(CONVERT(int, vaccines.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, 
deaths.date) as RollingVaccinationCount
From master..CovidDeaths$ deaths
Join master..CovidVaccinations$ vaccines
On deaths.location = vaccines.location and deaths.date = vaccines.date
Where deaths.continent is not null


