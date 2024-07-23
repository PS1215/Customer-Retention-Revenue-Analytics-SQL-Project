--Task 1


-----------------------------------step 1----------------------------

-- Check for missing values in the ORDER table
SELECT 
    COUNT(*) - COUNT("ORDER_ID") AS Missing_ORDER_ID,
    COUNT(*) - COUNT("USER_ID") AS Missing_USER_ID,
    COUNT(*) - COUNT("PROMO_ID") AS Missing_PROMO_ID,
    COUNT(*) - COUNT("ORDER_DATE") AS Missing_ORDER_DATE,
    COUNT(*) - COUNT("ORDER_SEQ") AS Missing_ORDER_SEQ,
    COUNT(*) - COUNT("REDEMPTION_DATE") AS Missing_REDEMPTION_DATE,
    COUNT(*) - COUNT("VALIDITY_TILL_DATE") AS Missing_VALIDITY_TILL_DATE,
    COUNT(*) - COUNT("ORDER_STAUS") AS Missing_ORDER_STATUS
FROM "ORDER";


-- Check for missing values in the PROMOTION_DETAILS table
SELECT 
    COUNT(*) - COUNT("PROMO_ID") AS Missing_PROMO_ID,
    COUNT(*) - COUNT("PROMO_PLAN") AS Missing_PROMO_PLAN,
    COUNT(*) - COUNT("PROMO_OFFER_TYPE") AS Missing_PROMO_OFFER_TYPE,
    COUNT(*) - COUNT("SUBSCRIPTION_TYPE") AS Missing_SUBSCRIPTION_TYPE,
    COUNT(*) - COUNT("BASE PRICE") AS Missing_BASE_PRICE,
    COUNT(*) - COUNT("DISCOUNT_PERCENTAGE") AS Missing_DISCOUNT_PERCENTAGE,
    COUNT(*) - COUNT("EFFECTIVE_PRICE") AS Missing_EFFECTIVE_PRICE
FROM "promotional_plan" ;

-- Check for missing values in the USER_REGISTRATION table
SELECT 
    COUNT(*) - COUNT("User Id") AS Missing_USER_ID,
    COUNT(*) - COUNT("Full Name") AS Missing_FULL_NAME,
    COUNT(*) - COUNT("Age") AS Missing_AGE,
    COUNT(*) - COUNT("Gender") AS Missing_GENDER,
    COUNT(*) - COUNT("Country") AS Missing_COUNTRY,
    COUNT(*) - COUNT("City") AS Missing_CITY
FROM user_registration ur ;


-----------------------------------step 2---------------------------------------

-- Check for duplicates in the ORDER table

SELECT "ORDER_ID", COUNT(*)
FROM "ORDER"
GROUP BY "ORDER_ID"
HAVING COUNT(*) > 1;


-- Check for duplicates in the PROMOTION_DETAILS table
SELECT "PROMO_ID", COUNT(*)
FROM "promotional_plan"
GROUP BY "PROMO_ID"
HAVING COUNT(*) > 1;

-- Check for duplicates in the USER_REGISTRATION table
SELECT "User Id", COUNT(*)
FROM "user_registration"
GROUP BY "User Id"
HAVING COUNT(*) > 1;

-----------------------------------step 3--------------------------------------

-- Combine the three tables into a single view
CREATE OR REPLACE VIEW Combined_Data AS
SELECT
    o."ORDER_ID",
    o."USER_ID",
    o."PROMO_ID",
    o."ORDER_DATE",
    o."ORDER_SEQ",
    o."REDEMPTION_DATE",
    o."VALIDITY_TILL_DATE",
    o."ORDER_STAUS",
    pp."PROMO_PLAN",
    pp."PROMO_OFFER_TYPE",
    pp."SUBSCRIPTION_TYPE",
    pp."BASE PRICE",
    pp."DISCOUNT_PERCENTAGE",
    pp."EFFECTIVE_PRICE",
    ur."Full Name",
    ur."Age",
    ur."Gender",
    ur."Country",
    ur."City"
FROM "ORDER" o
LEFT JOIN "promotional_plan" pp ON o."PROMO_ID" = pp."PROMO_ID"
LEFT JOIN "user_registration" ur ON o."USER_ID" = ur."User Id";

-----------------------------------step 4---------------------------------------

-- Extract new features from existing columns
CREATE OR REPLACE VIEW Combined_Data_With_Features AS
SELECT *,
    EXTRACT(MONTH FROM TO_DATE("ORDER_DATE", 'DD-MM-YYYY')) AS Active_Month,
    EXTRACT(YEAR FROM TO_DATE("ORDER_DATE", 'DD-MM-YYYY')) AS Active_Year,
    EXTRACT(MONTH FROM TO_DATE("REDEMPTION_DATE", 'DD-MM-YYYY')) AS Promo_Activation_Month,
    EXTRACT(YEAR FROM TO_DATE("REDEMPTION_DATE", 'DD-MM-YYYY')) AS Promo_Activation_Year,
    EXTRACT(MONTH FROM TO_DATE("VALIDITY_TILL_DATE", 'DD-MM-YYYY')) AS Promo_Ending_Month,
    EXTRACT(YEAR FROM TO_DATE("VALIDITY_TILL_DATE", 'DD-MM-YYYY')) AS Promo_Ending_Year
FROM Combined_Data;

SELECT *
FROM Combined_Data_With_Features




