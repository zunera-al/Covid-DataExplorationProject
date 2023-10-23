

Select *
From PortfolioProject. .CovidDeaths
Where continent is not null
Order by 3,4

--select data that we are going to be using

Select location, date, total_cases,new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2


--looking at Total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

--select Location, date, total_cases, (total_deaths/total_cases))*100 as DeathPercentage
Select location, date, total_cases, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like'%states%'
Order by 1,2


--looking at total cases vs population
-- shows what percentage of population got Covid

Select location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like'%states%'
Order by 1,2

--Looking at countries with highest infection rate compared to population

Select location,population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like'%states%'
Group by location, population
Order by PercentPopulationInfected desc

-- showing countries with highest death count per population
-- cast to convert int
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like'%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc



Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like'%states%'
Where continent is null
Group by location
Order by TotalDeathCount desc


--let's break things down by continent
-- showing the continents with highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like'%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global numbers
Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like'%states%'
Where continent is not null
Group by date
Order by 1,2

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like'%states%'
Where continent is not null
--group by date
Order by 1,2


--looking at total population vs vaccinations
Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
Order by 2,3

--use CTE

With PopvsVac (continent,location, date,population, New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated

