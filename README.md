# US_Household_Income_Analysis

# Objective 
This project aims to analyze household income trends across states, counties, and places in the United States. 
By identifying patterns and disparities in income, the analysis will provide insights into geographic income distributions. 

# Datasets  

1. ***US Household Income Dataset***  
   - Columns: row_id, id, State_Code, State_Name, State_ab, County, City, Place, Type, Primary, Zip_Code, Area_Code, ALand, AWater, Lat, Lon  

2. ***US Household Income Statistics Dataset***  
   - Columns: id, State_Name, Mean, Median, Stdev  

# Project Plan

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
