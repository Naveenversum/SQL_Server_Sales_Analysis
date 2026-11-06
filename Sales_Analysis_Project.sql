CREATE DATABASE SalesDB;
USE SalesDB;
SELECT COUNT(*) AS Total_Rows
FROM dbo.Sales_Data;
SELECT COUNT(*) AS Null_Order_IDs
FROM dbo.Sales_Data
WHERE Order_ID IS NULL;
Select Order_ID,COUNT(*) AS Duplicate_Count
FROM dbo.Sales_Data
WHERE Order_Id IS NOT NULL
GROUP BY Order_ID
Having COUNT(*)>1;
Select *
From dbo.Sales_Data
WHERE Order_ID = 100023;
Select *,
COUNT(*) over (
    PARTITION BY Order_ID,Order_Date,Customer_name,City,State,Product,category,salesperson,Quantity,Price,Discount,Total_Sales,Payment_Mode,Region
) AS Duplicate_Count
From dbo.Sales_Data
WHERE Order_ID = 100023;
Select *,
       Row_Number() over (
              PARTITION BY Order_ID,Order_Date,Customer_name,City,State,Product,category,salesperson,Quantity,Price,Discount,Total_Sales,Payment_Mode,Region
              ORDER BY Order_ID
         ) AS Row_Num
From dbo.Sales_Data
WHERE Order_ID = 100023;

WITH DuplicateRows AS
(
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY Order_ID
            ORDER BY Order_ID
        ) AS Row_Num
    FROM dbo.Sales_Data
)
SELECT *
FROM DuplicateRows
WHERE Row_Num > 1;

SELECT DB_NAME() AS Current_Database;
SELECT COUNT(*) AS Blank_Rows
FROM dbo.Sales_Data
WHERE Order_ID IS NULL;

DELETE FROM dbo.Sales_Data
WHERE Order_ID IS NULL;

SELECT COUNT(*) AS Blank_Rows
FROM dbo.Sales_Data
WHERE Order_ID IS NULL;

SELECT Order_ID, COUNT(*) AS Duplicate_Count
FROM dbo.Sales_Data
GROUP BY Order_ID
HAVING COUNT(*) > 1;
-- Check for duplicate Order_IDs
WITH DuplicateRows AS
(
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY Order_ID
               ORDER BY Order_ID
           ) AS Row_Num
    FROM dbo.Sales_Data
)
SELECT *
FROM DuplicateRows
WHERE Row_Num > 1;

--Just countiung duplicates
WITH DuplicateRows AS.   
(
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY Order_ID
               ORDER BY Order_ID
           ) AS Row_Num
    FROM dbo.Sales_Data
)
SELECT COUNT(*) AS Rows_To_Remove
FROM DuplicateRows
WHERE Row_Num > 1;

WITH DuplicateRows AS
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY Order_ID
               ORDER BY Order_ID
           ) AS Row_Num
    FROM dbo.Sales_Data
)
DELETE FROM DuplicateRows
WHERE Row_Num > 1;
--verify the cleanup
SELECT COUNT(*) AS Total_Rows
FROM dbo.Sales_Data;
--no duplicate Order_IDs remain:
SELECT Order_ID, COUNT(*) AS Duplicate_Count
FROM dbo.Sales_Data
WHERE Order_ID IS NOT NULL
GROUP BY Order_ID
HAVING COUNT(*) > 1;
--confirm the total number of rows is now 50,000
SELECT COUNT(*) AS Total_Rows
FROM dbo.Sales_Data;

