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


-- PROJECT: US HOUSEHOLD INCOME ANALYSIS ( PART I DATA CLEANING):

USE	US_Project
GO

SELECT	*
FROM	US_Household_Income;

/*
Note: It was observed that the US Household Income dataset contains duplicate rows, 
null values in the Place column, and typos in the Type column.
*/

-- Duplicate Removal Process

/*
This query removes duplicates from the US_Household_Income table by assigning a row number to each id.
Rows with a row number greater than 1 are deleted, ensuring only one entry per id.
*/

SELECT	id, COUNT(id) AS id_count --Check for duplicates
FROM	US_Household_Income
GROUP BY id
HAVING	 COUNT(id) > 1 ;



WITH CTE AS (

	SELECT	row_id, id,
			ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) Row_Num
	FROM	US_Household_Income
)
DELETE FROM US_Household_Income
WHERE Row_ID IN (
    SELECT Row_ID
    FROM CTE
    WHERE Row_Num > 1
);

-- Fill Null Values in the Place Column

/*
This query updates the Place column in the US_Household_Income table, 
for rows where the current status is NULL.
*/

SELECT	County, City, Place -- Check for Null values
FROM	US_Household_Income
WHERE	Place IS NULL;

UPDATE	US_Household_Income
SET		Place = 'Autaugaville'
WHERE	County = 'Autauga County'
AND		City = 'Vinemont';


-- Identifying and Standardizing Name Typos in the Type column

/*
This code first identifies potential typos in the Type field of the US_Household_Income table 
by counting and grouping the different entries in this column. Then, it corrects a 
specific typo by updating rows where Type is 'Boroughs' to the standardized form 
'Borough'.
*/

SELECT	Type, COUNT(Type) -- Check unique values
FROM	US_Household_Income
GROUP BY Type
ORDER BY Type;

UPDATE	US_Household_Income
SET		Type = 'Borough'
WHERE	Type = 'Boroughs';


SELECT	DISTINCT State_Name
FROM	US_Household_Income
WHERE	State_Name LIKE '[g]%';

UPDATE	US_Household_Income
SET		State_Name = 'Georgia'
WHERE	State_Name = 'georia';



-- PROJECT: US HOUSEHOLD INCOME ANALYSIS ( PART II AUTOMATION AND DATA QUALITY):

-- Below is the complete code used to automate the data cleaning process described above.


USE	US_Project
GO

SELECT *
FROM   US_Household_Income;


-- Drop the procedure if it already exists
IF OBJECT_ID('Copy_and_Clean_Data', 'P') IS NOT NULL
    DROP PROCEDURE Copy_and_Clean_Data;
GO

-- Create the new procedure
CREATE PROCEDURE Copy_and_Clean_Data
AS
BEGIN
    -- Start a transaction to ensure data integrity
    BEGIN TRANSACTION;

    -- Step 1. Create a copy of the orignal table if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'US_Household_Income_Cleaned')
    BEGIN
        CREATE TABLE US_Household_Income_Cleaned (
            row_id INT NULL,
            id INT NULL,
            State_Code INT NULL,
            State_Name NVARCHAR(MAX),
            State_ab NVARCHAR(MAX),
            County NVARCHAR(MAX),
            City NVARCHAR(MAX),
            Place NVARCHAR(MAX),
            Type NVARCHAR(MAX),
            [Primary] NVARCHAR(MAX), -- Brackets to escape the keyword
            Zip_Code INT NULL,
            Area_Code INT NULL,
            ALand BIGINT NULL,
            AWater BIGINT NULL,
            Lat FLOAT NULL,
            Lon FLOAT NULL,
            TimeStamp DATETIME DEFAULT GETDATE()
        );
    END;

    -- Step 2. Insert data from the source table with a timestamp
    INSERT INTO US_Household_Income_Cleaned
    SELECT *, GETDATE() AS TimeStamp
    FROM US_Project.dbo.US_Household_Income;

    -- Step 3. Clean the data

    -- Remove duplicates by keeping the earliest row for each 'id' and 'TimeStamp'
    WITH duplicates AS (
        SELECT row_id, id,
            ROW_NUMBER() OVER (PARTITION BY id, TimeStamp ORDER BY id, TimeStamp) AS row_num
        FROM US_Household_Income_Cleaned
    )
    DELETE FROM US_Household_Income_Cleaned
    WHERE row_id IN (
        SELECT row_id FROM duplicates WHERE row_num > 1
    );

    -- Fill NULL values in the 'Place' column based on County and City
    UPDATE US_Household_Income_Cleaned
    SET Place = 'AUTAUGAVILLE'
    WHERE County = 'Autauga County' AND City = 'Vinemont';

    -- Standardization of values
    UPDATE US_Household_Income_Cleaned
    SET State_Name = 'GEORGIA' WHERE State_Name = 'georia';

    UPDATE US_Household_Income_Cleaned
    SET County = UPPER(County), 
        City = UPPER(City), 
        Place = UPPER(Place), 
        State_Name = UPPER(State_Name);

    UPDATE US_Household_Income_Cleaned
    SET Type = 'CDP' WHERE Type = 'CPD';

    UPDATE US_Household_Income_Cleaned
    SET Type = 'BOROUGH' WHERE Type = 'Boroughs';

    -- Step 4. Commit the transaction to save changes
    COMMIT TRANSACTION;
END;
GO

-- To run the procedure
EXEC Copy_and_Clean_Data;


-- Ckeck Cleaned dataset

SELECT *
FROM   US_Household_Income_Cleaned;



/*
To ensure that newly added data is cleaned automatically, I created a trigger that activates whenever new rows are inserted into 
the US_Project.US_Household_Income table. This approach ensures that the cleaning process runs seamlessly, maintaining data 
consistency and quality without manual intervention.
*/


-- Step 1: Create the Trigger on the Original Table

CREATE TRIGGER Transfer_clean_data
ON US_Project.US_Household_Income
AFTER INSERT
AS
BEGIN
    -- Start a transaction to ensure data integrity
    BEGIN TRANSACTION;

    -- Call the Copy_and_Clean_Data procedure to process data
    EXEC Copy_and_Clean_Data;

    -- Commit the transaction
    COMMIT TRANSACTION;
END;
GO

-- Insert Statement to Test the Trigger
-- When a row is inserted into US_Project.US_Household_Income, the Transfer_clean_data trigger fires.
-- The trigger executes the Copy_and_Clean_Data procedure to transfer and clean the data.

INSERT INTO US_Project.US_Household_Income
    (row_id, id, State_Code, State_Name, State_ab, County, City, Place, Type, [Primary], Zip_Code, Area_Code, ALand, AWater, Lat, Lon)
VALUES
    (121671, 37025904, 37, 'North Carolina', 'NC', 'Alamance County', 'Charlotte', 'Alamance', 'Track', 'Track', 28215, 980, 24011255, 98062070, 35.2661197, -80.6865346);




























