Select *
From [Portfolio Cov19]..Sheet1$
Where continent is not null
Order by 3,4

--select data we are using

Select location , date , total_cases , total_deaths , population
From [Portfolio Cov19].dbo.Sheet1$
 --order data by selected columns
Order by 1,2            

-- looking at ratio deaths vs cases in a given month
-- cast (expression as int) convert to interger to carry out / operator

Select location , date , total_cases , total_deaths , (cast(total_deaths as float)/cast(total_cases as float))*100 as ratiocasevsdeaths
From [Portfolio Cov19].dbo.Sheet1$
Where location like 'Australia'
Order by 1,2

-- looking at population that contracted covid 

Select location , date , total_cases , population , (cast(total_cases as float)/cast(population as float))*100 as ratiopopulationinfect
From [Portfolio Cov19].dbo.Sheet1$
Where location like '%kingdom'
Order by 1,2 

-- countres highest infection rates vs population


Select location , population , Max(total_cases) as highestinfectcount  , Max(((cast(total_cases as float))/cast(population as float)))*100 as ratiomaxcase_vs_population
From [Portfolio Cov19].dbo.Sheet1$
--Where location like '%kingdom'
Group by population , location
Order by 4 desc

Select location , population , Max(cast(total_cases as int)) as highestinfectcount  , Max(total_cases)/population*100
From [Portfolio Cov19].dbo.Sheet1$
--Where location like '%states%'
Group by population , location
Order by 4 desc

-- countries highest death vs populattion 

Select location , population , MAX (cast(total_deaths as int)) as totaldeathcount  , (MAX(total_deaths)/population)*100 as deathvspop
From [Portfolio Cov19].dbo.Sheet1$
Where continent is not null
--Where location like '%states%'
Group by population , location
Order by 3 desc

-- showing breakdown by continent

Select location, MAX (cast(total_deaths as int)) as totaldeathcount 
From [Portfolio Cov19].dbo.Sheet1$
Where continent is null
--Where location like '%states%'
Group by location
Order by 2 desc 

--global values

Select Sum(new_cases) as totalcases ,SUM(new_deaths) as totaldeaths,SUM(cast(new_deaths as float))/SUM(cast (new_cases as float))*100 as GLOBALdeathPercent
From [Portfolio Cov19].dbo.Sheet1$
--Where location like 'Australia'
where continent is not null
Order by 1,2



---- JOIN two databases example 
----Select *
----From [Portfolio Cov19]..Sheet1$ dea
----Join [Portfolio Cov19]..Sheet2$ vac
--ON dea.location = vac.location
--and dea.date = vac.date

------------------------------ looking at total popultaion vs vaccination
--partition splits the sum of vaccination between countries

Select continent , location ,date, population,new_vaccinations, 
sum(Convert(float ,new_vaccinations)) OVER (Partition by location Order by date) as rollingcount_vacinated

-- ways to use your variable such as rolling count in equations are not possible unless CTE or temp tables
--,(rollingcount_vacinated/population)*100
From [Portfolio Cov19]..Sheet1$ 
Where continent is not null
Order by 2,3 


--CTE Version to add rollingcount_vacinated as a variable to enable calculation 
-- Using With Syntax
-- CTE colums has to match main() columns 

With Popvsvac ( continent,location,date , population, new_vaccinations,rollingcount_vacinated)
as 
(
Select continent , location ,date, population,new_vaccinations, 
sum(Convert(float ,new_vaccinations)) OVER (Partition by location Order by date) as rollingcount_vacinated
--(rollingcount_vacinated/population)*100
From [Portfolio Cov19]..Sheet1$ 
Where continent is not null
--Order by 2,3 
)
Select *, (rollingcount_vacinated/population)*100 as percentagevacinated
From Popvsvac



-- Temp Table version
-- table is created with variable then inserted by data then temp table is called upon to calculate whats needed 
-- Drop table is needed at the beginning as it deletes the table so it can be recreated when executed again if there are changes.


Drop table if exists #percentofpopualtionvaccinated
Create table #percentofpopualtionvaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
Rollingcount_vacinated numeric)

Insert into #percentofpopualtionvaccinated

Select continent , location ,date, population,new_vaccinations, 
sum(Convert(float ,new_vaccinations)) OVER (Partition by location Order by date) as rollingcount_vacinated
--(rollingcount_vacinated/population)*100
From [Portfolio Cov19]..Sheet1$ 
--Where continent is not null
--Order by 2,3 

Select *, (rollingcount_vacinated/population)*100 as percentagevacinated
From #percentofpopualtionvaccinated

-- Createing view for later visulisations

Create View PercentPopulationVacinated as 
Select continent , location ,date, population,new_vaccinations, 
sum(Convert(float ,new_vaccinations)) OVER (Partition by location Order by date) as rollingcount_vacinated
--(rollingcount_vacinated/population)*100
From [Portfolio Cov19]..Sheet1$ 
Where continent is not null
--Order by 2,3 

-- Created a View that is permanent which is not the same as a temp table

Select* , (rollingcount_vacinated/population)*100 as PercentPopulationVacinated
From PercentPopulationVacinated