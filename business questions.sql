use DWH_Ecommerce_F

--When is the peak season of our ecommerce ?

SELECT
    COUNT(order_id) AS OrderCount,
    YEAR(order_date) AS Year,
    MONTH(order_date) AS Month
FROM Dim_Orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    OrderCount DESC;


--What time users are most likely make an order or 
--using the ecommerce app?
SELECT
    COUNT(order_id) AS OrderCount,
    DATEPART(HOUR, order_date) AS Hour
FROM Dim_Orders
GROUP BY
    DATEPART(HOUR, order_date)
ORDER BY
    OrderCount DESC;

--What is the preferred way to pay in the ecommerce?
SELECT 
payment_type,
COUNT(order_id) AS PaymentCount

FROM Dim_Payments
GROUP BY payment_type
ORDER BY PaymentCount DESC

--How many installment is usually done when paying in the ecommerce?
SELECT 
AVG(payment_installments) AS installmentsCount
FROM Dim_Payments

--What is the average spending time for user for our ecommerce?
SELECT
    AVG(DATEDIFF(day, order_date, delivered_date)) AS AverageDays
FROM
    Dim_Orders
WHERE
    delivered_date IS NOT NULL;

--What is the frequency of purchase on each state?
SELECT
customer_state,
COUNT(order_id) AS OrderCount
FROM Dim_Orders
JOIN Dim_Customers
on Dim_Orders.user_name = Dim_Customers.user_name
GROUP BY customer_state
ORDER BY OrderCount DESC




--How many late delivered order in our ecommerce? Are late order affecting the customer satisfaction?
SELECT
    COUNT(Dim_Orders.order_id) AS LateOrders,
    AVG(Dim_Feedback.feedback_score) AS AverageFeedback
FROM
    Dim_Orders
LEFT JOIN
    Dim_Feedback  
    ON Dim_Orders.order_id = Dim_Feedback.order_id
    AND Dim_Orders.delivered_date > Dim_Orders.estimated_time_delivery;


--How long are the delay for delivery / shipping process in each state?

SELECT
    Dim_Customers.customer_state,
    AVG(DATEDIFF(DAY, Dim_Orders.estimated_time_delivery, Dim_Orders.delivered_date)) AS AverageDelayDays
FROM
    Dim_Orders
JOIN
    Dim_Customers ON Dim_Orders.user_name = Dim_Customers.user_name
WHERE
    Dim_Orders.delivered_date > Dim_Orders.estimated_time_delivery
GROUP BY
   Dim_Customers.customer_state;

--How long are the difference between estimated delivery time and actual delivery time in each state?
SELECT
    Dim_Customers.customer_state,
    AVG(DATEDIFF(DAY, Dim_Orders.estimated_time_delivery, Dim_Orders.delivered_date)) AS AverageDifferenceDays
FROM
    Dim_Orders
JOIN
   Dim_Customers ON Dim_Orders.user_name = Dim_Customers.user_name
GROUP BY
    Dim_Customers.customer_state
ORDER BY AverageDifferenceDays DESC;


--Which logistic route that have heavy traffic in our ecommerce?

SELECT
    Fact_Orders.order_id,
    Dim_Sellers.seller_city,
    Dim_Customers.customer_city
FROM
    Fact_Orders 
JOIN
    Dim_Sellers  
	ON Fact_Orders.seller_id = Dim_Sellers.seller_id
JOIN
    Dim_Customers 
	ON Fact_Orders.customer_zip_code= Dim_Customers.customer_zip_code;
