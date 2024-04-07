--SELECT cv.continent,cd.total_deaths  FROM CovidVaccinations as cv JOIN CovidDeaths as cd
--ON cv.continent = cd.continent WHERE cv.location = 'Argentina'

--Select * from CovidVaccinations  where location = 'Argentina' order by date

--SELECT location,date,total_cases,total_deaths, 
--CONVERT(VARCHAR(255),round((total_deaths/total_cases * 100),2)) + '%' as ratio
--FROM CovidDeaths
-- WHERE location = 'Afghanistan'
--order by 1,2


--SELECT location, date, population, total_cases, 
--CONVERT(VARCHAR(255),(population/total_cases * 100 )) + '%' as PopulatioVScases 
--from CovidDeaths
--order by 1,2

--ALTER TABLE CovidDeaths
--ALTER COLUMN new_cases FLOAT

--ALTER TABLE CovidDeaths
--ALTER COLUMN total_deaths FLOAT


--SELECT location,population,MAX(total_cases) AS HighestCases, MAX((total_cases/population * 100))
--AS casesVSpopulation from CovidDeaths GROUP BY location,population order by 4 DESC


--SELECT location,MAX(total_cases) AS MaxCases,population,MAX(total_deaths) 
--as maxDeaths,MAX(total_deaths/population * 100)
--as DeathsVSpopulation,MAX(total_deaths/total_cases * 100) as DeathsVSCases FROM CovidDeaths
--where continent is not null
--group by location,population
--order by DeathsVSCases desc

--select * from CovidDeaths where location = 'France'


----Breaking down by continent
--select continent,MAX(total_cases) from CovidDeaths
--where continent is not null group by 
--continent order by continent desc

--SELECT location,max(total_deaths) FROM CovidDeaths where 
--continent is null 
--group by location 
--order by location


----GLOBAL NUMBERS
--SELECT location,date,total_cases,total_deaths, 
--CONVERT(VARCHAR(255),round((total_deaths/total_cases * 100),2)) + '%' as ratio
--FROM CovidDeaths
-- WHERE continent IS NOT NULL
--order by 1,2

----ALTER TABLE CovidDeaths
----ALTER COLUMN new_deaths FLOAT

--SELECT SUM(new_cases) AS TOTAL_CASES,SUM(new_deaths) AS TOTAL_DEATHS,
--SUM(new_deaths)/SUM(new_cases) * 100 AS DEATHSvsCASES 
--FROM CovidDeaths

--SELECT MAX(total_cases),MAX(total_deaths),MAX(total_deaths)/MAX(total_cases) * 100 as DEATHSvsCASES FROM CovidDeaths



----total population vs vaccinations
--SELECT MAX(dea.population)as total_population,MAX(vac.total_vaccinations)as total_vaccinations,
--MAX(vac.total_vaccinations)/MAX(dea.population) * 100 as populationVSvaccination
--FROM CovidDeaths dea 
--join CovidVaccinations vac
--ON 
--	dea.location = vac.location
--and	dea.date = vac.date


--SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(vac.new_vaccinations)
--OVER(PARTITION BY dea.location order by dea.date) as sum_vaccinations
--FROM CovidDeaths dea join
--CovidVaccinations vac 
--ON dea.location = vac.location
--and dea.date = vac.date
--where dea.continent is not null

--SELECT 
--    dea.continent,
--    dea.location,
--    dea.date,
--    dea.population,
--    vac.new_vaccinations, 
--    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) as sum_vaccinations
--FROM 
--    CovidDeaths dea 
--JOIN
--    CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
--WHERE 
--    dea.continent IS NOT NULL and dea.location = 'kenya'


--ALTER TABLE CovidVaccinations
--ALTER COLUMN new_vaccinations bigint

--here is to calculate the summ of vaccinations in each country then total world wide

SELECT dea.location, SUM(new_vaccinations)
as total_vaccinations FROM CovidDeaths AS dea JOIN CovidVaccinations AS vac 
ON 
dea.location = vac.location
and 
dea.date = vac.date
where dea.continent is not null
group by dea.location;


--with PopvsVac (continent, location, date, population, new_vaccinations, sum_vaccinations)
--as
--(
--	SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(vac.new_vaccinations)
--	OVER(PARTITION BY dea.location order by dea.date) as sum_vaccinations
--	FROM CovidDeaths dea join
--	CovidVaccinations vac 
--	ON dea.location = vac.location
--	and dea.date = vac.date
--	where dea.continent is not null
--)

--Temp table
DROP TABLE IF EXISTS #tempvscac
CREATE TABLE #tempvscac(
	continent varchar(255),
	location varchar(255),
	date date,
	population Float,
	new_vaccinations bigint,
	sum_vaccinations bigint
)

INSERT INTO #tempvscac SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(vac.new_vaccinations)
	OVER(PARTITION BY dea.location order by dea.date) as sum_vaccinations
	FROM CovidDeaths dea join
	CovidVaccinations vac 
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

SELECT *,(sum_vaccinations/population * 100) FROM #tempvscac

---creating view to store data for later visualisazions


create view percentpopulationvaccinated as 
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(vac.new_vaccinations)
	OVER(PARTITION BY dea.location order by dea.date) as sum_vaccinations
	FROM CovidDeaths dea join
	CovidVaccinations vac 
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null


select * from percentpopulationvaccinated