--Task 3


--------------------------------------Step 1------------------------------

-- Set the date style to recognize the provided date format
SET datestyle = 'DMY';

-- Calculate the total revenue for each order based on the effective price and subscription period
CREATE OR REPLACE VIEW total_order_revenue AS
SELECT
    o."ORDER_ID" AS order_id,
    o."USER_ID" AS user_id,
    p."PROMO_ID" AS promo_id,
    to_date(o."ORDER_DATE", 'DD-MM-YYYY') AS order_date,
    to_date(o."VALIDITY_TILL_DATE", 'DD-MM-YYYY') AS validity_till_date,
    p."EFFECTIVE_PRICE" AS effective_price,
    DATE_PART('month', AGE(to_date(o."VALIDITY_TILL_DATE", 'DD-MM-YYYY'), to_date(o."ORDER_DATE", 'DD-MM-YYYY'))) + 1 AS subscription_months,
    p."EFFECTIVE_PRICE" * (DATE_PART('month', AGE(to_date(o."VALIDITY_TILL_DATE", 'DD-MM-YYYY'), to_date(o."ORDER_DATE", 'DD-MM-YYYY'))) + 1) AS total_revenue
FROM 
    "ORDER" o
JOIN 
    "promotional_plan" p ON o."PROMO_ID" = p."PROMO_ID"
WHERE 
    o."ORDER_STAUS" IN ('Active', 'CLOSED');  -- Include both active and closed orders

-- Verify the results
SELECT * FROM total_order_revenue LIMIT 10;


   
------------------------------------Step 2----------------------------------
   
-- Create a view to define cohorts based on the first order date
CREATE OR REPLACE VIEW user_cohorts AS
SELECT
    "USER_ID",
    MIN(DATE_TRUNC('month', to_date("ORDER_DATE", 'DD-MM-YYYY'))) AS Cohort
FROM 
    "ORDER"
GROUP BY 
    "USER_ID";

-- Calculate total cohort revenue
CREATE OR REPLACE VIEW cohort_revenue AS
SELECT 
    uc.Cohort,
    SUM(tor.total_revenue) AS Total_Cohort_Revenue
FROM 
    total_order_revenue tor
JOIN 
    user_cohorts uc ON tor.user_id = uc."USER_ID"
GROUP BY 
    uc.Cohort
ORDER BY 
    uc.Cohort;

-- Verify the results
SELECT * FROM cohort_revenue LIMIT 10;


   
   
-----------------------------------Step 3-----------------------------------
   
-- Calculate the cohort size
CREATE OR REPLACE VIEW cohort_size AS
SELECT 
    Cohort,
    COUNT(DISTINCT "USER_ID") AS Cohort_Size
FROM 
    user_cohorts
GROUP BY 
    Cohort;

-- Calculate the average revenue per customer for each cohort
CREATE OR REPLACE VIEW average_revenue_per_customer AS
SELECT 
    cr.Cohort,
    cr.Total_Cohort_Revenue,
    cs.Cohort_Size,
    (cr.Total_Cohort_Revenue::FLOAT / cs.Cohort_Size) AS Average_Revenue_Per_Customer
FROM 
    cohort_revenue cr
JOIN 
    cohort_size cs ON cr.Cohort = cs.Cohort;

-- Verify the results
SELECT * FROM average_revenue_per_customer LIMIT 10;

   
---------------------------------Step 4----------------------------------------
-- Create the view with CTEs for CLTV calculation
CREATE OR REPLACE VIEW CLTV_Calculation AS
WITH Retention_Time AS (
    SELECT
        36 AS Avg_Retention_Time -- 3 years in months
),
Average_Revenue_Per_Customer_CTE AS (
    SELECT
        cohort,
        AVG(Average_Revenue_Per_Customer) AS Average_Revenue_Per_Customer
    FROM
        average_revenue_per_customer
    GROUP BY
        cohort
)
SELECT 
    arc.cohort,
    arc.Average_Revenue_Per_Customer,
    rt.Avg_Retention_Time,
    (arc.Average_Revenue_Per_Customer * rt.Avg_Retention_Time) AS CLTV
FROM 
    Average_Revenue_Per_Customer_CTE arc
JOIN 
    Retention_Time rt ON true; -- This joins the CTEs; using ON true is a simple way to combine CTEs

-- Verify the results
SELECT * FROM CLTV_Calculation LIMIT 10;




---------------------------------Step 5------------------------------------------
    
-- Create the view with CTEs for CLTV calculation with gross margin
CREATE OR REPLACE VIEW CLTV_With_Gross_Margin AS
WITH Gross_Margin AS (
    SELECT
        0.65 AS Margin -- Assuming a gross margin of 65%
),
CLTV_Calculation_CTE AS (
    -- CTE to calculate CLTV
    SELECT 
        arc.cohort,
        arc.Average_Revenue_Per_Customer,
        36 AS Avg_Retention_Time, 
        (arc.Average_Revenue_Per_Customer * 36) AS CLTV -- CLTV calculation
    FROM 
        CLTV_Calculation arc
)
-- Final selection for the view
SELECT 
    cltv.cohort,
    cltv.Average_Revenue_Per_Customer,
    cltv.Avg_Retention_Time,
    cltv.CLTV,
    gm.Margin,
    (cltv.CLTV * gm.Margin) AS CLTV_With_Margin
FROM 
    CLTV_Calculation_CTE cltv
JOIN 
    Gross_Margin gm ON true; -- Use ON true to combine CTEs

-- Verify the results
SELECT * FROM CLTV_With_Gross_Margin LIMIT 10;


    
    
---------------------------------Step 6-------------------------------
    
    
-- Export the CLTV data to CSV
COPY (
    SELECT *
    FROM CLTV_With_Gross_Margin
) TO 'D:\\course\\Project\\Task 3\\CLTV_Analysis.csv' WITH CSV HEADER;


















    