--checking other Null values 
SELECT
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS Null_Order_Date,
    SUM(CASE WHEN Customer_Name IS NULL THEN 1 ELSE 0 END) AS Null_Customer_Name,
    SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS Null_City,
    SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS Null_State,
    SUM(CASE WHEN Product IS NULL THEN 1 ELSE 0 END) AS Null_Product,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS Null_Category,
    SUM(CASE WHEN Salesperson IS NULL THEN 1 ELSE 0 END) AS Null_Salesperson,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS Null_Quantity,
    SUM(CASE WHEN Price IS NULL THEN 1 ELSE 0 END) AS Null_Price,
    SUM(CASE WHEN Discount IS NULL THEN 1 ELSE 0 END) AS Null_Discount,
    SUM(CASE WHEN Total_Sales IS NULL THEN 1 ELSE 0 END) AS Null_Total_Sales,
    SUM(CASE WHEN Payment_Mode IS NULL THEN 1 ELSE 0 END) AS Null_Payment_Mode,
    SUM(CASE WHEN Region IS NULL THEN 1 ELSE 0 END) AS Null_Region
FROM dbo.Sales_Data;

--which payment modes exist
SELECT Payment_Mode, COUNT(*) AS Order_Count
FROM dbo.Sales_Data
GROUP BY Payment_Mode 
--what percentage of the 50,000 rows have missing Payment_Mode.
SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Payment_Mode IS NULL THEN 1 ELSE 0 END) AS Null_Payment_Mode
FROM dbo.Sales_Data;
-- Check missing Payment_Mode
SELECT *
FROM dbo.Sales_Data
WHERE Payment_Mode IS NULL;
-- Since we don't know the actual payment method for those 41 orders,
-- the safest data-cleaning approach is to label them as Unknown.
UPDATE dbo.Sales_Data
SET Payment_Mode = 'Unknown'
WHERE Payment_Mode IS NULL;
--verify
SELECT Payment_Mode, COUNT(*) AS Order_Count
FROM dbo.Sales_Data
GROUP BY Payment_Mode;
--check for invalid values
SELECT *
FROM dbo.Sales_Data
WHERE Quantity <= 0;
--checking Price
SELECT *
FROM dbo.Sales_Data
WHERE Price <= 0;
--check whether any discount is invalid.
SELECT *
FROM dbo.Sales_Data
WHERE Discount < 0 OR Discount > 100;
--We'll check whether any rows in your 50,000 records have a Total_Sales value that doesn't match this calculation.
SELECT *
FROM dbo.Sales_Data
WHERE Total_Sales <> Quantity * Price * (1 - Discount / 100.0);

--Used to choose/show the data (columns) we want from a table.
SELECT
     MONTH(Order_Date) AS Sales_Month,      --How many orders did we get in each month?   
     COUNT(*) AS Orders,                    --Now we want to know how many orders happened in each month.      
     SUM(Total_Sales) AS Total_Sales        --How much total sales did we make in each month?
FROM dbo.Sales_Data
Group BY MONTH(Order_Date)                  --Put all orders belonging to the same month together.       
Order BY Sales_Month;                   --Show the months in order.

SELECT
     Salesperson,
     COUNT(*)AS Order_Count.    --COUNT(*) = Counts the number of rows.
FROM dbo.Sales_Data
GROUP BY Salesperson;         --GROUP BY = Groups rows having the same value.
--GROUP BY + COUNT(*) = Counts how many rows belong to each group.
--Total sales made by each salesperson
SELECT
      Salesperson,                       --show each salesperson
      SUM(Total_Sales) AS Total_Sales    --add their sales amounts --give the result a name
FROM dbo.Sales_Data
GROUP BY Salesperson;    --calculate separately for each salesperson
--For each salesperson, show both the number of orders AND their total sales.
SELECT
    Salesperson,
    COUNT(*) AS Order_Count,    --How many orders? 
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY Salesperson;

--Find the salesperson with the highest sales
SELECT
    Salesperson,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY Salesperson
ORDER BY Total_Sales DESC;     
--Group the data by salesperson → calculate their total sales → put highest sales first → show only the first person.
--Show me only the salesperson with the highest total sales
SELECT TOP 1
    Salesperson,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY Salesperson
ORDER BY Total_Sales DESC;
--How many orders did each salesperson handle in the South region?
SELECT
    Salesperson,
    COUNT(*) AS Order_Count
