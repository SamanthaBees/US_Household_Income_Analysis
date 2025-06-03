/* 
Project: US Household Income Analysis

Objective: This project aims to analyze household income trends across states, counties, and places in the United States. 
By identifying patterns and disparities in income, the analysis will provide insights into geographic income distributions. 

Datasets:  

1. **US Household Income Dataset**  
   - Columns: row_id, id, State_Code, State_Name, State_ab, County, City, Place, Type, Primary, Zip_Code, Area_Code, ALand, AWater, Lat, Lon  

2. **US Household Income Statistics Dataset**  
   - Columns: id, State_Name, Mean, Median, Stdev  

Project Plan:

1. **Data Cleaning**:  
   - Identify and remove duplicate rows  
   - Handle NULL values and standardize text fields (e.g., ‘Boroughs’ → ‘Borough’)  
   - Ensure data consistency across key fields like `State_Name` and `Type`  

2. **Automation and Data Quality**:  
   - Automate the cleaning process using SQL procedures and triggers  
   - Ensure that all new data is cleaned automatically to maintain data quality
   
3. **Exploratory Data Analysis (EDA)**:  
   - Combine both datasets to analyze income trends by geographic region  
   - Identify patterns in income distributions using statistical metrics such as mean, median, and standard deviation  

*/


-- PROJECT: US HOUSEHOLD INCOME ANALYSIS ( PART III EXPLORATORY DATA ANALYSIS (EDA)):

USE	US_Project
GO

SELECT	*
FROM	US_Household_Income_Cleaned;

SELECT	*
FROM	US_Household_Income_Statistics;


-- Top 10 U.S. States with the Largest Water Area

/*
This query identifies the top 10 U.S. states with the highest total water area by summing 
the AWater field for each state. The results are grouped by State_Name and ordered 
in descending order to display the states with the largest total water area.
*/


SELECT	TOP 10 WITH TIES State_Name, SUM(AWater) AS Total_Water
FROM	US_Household_Income_Cleaned
GROUP BY State_Name
ORDER BY SUM(AWater) DESC;

--  U.S. Household Income Data with Income Statistics

SELECT	u.State_Name, County, City, Type, [Primary], Mean, Median
FROM	US_Household_Income_Cleaned AS u
INNER JOIN	US_Household_Income_Statistics AS us
		ON	u.id = us.id
WHERE	Mean <> 0
;

-- Top 5 U.S. States with Highest Average Household Income Mean

/*
This query returns the top 5 states with the highest average household income mean,
excluding zero values, using data from two joined tables. States with equal 
averages are included with WITH TIES.
*/

SELECT	TOP 5 WITH TIES u.State_Name, AVG(Mean) AS Avg_mean
FROM	US_Household_Income_Cleaned AS u
INNER JOIN	US_Household_Income_Statistics AS us
		ON	u.id = us.id
WHERE	Mean <> 0
GROUP BY u.State_Name
ORDER BY Avg_mean DESC
;

-- Average Household Income Statistics by Type

/*
This query retrieves the count of records and calculates the average household income 
mean (Avg_mean) and median (Avg_median) for each Type in the US_Household_Income 
table. It filters out records where the mean is zero and orders the results by 
the average mean in descending order. 
*/

SELECT	Type, 
        COUNT(Type) AS Records_Count, 
        AVG(CAST(Mean AS NUMERIC(8,2))) AS Avg_mean, 
        AVG(CAST(Median AS NUMERIC(8,2))) AS Avg_median
FROM	US_Household_Income_Cleaned AS u
INNER JOIN	US_Household_Income_Statistics AS us
		ON	u.id = us.id
WHERE	Mean <> 0
GROUP BY Type
ORDER BY 3 DESC;

-- Average Household Income by City and State

/*
This query calculates the average household income mean for each city and 
state, excluding zero values, and orders the results by highest average 
income.
*/

SELECT	u.State_Name, 
		City, 
		AVG(CAST(Mean AS NUMERIC(8,2))) AS Avg_mean
FROM	US_Household_Income_Cleaned AS u
INNER JOIN	US_Household_Income_Statistics AS us
		ON	u.id = us.id
WHERE	Mean <> 0
GROUP BY u.State_Name, City
ORDER BY Avg_mean DESC
;