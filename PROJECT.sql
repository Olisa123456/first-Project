use portiofolio;
SELECT 
    *
FROM
    covid_deaths;
SELECT 
    *
FROM
    portiofolio.covid_deaths
    where continent is not null
    order by 3,4;
    
    SELECT 
    *
FROM
    portiofolio.covid_vaccinations
    where continent is not null
    order by 3,4;
    
    
    select location, date, total_cases, new_cases, total_deaths, population
    from portiofolio.covid_deaths;
    
    #total cases verse total deaths
    
    select location, date, total_cases,  total_deaths,(total_deaths/total_cases)*100 as DeathPercent
    from portiofolio.covid_deaths;
    
    select location, date, total_cases,  total_deaths,(total_deaths/total_cases)*100 as DeathPercent
    from portiofolio.covid_deaths
    where location like '%Nigeria%'
    and continent is not null;
    
    #total cases verses population, shows what percentage got covid
    select location, date, population,total_cases, (total_cases/population)*100 as populationpercent
    from portiofolio.covid_deaths
    where location like '%Nigeria%'
    and continent is not null;
    
    #what country has the most infection rate compared to population.
     select location, population,max(total_cases) as HIC, max((total_cases/population))*100 as populationpercent
    from portiofolio.covid_deaths
    #where location like '%Nigeria%'
    group by location, population
    order by populationpercent desc;
    
	-- convert total deaths from varchar to int
   -- update portiofolio.covid_deaths
    -- set total_deaths = null
   -- where not total_deaths regexp '^[0-9]+$';
    
    -- alter table portiofolio.covid_deaths
   -- modify column total_deaths INT;

        
     #showing the countries with the highest death count per population
     select location, max(total_deaths) as totaldeathcount
     from portiofolio.covid_deaths
     where continent is not null
     group by location
    order by totaldeathcount desc;
 
 set @@global.sql_mode:=replace(@@global.sql_mode,'only_FULL_GROUP_BY', '');  
 SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
    
    #analyzing by continent
    select continent, max(cast( total_deaths as signed)) as totaldeathcount
     from portiofolio.covid_deaths
     where continent is not null
     group by continent
    order by total_deaths desc;
    
    select continent, max(cast( total_deaths as signed)) as totaldeathcount
     from portiofolio.covid_deaths
     where continent is null
     group by continent
    order by total_deaths desc;
    
       select location, max(cast( total_deaths as signed)) as totaldeathcount
     from portiofolio.covid_deaths
     where continent is not null
     group by location
    order by totaldeathcount desc; 
    
    #showing the continent with the highest death count per population
    select continent,max(cast(total_deaths as signed)) as totaldeathcount
    from portiofolio.covid_deaths
    where continent is not null
    group by continent
    order by totaldeathcount desc;
    
    #global numbers
    select sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, sum(new_deaths)/sum(new_cases)*100 as Deathpercentage
    from portiofolio.covid_deaths
    where continent is not null
    group by date
    order by 1,2;
    
    
    select * from portiofolio.covid_deaths Death
    join portiofolio.covid_vaccinations Vaccine
    on Death.location = Vaccine.location
    and Death.date = Vaccine.date;
    
    #looking at total population vs vaccination
    select D.continent, D.location, D.date,D.population,V.new_vaccinations, SUM(V.new_vaccinations) OVER (partition by D.location order by D.location, D.date) as rollingpeoplevaccine
   from portiofolio.covid_deaths D
    join portiofolio.covid_vaccinations V
    on D.location = V.location
    and D.date = V.date
    where D.continent is not null
    order by 2,3;
    
    
    #using CTE 
    with popvsvac (continent, location, date, population,New_vaccinations, rollingpeoplevaccine)
    as
    (
    select D.continent, D.location, D.date,D.population,V.new_vaccinations, SUM(V.new_vaccinations) OVER (partition by D.location order by D.location, D.date) as rollingpeoplevaccine
   from portiofolio.covid_deaths D
    join portiofolio.covid_vaccinations V
    on D.location = V.location
    and D.date = V.date
    where D.continent is not null
    )
select * , (rollingpeoplevaccine/population)*100 from popvsvac;  

#temp table
drop table percentpopulationvaccinated;
create table percentpopulationvaccinated
(
continent varchar (255),
location varchar (255),
Date datetime,
population int,
new_vaccinations int,
Rollingpeoplevaccine int
);

 insert into percentpopulationvaccinated
 
 select D.continent, D.location, D.date,D.population,V.new_vaccinations, sum(V.new_vaccinations) OVER (partition by D.location order by D.location, D.date) as rollingpeoplevaccine
   from portiofolio.covid_deaths D
    join portiofolio.covid_vaccinations V
    on D.location = V.location
    and D.date = V.date
    where D.continent is not null
    ;
    select * , (rollingpeoplevaccine/population)*100 from percentpopulationvaccinated;  
-- Ccreating view to store data later

drop view percentpopulationvaccinated;
create view percentpopulationvaccinateds as
select D.continent, D.location, D.date,D.population,V.new_vaccinations, SUM(V.new_vaccinations) OVER (partition by D.location order by D.location, D.date) as rollingpeoplevaccine
   from portiofolio.covid_deaths D
    join portiofolio.covid_vaccinations V
    on D.location = V.location
    and D.date = V.date
    where D.continent is not null;
     
    select * from percentpopulationvaccinateds;
    