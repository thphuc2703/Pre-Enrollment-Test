-- 1. Count number of unique client order and number of orders by order month.
-- Count the number of unique client orders
SELECT COUNT(DISTINCT Client_ID) AS Unique_Client_Count
FROM ORDER;

-- Count the number of orders by order month
SELECT EXTRACT(YEAR FROM TO_DATE(Date_Order, 'DD.Mon.YYYY')) AS Order_Year,
       EXTRACT(MONTH FROM TO_DATE(Date_Order, 'DD.Mon.YYYY')) AS Order_Month,
       COUNT(*) AS Order_Count
FROM ORDER
GROUP BY EXTRACT(YEAR FROM TO_DATE(Date_Order, 'DD.Mon.YYYY')),
         EXTRACT(MONTH FROM TO_DATE(Date_Order, 'DD.Mon.YYYY'))
ORDER BY Order_Year, Order_Month

-- 2. Get a list of clients who have more than 10 orders in this year:
SELECT Client_ID
FROM ORDER
WHERE EXTRACT(YEAR FROM TO_DATE(Date_Order, 'DD.Mon.YYYY')) = EXTRACT(YEAR FROM SYSDATE)
GROUP BY Client_ID
HAVING COUNT(*) > 10

--3. From the above list of clients: 
-- get information on the first and second last order of each client (Order date, good type, and amount):
WITH Client_Orders AS (
    SELECT Client_ID, Order_ID, Date_Order, Good_Type, Good_Amount,
           ROW_NUMBER() OVER (PARTITION BY Client_ID ORDER BY TO_DATE(Date_Order, 'DD.Mon.YYYY')) AS Order_Rank_Asc,
           ROW_NUMBER() OVER (PARTITION BY Client_ID ORDER BY TO_DATE(Date_Order, 'DD.Mon.YYYY') DESC) AS Order_Rank_Desc
    FROM ORDER
    WHERE Client_ID IN (
        SELECT Client_ID
        FROM ORDER
        WHERE EXTRACT(YEAR FROM TO_DATE(Date_Order, 'DD.Mon.YYYY')) = EXTRACT(YEAR FROM SYSDATE)
        GROUP BY Client_ID
        HAVING COUNT(*) > 10
    )
)
SELECT Client_ID, Order_ID, Date_Order, Good_Type, Good_Amount
FROM Client_Orders
WHERE Order_Rank_Asc = 1 OR Order_Rank_Desc = 2
ORDER BY Client_ID, Date_Order;

--4. Calculate the total good amount and the count number of orders that were delivered in Sep.2019:
SELECT SUM(O.Good_Amount) AS Total_Good_Amount,
       COUNT(*) AS Order_Count
FROM ORDER O
JOIN ORDER_DELIVERY OD ON O.Order_ID = OD.Order_ID
WHERE EXTRACT(YEAR FROM TO_DATE(OD.Date_Delivery, 'DD.Mon.YYYY')) = 2019
  AND EXTRACT(MONTH FROM TO_DATE(OD.Date_Delivery, 'DD.Mon.YYYY')) = 9;
  
--5. Assuming your two tables contain a huge amount of data and each join will take about 30 hours, 
-- while you need to do a daily report, what is your solution?

-- Answer:
-- Data Indexing: Ensure that indexes are created on columns used in joins and filtering, such as Order_ID, Date_Order, and Date_Delivery.
-- Partitioning: If the tables are extremely large, consider partitioning them based on relevant columns like Date_Order and Date_Delivery.
-- Materialized Views: Use materialized views to precompute and store the results of complex joins. These views can be refreshed periodically (e.g., daily).