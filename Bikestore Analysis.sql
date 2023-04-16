
SELECT *
FROM production.brands;
SELECT *
FROM production.categories;
SELECT *
FROM production.products;
SELECT *
FROM production.stocks;

SELECT *
FROM sales.customers
SELECT *
FROM sales.order_items
SELECT *
FROM sales.orders
SELECT *
FROM sales.staffs
SELECT *
FROM sales.stores

----Get the required columns together----

SELECT ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name) AS customer_name, cus.city, cus.state, ord.order_date, pro.product_name,
	cat.category_name, 
	SUM(ite.quantity) AS TOTAL_UNITS,
	SUM(ite.quantity * ite.list_price) AS REVENUE , 
	stf.staff_id as 'Sales_Rep', sto.store_id, sto.store_name
FROM sales.orders ord
JOIN sales.customers cus ON ord.customer_id = cus.customer_id
JOIN sales.order_items ite ON ite.order_id = ord.order_id
JOIN production.products pro ON pro.product_id = ite.product_id
JOIN production.categories cat ON cat.category_id = pro.category_id
JOIN sales.staffs stf ON stf.staff_id = ord.staff_id
JOIN sales.stores sto ON sto.store_id = ord.store_id
GROUP BY ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name), 
		cus.city, cus.state, ord.order_date,
		pro.product_name, cat.category_name,
		stf.staff_id, sto.store_id, sto.store_name;

----Yearly Revenue of the Company----

SELECT YEAR(B.order_date) AS Year_of_Sales , SUM(B.REVENUE) AS REVENUE
FROM 
	(SELECT ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name) AS customer_name, cus.city, 
	cus.state, ord.order_date, pro.product_name,
	cat.category_name, 
	SUM(ite.quantity) AS TOTAL_UNITS,
	SUM(ite.quantity * ite.list_price) AS REVENUE , 
	stf.staff_id as 'Sales_Rep', sto.store_id, sto.store_name
FROM sales.orders ord
JOIN sales.customers cus ON ord.customer_id = cus.customer_id 
JOIN sales.order_items ite ON ite.order_id = ord.order_id 
JOIN production.products pro ON pro.product_id = ite.product_id 
JOIN production.categories cat ON cat.category_id = pro.category_id
JOIN sales.staffs stf ON stf.staff_id = ord.staff_id 
JOIN sales.stores sto ON sto.store_id = ord.store_id
		GROUP BY ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name), 
		cus.city, cus.state, ord.order_date, 
		pro.product_name, cat.category_name, 
		stf.staff_id, sto.store_id, sto.store_name) B
GROUP BY YEAR(B.order_date);


----Revenue of the Company for first 2 Quarters every year since 2016----

SELECT YEAR(B.order_date) AS Year_of_Sales , MONTH(B.order_date) AS Month_of_Sales , SUM(B.REVENUE) AS REVENUE
FROM 
	(SELECT ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name) AS customer_name, cus.city, 
	cus.state, ord.order_date, pro.product_name,
	cat.category_name, 
	SUM(ite.quantity) AS TOTAL_UNITS,
	SUM(ite.quantity * ite.list_price) AS REVENUE , 
	stf.staff_id as 'Sales_Rep', sto.store_id, sto.store_name
FROM sales.orders ord
JOIN sales.customers cus ON ord.customer_id = cus.customer_id 
JOIN sales.order_items ite ON ite.order_id = ord.order_id 
JOIN production.products pro ON pro.product_id = ite.product_id 
JOIN production.categories cat ON cat.category_id = pro.category_id
JOIN sales.staffs stf ON stf.staff_id = ord.staff_id 
JOIN sales.stores sto ON sto.store_id = ord.store_id
		GROUP BY ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name), 
		cus.city, cus.state, ord.order_date, 
		pro.product_name, cat.category_name, 
		stf.staff_id, sto.store_id, sto.store_name) B
WHERE YEAR(B.order_date) >= '2016' AND MONTH(B.order_date) <= 6 
GROUP BY YEAR(B.order_date), MONTH(B.order_date)
ORDER BY YEAR(B.order_date), MONTH(B.order_date);



----When more than one customer ordered on the same day----

SELECT B.order_date, COUNT(Distinct(B.customer_name)) AS Number_of_orders
FROM (
	SELECT ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name) AS customer_name, cus.city, cus.state, ord.order_date, pro.product_name,
	cat.category_name, 
	SUM(ite.quantity) AS TOTAL_UNITS,
	SUM(ite.quantity * ite.list_price) AS REVENUE , 
	stf.staff_id as 'Sales_Rep', sto.store_id, sto.store_name
