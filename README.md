# Covid_EDA_SQL

Exploratory Data Analysis of a Covid-19 Dataset (source: https://ourworldindata.org/covid-deaths  last update: 28/06/2022)

More info: https://github.com/owid/covid-19-data/tree/master/public/data

**Motivation**: I recently recovered from Covid and decided to finally check out a covid-19 dataset to see what insights I can build from the data using SQL.

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
Next,let's find the shape of the dataset
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

Since this is a public dataset, we should look at the table metadata to understand what data types are assigned to each column. We can do this bey accessing the SQL Server INFORMATION_SCHEMA views for our table's columns.

```sql
---View Table Metadata
SELECT
	*
FROM
	INFORMATION_SCHEMA.COLUMNS
WHERE
	TABLE_NAME = 'covid_19_data';
```

We can see that many of the columns that store traditionally numeric data are casted as nvarchar(strings). This is important to know as we may run into calculation problems further into the analysis.



## Data Cleaning