FROM dbo.Sales_Data
WHERE Region = 'South'.     --Take only South region rows
GROUP BY Salesperson;
--How much total sales did each salesperson make in the South region?
SELECT
    Salesperson,
    SUM(Total_Sales) AS Total_Sales.        --dd all the sales for each salesperson.
FROM dbo.Sales_Data
WHERE Region = 'South'
GROUP BY Salesperson;
--Who is the salesperson with the highest total sales in the South region?
SELECT TOP 1.           --show only the highest one
    Salesperson,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
WHERE Region = 'South'
GROUP BY Salesperson
ORDER BY Total_Sales DESC;
--What is the average Total_Sales for each salesperson?
SELECT
    Salesperson,
    AVG(Total_Sales) AS Average_Sales
FROM dbo.Sales_Data
GROUP BY Salesperson;
--What is the minimum and maximum sale made by each salesperson?
SELECT
    Salesperson,
    MIN(Total_Sales) AS Minimum_Sale,
    MAX(Total_Sales) AS Maximum_Sale
FROM dbo.Sales_Data
GROUP BY Salesperson;
--For a Data Analyst, we usually don't want such a long decimal.
--We can round the average sales to 2 decimal places.
SELECT
    Salesperson,
    ROUND(AVG(Total_Sales), 2) AS Average_Sales
FROM dbo.Sales_Data
GROUP BY Salesperson;
--Now we want to keep only salespeople whose count is greater than 10,000.
SELECT
    Salesperson,
    COUNT(*) AS Order_Count
FROM dbo.Sales_Data
GROUP BY Salesperson
HAVING COUNT(*) > 10000;
--Next, we'll learn DISTINCT, which is very easy and useful for finding unique cities, products, salespeople, etc.
--DISTINCT = unique values
SELECT DISTINCT City
FROM dbo.Sales_Data;
--Gives each city and how many orders it has.
SELECT City, COUNT(*) AS Order_Count
FROM dbo.Sales_Data
GROUP BY City;
--Let's find unique products.
--Show me every different/unique product in my sales table, without repeating the same product
--Shows each product only once
SELECT DISTINCT Product
FROM dbo.Sales_Data;
--This will show the unique product categories in your dataset
--DISTINCT = removes duplicates.
SELECT DISTINCT Category
FROM dbo.Sales_Data;
--How many orders are there in each category
SELECT
     Category,                       --"I want to see the category."
     COUNT(*) AS Order_Count     --"I want to count how many rows/orders are there."--Give the count column a readable name: Order_Count.
FROM dbo.Sales_Data.            --Take the data from your sales table.
GROUP BY Category;              --Put the same categories together and count each group.
--COUNT(*) → counts the number of rows.
--GROUP BY → puts the same values into groups.
--COUNT(*) + GROUP BY
--counts how many rows belong to each group.

SELECT Category, COUNT(*)
FROM dbo.Sales_Data
GROUP BY Category;
--How much total sales did each category generate
SELECT
    Category,
    SUM(Total_Sales) AS Total_Sales.        --SUM() → adds values --AS Total_Sales → gives the result column a clear name
FROM dbo.Sales_Data
GROUP BY Category;                   --adds them separately for each category
--SUM() + GROUP BY
→ calculates the total separately for each group
--COUNT + GROUP BY → How many?
--SUM + GROUP BY   → How much?
--Which category has the highest total sales?
SELECT
    Category,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY Category
ORDER BY Total_Sales DESC;
--how to find the highest salesperson using:
SELECT TOP 1
    Category,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY Category
ORDER BY Total_Sales DESC;
--Show me Electronics orders from the South region.
--Shows rows where both conditions match.
SELECT *
FROM dbo.Sales_Data
WHERE Category = 'Electronics'.         --WHERE Condition1
AND Region = 'South';     ----AND Condition2--AND means both conditions must be TRUE.
--"Show me orders that are either from the South region OR the North region."
SELECT *
FROM dbo.Sales_Data
WHERE Region = 'South'
OR Region = 'North';              --OR means at least one condition must be TRUE.
--SQL gives us a shorter way:
SELECT *
FROM dbo.Sales_Data
WHERE Region IN ('South', 'North');        --IN means "The value should be one of these options."

