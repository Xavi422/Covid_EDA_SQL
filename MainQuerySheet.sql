Use Covid19_EDA_Proj;


--Explore shape of dataset

--Number of columns
SELECT 
	COUNT(*) as num_of_cols
FROM 
	INFORMATION_SCHEMA.TABLES 
WHERE 
	TABLE_NAME = 'covid_19_data';

--Number of rows
SELECT 
	COUNT(*) as num_of_rows
FROM
	covid_19_data;


--Explore dataset
SELECT
	*
FROM covid_19_data;


---View Table Metadata
SELECT
	*
FROM
	INFORMATION_SCHEMA.COLUMNS
WHERE
	TABLE_NAME = 'covid_19_data';



--Date Range
SELECT
	MIN(CAST(date as DATE)) as 'from', MAX(CAST(date as DATE)) as 'to'
FROM
	covid_19_data;



-- NULL checking
SELECT
	location, new_cases, new_deaths, population
FROM
	covid_19_data
WHERE
	location IN ('United States', 'Canada') AND (new_deaths IS NULL OR new_cases IS NULL OR population IS NULL );


-- YoY Comparison of Total Covid Cases in Canada (January 1st to June 27th) for 2021 and 2022
SELECT
	location, SUM(new_cases) as yoy_total_2021,
	(SELECT SUM(new_cases)
	 FROM covid_19_data
	 WHERE location = 'Canada' AND (date BETWEEN '2022-01-01' AND '2022-06-27')) as yoy_total_2022
FROM 
	covid_19_data
WHERE
	location = 'Canada' AND (date BETWEEN '2021-01-01' AND '2021-06-27')
GROUP BY location;

--YTD Fatality Rate of Covid-19 in Canada
SELECT
	location, (SUM(CAST(new_deaths as INT))/SUM(new_cases))*100 as fatality_rate_pct
FROM
	covid_19_data
WHERE location = 'Canada' AND (date BETWEEN '2022-01-01' AND '2022-06-27')
GROUP BY location;

---YTD total covid-19 cases/population pct; US vs Canada
SELECT
	location, (SUM(new_cases)/population)*100 as total_cases_YTD
FROM
	covid_19_data
WHERE location IN ('United States', 'Canada') AND (date BETWEEN '2022-01-01' AND '2022-06-27')
GROUP BY location, population;