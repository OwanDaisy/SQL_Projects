#create database
create database if not exists SalesDataWalmart;

#creating tables based on data provided and eliminating null values
#to minimise data cleaning
create table if not exists sales(
    invoice_id varchar(30) not null primary key,
    branch varchar(30) not null,
    city varchar(30) not null,
    customer_type varchar(30),
    gender varchar(10) not null,
    product_line varchar(20) not null,
    unit_price decimal(10,2) not null,
    quantity int not null,
    VAT float(6,4) not null,
    total decimal(12,4) not null,
    date datetime not null,
    time time not null,
    payment_method varchar(15) not null,
    cogs decimal(10,2),
    gross_margin_percentage float(11,9),
    gross_income decimal(12,4) not null,
    rating float(2,1)
    
);

##readjusting character lengths of some columns
alter table sales modify product_line varchar(50);
alter table sales modify rating float;





## after importing data into our database



-- ***************************************** FEATURE ENGINEERING******************************************* --



-- 1. Which part of the day are most sales made? --

#partitioning time stamps into periods

SELECT time, (CASE 
			     WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
                 WHEN time BETWEEN "12:00:00" AND "17:00:00" THEN "Afternoon"
                 ELSE "Evening"
			END) AS "Period" FROM sales;

#adding column to store periods
ALTER TABLE sales ADD column Period varchar(15);

#feeding empty column with our queried data
UPDATE sales
SET Period = (CASE 
			     WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
                 WHEN time BETWEEN "12:00:00" AND "17:00:00" THEN "Afternoon"
                 ELSE "Evening"
			END);




-- 2. Which day of the week is the branch busiest? --

#retrieving days correspondin to dates
SELECT date, dayname(date) FROM sales;

#adding this info into its own column
ALTER TABLE sales ADD COLUMN Day varchar(15);
UPDATE sales
SET Day = (
    SELECT dayname(date)
);

##repeating process above for month
SELECT date, monthname(date) FROM sales;

ALTER TABLE sales ADD COLUMN Month varchar(15);
UPDATE sales
SET Month = (
    SELECT monthname(date)
);



-- ***************************************** EXPLORATORY DATA ANALYSIS******************************************* --


          -- GENERIC QUESTIONS --

-- 1. How many unique cities have a walmart branch? --
SELECT DISTINCT(city) FROM sales;

-- 2. How many unique walmart branches are there? --
SELECT DISTINCT branch FROM sales;

-- 3. In which city is each individual branch? --
SELECT DISTINCT(city), branch FROM sales;


          -- PRODUCT RELATED QUESTIONS --

-- 1.How many unique product lines does the data have?--
SELECT COUNT(DISTINCT product_line) FROM sales;
 -- Ans: 6
 
 -- 2. Most common payment method
SELECT payment_method, COUNT(payment_method) AS Count
FROM sales
GROUP BY payment_method;
-- Ans: Ewallet

-- 3. Most selling product line --
SELECT product_line, COUNT(product_line) AS Count
FROM sales
GROUP BY product_line
ORDER BY Count desc;
-- Ans: Fashion accessories

-- 4. Total revenue by month
SELECT SUM(total) as Total_Sales,Month
FROM sales
GROUP BY Month
ORDER BY Total_Sales desc;

-- 5. Which month had the most COGS(Cost Of Goods Sold)? 
SELECT SUM(cogs) as Tot_Cogs,Month
FROM sales
GROUP BY Month
ORDER BY Tot_Cogs desc;
-- Ans : January
#we could start hinting towards the fact that revenue and Cogs could be positively correlated

-- 6. What product had the most revenue?
SELECT product_line,SUM(total) as Total_Sales
FROM sales
GROUP BY product_line
ORDER BY Total_Sales desc;
-- Ans: food and beverages

-- 7. City/Branch with the largest revenue
SELECT city, branch, SUM(total) as Total_Sales
FROM sales
GROUP BY city
ORDER BY Total_Sales desc;
-- Ans: Naypyitaw

-- 8. What product line had the largest VAT?
SELECT product_line, avg(VAT) as Total_VAT
FROM sales
GROUP BY product_line
ORDER BY Total_VAT desc;
-- Ans: home and lifestyle

-- 9. Which branch sold more products than the average product sold? --
SELECT branch, product_line, sum(quantity) as Qty
FROM sales
GROUP BY branch
having Qty > (SELECT avg(quantity) FROM sales);
-- Ans: A --

-- 10. Which gender consumes each product more?
SELECT gender,product_line,count(gender) as Cnt
FROM sales
GROUP BY gender,product_line
order by Cnt desc;

-- 11. What is the average rating per product --
SELECT product_line,round(avg(rating),2) as Rating
FROM sales
GROUP BY product_line
order by Rating desc;


          -- SALES RELATED QUESTIONS --

-- 12. Number of Sales made in each time of the day per week day
SELECT Day, Period, COUNT(invoice_id) AS Sale_Count
FROM sales
GROUP BY Day,Period
order by Day, Period;

-- 13. Which Customer type brings in more revenue? --
SELECT customer_type, SUM(total) AS Revenue
FROM sales
GROUP BY customer_type
ORDER BY Revenue;
-- Ans : Member

-- 14. Which City has the largest VAT --
SELECT city, avg(VAT) VAT
FROM sales
gROUP BY city
Order by VAT desc;
-- Ans: Naypyitaw

-- 15. Which customer type pays the most VAT
SELECT customer_type, avg(VAT) as VAT
FROM sales
GROUP BY customer_type
Order by VAT desc;
-- Ans: Member
-- We can assume that being a particular customer type does not really provide an advantage vis a vis tax payment

          -- CUSTOMER QUESTIONS --
          
-- 16. Customer categories and count of each --
SELECT DISTINCT customer_type, count(customer_type) as Count
FROM sales
GROUP BY customer_type;

-- 17. Which type buys most? --
SELECT DISTINCT customer_type, count(total) as Count
FROM sales
GROUP BY customer_type;
-- Ans : Member --

-- 18. what gender buys most from us? --
SELECT DISTINCT gender, count(*) as Count
FROM sales
GROUP BY gender;
-- Ans : Female --

-- 19. What is the gender distribution per branch --
SELECT branch, gender, count(*) as Count
FROM sales
GROUP BY branch, gender 
ORDER BY branch;

-- 20. What time of the day do customers give more ratings
SELECT Period,avg(rating) as rating 
FROM sales
GROUP BY Period 
ORDER BY rating;
-- Ans: Afternoon. Upon observing the different values, the period of the day
-- does not seem to have a significant effect on customer's mood

-- 21. What time of the day do customers give more ratings, per branch
SELECT branch, Period, avg(rating) as rating 
FROM sales
GROUP BY Period, branch
ORDER BY branch,rating desc;

-- 22. Which day has the best rating?
SELECT Day, avg(rating) as rating 
FROM sales
GROUP BY Day
ORDER BY rating desc;
-- Ans: Monday

-- 23. Which day has the best rating per branch?
SELECT Day, avg(rating) as rating 
FROM sales
WHERE branch = "B"
GROUP BY Day
ORDER BY rating desc;