SELECT *
FROM dbo.Sales_Data
WHERE Category IN ('Electronics', 'Furniture');
--NOT IN  → Give me everything EXCEPT Electronics and Furniture
SELECT *
FROM dbo.Sales_Data
WHERE Category NOT IN ('Electronics', 'Furniture');     --It will exclude Electronics and Furniture.
--we want customers whose name starts with A:
SELECT *
FROM dbo.Sales_Data
WHERE Customer_Name LIKE 'A%';
--Ends with A
SELECT *
FROM dbo.Sales_Data
WHERE Customer_Name LIKE '%a';
--contains A anywhere
SELECT *
FROM dbo.Sales_Data
WHERE Customer_Name LIKE '%a%';
-- Monthly sales analysis
SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date)
ORDER BY
    Sales_Year,
    Sales_Month;
-- Highest sales month
SELECT TOP 1
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date)
ORDER BY
    Total_Sales DESC;
    -- Category-wise sales analysis
SELECT
    Category,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY Category
ORDER BY Total_Sales DESC;
-- Salesperson-wise sales analysis
SELECT
    Salesperson,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY Salesperson
ORDER BY Total_Sales DESC;
-- City-wise sales analysis
SELECT
    City,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY City
ORDER BY Total_Sales DESC;
-- State-wise sales analysis
SELECT
    State,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY State
ORDER BY Total_Sales DESC;
-- Product-wise sales analysis
SELECT
    Product,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY Product
ORDER BY Total_Sales DESC;
-- Product-wise quantity analysis

SELECT
    Product,
    SUM(Quantity) AS Total_Quantity
FROM dbo.Sales_Data
GROUP BY Product
ORDER BY Total_Quantity DESC;
-- Average price by product

SELECT
    Product,
    AVG(Price) AS Average_Price
FROM dbo.Sales_Data
GROUP BY Product
ORDER BY Average_Price DESC;
-- State-wise sales analysis

SELECT
    State,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY State
ORDER BY Total_Sales DESC;
-- Customer-wise sales analysis
SELECT
    Customer_Name,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY Customer_Name
ORDER BY Total_Sales DESC;
-- Category-wise quantity analysis
SELECT
    Category,
    SUM(Quantity) AS Total_Quantity
FROM dbo.Sales_Data
GROUP BY Category
ORDER BY Total_Quantity DESC;
-- Average order value
SELECT
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Total_Sales) AS Total_Sales,
    SUM(Total_Sales) / COUNT(DISTINCT Order_ID) AS Average_Order_Value
FROM dbo.Sales_Data;
-- Year-wise sales analysis
SELECT
    YEAR(Order_Date) AS Sales_Year,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY YEAR(Order_Date)
ORDER BY Sales_Year;
-- Top 5 products by quantity
SELECT TOP 5
    Product,
    SUM(Quantity) AS Total_Quantity
FROM dbo.Sales_Data
GROUP BY Product
ORDER BY Total_Quantity DESC;

-- Top 5 products by sales

SELECT TOP 5
    Product,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY Product
ORDER BY Total_Sales DESC;
-- Category sales contribution %

SELECT
    Category,
    SUM(Total_Sales) AS Category_Sales,
    ROUND(
        SUM(Total_Sales) * 100.0 /
        (SELECT SUM(Total_Sales) FROM dbo.Sales_Data),
        2
    ) AS Sales_Percentage
FROM dbo.Sales_Data
GROUP BY Category
ORDER BY Sales_Percentage DESC;
-- State and category sales analysis

SELECT
    State,
    Category,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY
    State,
    Category
ORDER BY
    Total_Sales DESC;
-- Top 10 customers by number of orders

SELECT TOP 10
    Customer_Name,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Total_Sales) AS Total_Sales
FROM dbo.Sales_Data
GROUP BY Customer_Name
ORDER BY Total_Orders DESC;






