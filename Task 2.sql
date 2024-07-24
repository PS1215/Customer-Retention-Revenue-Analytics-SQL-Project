--Task 2


---------------------------------step 1------------------------------------

-- Create a table with user ID and their first order date
CREATE OR REPLACE VIEW User_First_Order AS
SELECT 
    "USER_ID", 
    MIN(TO_DATE("ORDER_DATE", 'DD-MM-YYYY')) AS First_Order_Date
FROM 
    "ORDER"
GROUP BY 
    "USER_ID";

-- Create a cohort table by month and year
CREATE OR REPLACE VIEW Cohorts AS
SELECT 
    "USER_ID",
    DATE_TRUNC('month', First_Order_Date) AS Cohort
FROM 
    User_First_Order;

--------------------------------step 2----------------------------------------
   
-- Add cohort information to the ORDER table
CREATE OR REPLACE VIEW Orders_With_Cohorts AS
SELECT 
    o.*,
    c.Cohort
FROM 
    "ORDER" o
JOIN 
    Cohorts c ON o."USER_ID" = c."USER_ID";


-- Calculate the number of active users for each cohort over time
CREATE OR REPLACE VIEW Cohort_Analysis AS
SELECT 
    Cohort,
    DATE_TRUNC('month', TO_DATE("ORDER_DATE", 'DD-MM-YYYY')) AS Order_Month,
    COUNT(DISTINCT "USER_ID") AS Active_Users
FROM 
    Orders_With_Cohorts
GROUP BY 
    Cohort, Order_Month
ORDER BY 
    Cohort, Order_Month;

   
----------------------------------------------step 3---------------------------------


-- Create a view with the number of users in each cohort
CREATE OR REPLACE VIEW Cohort_Size AS
SELECT 
    Cohort,
    COUNT(DISTINCT "USER_ID") AS Cohort_Size
FROM 
    Orders_With_Cohorts
GROUP BY 
    Cohort;

-- Calculate the retention percentage
CREATE OR REPLACE VIEW Retention_Percentage AS
SELECT 
    ca.Cohort,
    ca.Order_Month,
    ca.Active_Users,
    cs.Cohort_Size,
    (ca.Active_Users::FLOAT / cs.Cohort_Size) * 100 AS Retention_Percentage
FROM 
    Cohort_Analysis ca
JOIN 
    Cohort_Size cs ON ca.Cohort = cs.Cohort
ORDER BY 
    ca.Cohort, ca.Order_Month;

--------------------------------------step 4--------------------------------------------

-- Pivot the data to create the cohort table
SELECT
    Cohort,
    MAX(CASE WHEN EXTRACT(MONTH FROM age(Order_Month, Cohort)) = 0 THEN Retention_Percentage ELSE NULL END) AS Month_0,
    MAX(CASE WHEN EXTRACT(MONTH FROM age(Order_Month, Cohort)) = 1 THEN Retention_Percentage ELSE NULL END) AS Month_1,
    MAX(CASE WHEN EXTRACT(MONTH FROM age(Order_Month, Cohort)) = 2 THEN Retention_Percentage ELSE NULL END) AS Month_2,
    MAX(CASE WHEN EXTRACT(MONTH FROM age(Order_Month, Cohort)) = 3 THEN Retention_Percentage ELSE NULL END) AS Month_3,
    MAX(CASE WHEN EXTRACT(MONTH FROM age(Order_Month, Cohort)) = 4 THEN Retention_Percentage ELSE NULL END) AS Month_4,
    MAX(CASE WHEN EXTRACT(MONTH FROM age(Order_Month, Cohort)) = 5 THEN Retention_Percentage ELSE NULL END) AS Month_5,
    MAX(CASE WHEN EXTRACT(MONTH FROM age(Order_Month, Cohort)) = 6 THEN Retention_Percentage ELSE NULL END) AS Month_6,
    MAX(CASE WHEN EXTRACT(MONTH FROM age(Order_Month, Cohort)) = 7 THEN Retention_Percentage ELSE NULL END) AS Month_7,
    MAX(CASE WHEN EXTRACT(MONTH FROM age(Order_Month, Cohort)) = 8 THEN Retention_Percentage ELSE NULL END) AS Month_8,
    MAX(CASE WHEN EXTRACT(MONTH FROM age(Order_Month, Cohort)) = 9 THEN Retention_Percentage ELSE NULL END) AS Month_9,
    MAX(CASE WHEN EXTRACT(MONTH FROM age(Order_Month, Cohort)) = 10 THEN Retention_Percentage ELSE NULL END) AS Month_10,
    MAX(CASE WHEN EXTRACT(MONTH FROM age(Order_Month, Cohort)) = 11 THEN Retention_Percentage ELSE NULL END) AS Month_11
FROM 
    Retention_Percentage
GROUP BY 
    Cohort
ORDER BY 
    Cohort;

----------------------------------------step 5--------------------------------------------
   
-- Export the cohort table to CSV
   
COPY (
    SELECT *
    FROM Cohorts
) TO 'D:\\course\\Project\\Task 2\\Cohort_Analysis.csv' WITH CSV HEADER;