FROM sales.orders ord
JOIN sales.customers cus ON ord.customer_id = cus.customer_id
JOIN sales.order_items ite ON ite.order_id = ord.order_id
JOIN production.products pro ON pro.product_id = ite.product_id
JOIN production.categories cat ON cat.category_id = pro.category_id
JOIN sales.staffs stf ON stf.staff_id = ord.staff_id
JOIN sales.stores sto ON sto.store_id = ord.store_id
GROUP BY ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name), 
		cus.city, cus.state, ord.order_date,
		pro.product_name, cat.category_name,
		stf.staff_id, sto.store_id, sto.store_name ) B
WHERE B.order_date = B.order_date
GROUP BY B.order_date
HAVING COUNT(Distinct(B.customer_name)) > 1 ;


----Top 3 hot selling products in each store----

SELECT C.store_name, C.product_name, C.Sales, C.Ranking
FROM (
	SELECT B.store_name , B.product_name, B.REVENUE AS Sales, 
		DENSE_RANK() OVER (PARTITION BY B.store_name ORDER BY B.REVENUE DESC) AS Ranking
FROM (
		SELECT ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name) AS customer_name, cus.city, cus.state, ord.order_date, pro.product_name,
	cat.category_name, 
	SUM(ite.quantity) AS TOTAL_UNITS,
	SUM(ite.quantity * ite.list_price) AS REVENUE , 
	stf.staff_id as 'Sales_Rep', sto.store_id, sto.store_name
FROM sales.orders ord
JOIN sales.customers cus ON ord.customer_id = cus.customer_id
JOIN sales.order_items ite ON ite.order_id = ord.order_id
JOIN production.products pro ON pro.product_id = ite.product_id
JOIN production.categories cat ON cat.category_id = pro.category_id
JOIN sales.staffs stf ON stf.staff_id = ord.staff_id
JOIN sales.stores sto ON sto.store_id = ord.store_id
GROUP BY ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name), 
		cus.city, cus.state, ord.order_date,
		pro.product_name, cat.category_name,
		stf.staff_id, sto.store_id, sto.store_name
		) B
	) C
WHERE C.Ranking <= 3
ORDER BY C.store_name, C.Sales DESC;


----Revenue Generated by each store and each store's contribution to the total Revenue----
-- Step - 1:
--- Get the required data in table form and as we are also including data as a result of the aggregate functions which we further need
--- to use again in Step - 2. So, if we use subquery we will not be able to use those result of aggregated coulmns for further manipulation
--- under aggregate functions that's why we have to create CTE's which will allow us to create seperate table and then create another CTE 
--- where we will be applying aggregate functions to these aggregated columns by refering to their table ---
-- Step - 2:
--- We will create 2nd CTE in which we will create another result by applying aggregate function on aggregated results by refering to its 
--- tenporary table, this CTE will give us another result. In this way we have Step - 1 results saved, and Step - 2 results saved seperately.
--- now we can use both results in the SELECT Statement following the CTEs to get to the final conclusion ---

WITH CONTRIBUTION AS (
SELECT ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name) AS customer_name, cus.city, cus.state, ord.order_date, pro.product_name,
	cat.category_name, 
	SUM(ite.quantity) AS TOTAL_UNITS,
	SUM(ite.quantity * ite.list_price) AS REVENUE , 
	stf.staff_id as 'Sales_Rep', sto.store_id, sto.store_name
FROM sales.orders ord
JOIN sales.customers cus ON ord.customer_id = cus.customer_id
JOIN sales.order_items ite ON ite.order_id = ord.order_id
JOIN production.products pro ON pro.product_id = ite.product_id
JOIN production.categories cat ON cat.category_id = pro.category_id
JOIN sales.staffs stf ON stf.staff_id = ord.staff_id
JOIN sales.stores sto ON sto.store_id = ord.store_id
GROUP BY ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name), 
		cus.city, cus.state, ord.order_date,
		pro.product_name, cat.category_name,
		stf.staff_id, sto.store_id, sto.store_name) 
,
Total_Revenue AS (
SELECT SUM(CONTRIBUTION.REVENUE) AS Sum_of_Revenue
FROM CONTRIBUTION)

SELECT B.store_name, SUM(B.REVENUE) AS Revenues, 
       ROUND(SUM(B.REVENUE)/T.Sum_of_Revenue*100,2) AS Percentage_Contribution
FROM CONTRIBUTION B
JOIN TOTAL_REVENUE T ON 1=1 --Here we used 1=1 because we have joined all rows of CONTRIBUTION with all rows of TOTAL_REVENUE although, no.
							-- of rows are not the same. In this case TOTAL_REVENUE has only one row which means we have used all rows of 
							-- of CONTRIBUTION with that one row under aggregate function--
GROUP BY B.store_name,T.Sum_of_Revenue
ORDER BY Revenues DESC;