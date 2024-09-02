# Exploratory Data Analysis of a Covid-19 Dataset 

(source: https://ourworldindata.org/covid-deaths  last update: 28/06/2022)

More info: https://github.com/owid/covid-19-data/tree/master/public/data

**Motivation**: I recently tested positive for Covid-19 and decided to finally check out a covid-19 dataset to see what insights I can build from the data using SQL.

SQL Environment: Microsoft SQL Server Managment Studio (T-SQL)

## Importing Data
1. Create a database in SSMS
2. Open SQL Server Import and Export Wizard
3. Choose Microsoft Excel as data source and select Excel file
4. Choose SQL Server Native Client <version_no> as destination and select created database.
5. Select copy data from one or more tables or views
6. Select sheet containing relevant data
7. Click next to import data and finish


## First Look at Data
**NOTE**: the following queries are prefaced with `USE <database_name>;`

Firstly, let's take a glance at the dataset
```sql
SELECT
  *
FROM
  covid_19_data;
```
Next, let's find the shape of the dataset
```sql
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
```
There are 197248 rows and 67 columns in this dataset.

Since this is a public dataset, we should look at the table metadata to understand what data types are assigned to each column. We can do this by accessing the SQL Server INFORMATION_SCHEMA views for our table's columns.

```sql
---View Table Metadata
SELECT
	*
FROM
	INFORMATION_SCHEMA.COLUMNS
WHERE
	TABLE_NAME = 'covid_19_data';
```

We can see that many of the columns that store traditionally numeric data are casted as nvarchar(strings). This is important to know as we may run into calculation problems further into the analysis because of this.

Next, we want to check what date range our dataset covers

```sql
--Date Range
SELECT
	MIN(CAST(date as DATE)) as 'from', MAX(CAST(date as DATE)) as 'to'
FROM
	covid_19_data
```
This version of the dataset stores data from January 1<sup>st</sup>, 2020 to June 27<sup>th</sup>, 2022

## Ask

What questions do we want to answer with our data?
- What is the YoY comparison of total covid-19 cases in Canada for January 1<sup>st</sup> to June 27<sup?th</sup> in 2021 and 2022?
- What is the YTD fatality rate of covid-19 in Canada?
- How does YTD total covid-19 cases differ between the US and Canada (accounting for population)?
  
## Data Cleaning

To answer the above questions accurately, we need to ensure that the data being used is clean.
 
To answer the above questions, we need numerical data from the `new_cases`, `new_deaths` and `population` columns for Canada and the US.
 
Let's check for missing data in these columns
 
```sql
-- NULL checking
SELECT
	location, new_cases, new_deaths, population
FROM
	covid_19_data
WHERE
	location IN ('United States', 'Canada') AND (new_deaths IS NULL OR new_cases IS NULL OR population IS NULL );
 ```
We can see that there are a couple of NULL values in the `new_cases` column, none in the `population` column and many in the `new_deaths` column. 

Since we will only be taking the sum of the `new_deaths` and the `new_cases` columns, we don't need to change the NULL values since the SUM function in SQL ignores NULL values.

Everything else is in an acceptable format for the data analysis we want to carry out.

## Analysis

1. YoY Comparison
```sql
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
```
The total cases recorded between January 1<sup>st</sup>, 2021 and June 27<sup>th<\sup>, 2021 in Canada were 827,609 and 1,726,369 for the same period during 2022. This isn't surprising given that there were much more stringent covid-19 measures in during this period in the past year.

2. YTD Fatality Rate as a percentage
```sql
--YTD Fatality Rate of Covid-19 in Canada
SELECT
	location, (SUM(CAST(new_deaths as INT))/SUM(new_cases))*100 as fatality_rate_pct
FROM
	covid_19_data
WHERE location = 'Canada' AND (date BETWEEN '2022-01-01' AND '2022-06-27')
GROUP BY location;
```
The YTD fatality rate in Canada seems to be around 0.67% which is great news for me. The chances of me dying from covid appear to be pretty low ignoring many factors such as age, comorbidities etc.

3. Comparison of YTD total covid-19 cases between the US and Canada over population (pct)
**NOTE**: Population values do not change throughout this time period
```sql
---YTD total covid-19 cases/population pct; US vs Canada
SELECT
	location, (SUM(new_cases)/population)*100 as total_cases_YTD
FROM
	covid_19_data
WHERE location IN ('United States', 'Canada') AND (date BETWEEN '2022-01-01' AND '2022-06-27')
GROUP BY location, population;
```
The total cases/population YTD for Canada is 4.53% and 9.69% for the US. Canada has less the half of the percentage value that the US has. This could be reflecting the effect of the more lenient measures against covid-19 taken by the US during this year.

## Conclusion
Many other interesting insights can be found from this dataset and I'll be exploring some in the future but for now I'm glad that the fatality rate in Canada is ~0.67%.
