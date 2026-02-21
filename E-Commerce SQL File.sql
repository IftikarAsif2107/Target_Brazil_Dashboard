#Data type of all columns in the "customers" table.


select * from `TARGET_SQL.Customers` 
limit 10;

select * from `TARGET_SQL.Geolocation`
limit 5;

#Time range between which the orders were placed.

select 
min(order_purchase_timestamp) as start_time,
max(order_purchase_timestamp) as end_time 
 from `TARGET_SQL.Orders`;

#1.3. Display Cities & States of customers who ordered during the given period.

select
c.customer_city, c.customer_state from `TARGET_SQL.Orders` as o 
join `TARGET_SQL.Customers` as c
on o.customer_id = c.customer_id
where Extract (year from o.order_purchase_timestamp) = 2018
and Extract (month from o.order_purchase_timestamp) Between 1 and 3;

#2. In-depth Exploration:
#Trend in the no. of orders placed over the past months?

select extract(month from order_purchase_timestamp) as Month, count(order_id) as order_num
from `TARGET_SQL.Orders`
group by extract(month from order_purchase_timestamp) 
order by order_num desc;

#3. During what time of the day, do the Brazilian customers mostly place their orders? (Dawn, Morning, Afternoon or Night)
#■ 0-6 hrs : Dawn
#■ 7-12 hrs : Mornings
#■ 13-18 hrs : Afternoon
#■ 19-23 hrs : Night

select extract(hour from order_purchase_timestamp) as Time, count(order_id) as order_num
from `TARGET_SQL.Orders`
group by extract(hour from order_purchase_timestamp) 
order by order_num desc;

# Trend in the no. of orders placed over the past years?

select extract(year from order_purchase_timestamp) as Year, count(order_id) as order_num
from `TARGET_SQL.Orders`
group by extract(Year from order_purchase_timestamp)
order by order_num desc;

#3. Evolution of E-commerce orders in the Brazil region:
#Month on month no. of orders placed in each state.

SELECT 
  EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
  EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
  COUNT(DISTINCT order_id) AS num_orders
FROM `TARGET_SQL.Orders`
GROUP BY year, month
ORDER BY year, month;

#3.2. How are the customers distributed across all the states?

SELECT customer_city,customer_state, COUNT(DISTINCT customer_id) AS customer_count
FROM `TARGET_SQL.Customers`
GROUP BY customer_city, customer_state
ORDER BY customer_count DESC;


#4. Impact on Economy: Analyze the money movement by e-commerce by looking at order prices, freight and others.
#% increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only).

#STEP 1 : Calculate total payments per year
with yearly_totals as (SELECT
extract(year from o.order_purchase_timestamp) as Year,
Sum(p.payment_value) as total_payment
from TARGET_SQL.Payments as p
join TARGET_SQL.Orders as o
on p.order_id = o.order_id
where extract(year from o.order_purchase_timestamp) in (2017, 2018)
and extract(month from o.order_purchase_timestamp) between 1 and 8
group by extract(year from o.order_purchase_timestamp)),
#STEP 2. use LEAD window unctions to compare each year's payments to the previous year
yearly_comparisons AS (
SELECT
Year,
total_payment,
lead(total_payment) over (order by year desc) as prev_year_payment
from yearly_totals
)
select round(((total_payment - prev_year_payment) / prev_year_payment)*100, 2)
from yearly_comparisons;

#Total & Average value of order price for each state as well as Total & Average value of order freight for each state.

SELECT 
c.customer_state,
round(avg(price),2) as avg_price,
round(sum(price),2) as sum_price,
round(avg(freight_value),2) as avg_freight,
round(sum(freight_value),2) as sum_freight
from TARGET_SQL.Orders as o
JOIN TARGET_SQL.Order_Items as oi
on o.order_id = oi.order_id
JOIN TARGET_SQL.Customers as c
on o.customer_id = c.customer_id
group by c.customer_state;

#5. Analysis based on sales, freight and delivery time.
#No of days taken to deliver each order from the order’s purchase date as delivery time.

SELECT 
  order_id,
  TIMESTAMP_DIFF(
      order_delivered_customer_date,
      order_purchase_timestamp,
      DAY
  ),
  TIMESTAMP_DIFF(
    order_delivered_customer_date,
    order_estimated_delivery_date,
    DAY
  ) AS delivery_days
FROM `TARGET_SQL.Orders`;


#Top 5 states with the highest & lowest average freight value.


WITH state_freight AS (
  SELECT 
    c.customer_state,
    AVG(oi.freight_value) AS avg_freight_value
  FROM `TARGET_SQL.Orders` o
  JOIN `TARGET_SQL.Order_Items` oi
    ON o.order_id = oi.order_id
  JOIN `TARGET_SQL.Customers` c
    ON o.customer_id = c.customer_id
  GROUP BY c.customer_state
)

SELECT *
FROM (
  SELECT *,
         RANK() OVER (ORDER BY avg_freight_value DESC) AS rank_high,
         RANK() OVER (ORDER BY avg_freight_value ASC) AS rank_low
  FROM state_freight
)
WHERE rank_high <= 5
   OR rank_low <= 5;



#Top 5 states with the highest & lowest average delivery time.

with state_delivery_time as (select c.customer_state, AVG(TIMESTAMP_DIFF(
      order_delivered_customer_date,
      order_purchase_timestamp,
      DAY
  )) AS avg_delivery_time
from `TARGET_SQL.Orders` as o
join `TARGET_SQL.Customers` as c 
on o.customer_id = c.customer_id
group by c.customer_state
)
select *
from (
  select *,
         RANK() OVER (ORDER BY avg_delivery_time DESC) AS rank_high,
         RANK() OVER (ORDER BY avg_delivery_time ASC) AS rank_low 
    from state_delivery_time
)
WHERE rank_high <= 5
   OR rank_low <= 5;

# Top 5 states where the order delivery is really fast as compared to the estimated date of delivery.

WITH state_delivery_speed AS (
  SELECT 
    c.customer_state,
    AVG(
      TIMESTAMP_DIFF(
        order_delivered_customer_date,
        order_estimated_delivery_date,
        DAY
      )
    ) AS avg_diff_days
  FROM `TARGET_SQL.Orders` o
  JOIN `TARGET_SQL.Customers` c
    ON o.customer_id = c.customer_id
  WHERE order_delivered_customer_date IS NOT NULL
    AND order_estimated_delivery_date IS NOT NULL
  GROUP BY c.customer_state
)

SELECT 
  customer_state,
  avg_diff_days
FROM state_delivery_speed
ORDER BY avg_diff_days ASC
LIMIT 5;

#6. Analysis based on the payments:
#month on month no. of orders placed using different payment types.

SELECT 
  EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year, 
  EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month, 
  COUNT(DISTINCT o.order_id) AS num_orders, 
  p.payment_type
FROM `TARGET_SQL.Payments` AS p
JOIN `TARGET_SQL.Orders` AS o
  ON p.order_id = o.order_id
GROUP BY 
  p.payment_type,
  EXTRACT(YEAR FROM o.order_purchase_timestamp),
  EXTRACT(MONTH FROM o.order_purchase_timestamp)
ORDER BY year, month;


#No. of orders placed on the basis of the payment installments that have been paid.

SELECT 
  payment_installments,
  COUNT(DISTINCT order_id) AS num_orders
FROM `TARGET_SQL.Payments`
GROUP BY payment_installments
ORDER BY payment_installments;


#OVERALL BUSINESS OVERVIEW

-- Total Orders & Time Span of Dataset
SELECT 
  COUNT(DISTINCT order_id) AS total_orders,      -- Total number of unique orders
  MIN(order_purchase_timestamp) AS start_date,   -- First order date
  MAX(order_purchase_timestamp) AS end_date      -- Last order date
FROM `TARGET_SQL.Orders`;


# YEAR-OVER-YEAR REVENUE GROWTH (JAN–AUG 2017 vs 2018)


WITH yearly_totals AS (
  SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,  -- Extract year
    SUM(p.payment_value) AS total_payment                   -- Total revenue per year
  FROM `TARGET_SQL.Payments` p
  JOIN `TARGET_SQL.Orders` o
    ON p.order_id = o.order_id
  WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) IN (2017, 2018)
    AND EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 8
  GROUP BY year
)

SELECT 
  year,
  total_payment,
  LAG(total_payment) OVER (ORDER BY year) AS previous_year_payment,
  ROUND(
    (total_payment - LAG(total_payment) OVER (ORDER BY year))
    / LAG(total_payment) OVER (ORDER BY year) * 100,
    2
  ) AS percent_growth     -- YoY Growth %
FROM yearly_totals;


#TOP 5 STATES BY TOTAL REVENUE


SELECT 
  c.customer_state,
  ROUND(SUM(p.payment_value),2) AS total_revenue
FROM `TARGET_SQL.Payments` p
JOIN `TARGET_SQL.Orders` o ON p.order_id = o.order_id
JOIN `TARGET_SQL.Customers` c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC
LIMIT 5;


#AVERAGE DELIVERY TIME (OVERALL)

SELECT 
  ROUND(AVG(
    TIMESTAMP_DIFF(
      order_delivered_customer_date,
      order_purchase_timestamp,
      DAY
    )
  ),2) AS avg_delivery_days
FROM `TARGET_SQL.Orders`
WHERE order_delivered_customer_date IS NOT NULL;


#TOP 5 FASTEST STATES (EARLY DELIVERY VS ESTIMATE)

WITH state_delivery_speed AS (
  SELECT 
    c.customer_state,
    AVG(
      TIMESTAMP_DIFF(
        order_delivered_customer_date,
        order_estimated_delivery_date,
        DAY
      )
    ) AS avg_diff_days
  FROM `TARGET_SQL.Orders` o
  JOIN `TARGET_SQL.Customers` c
    ON o.customer_id = c.customer_id
  WHERE order_delivered_customer_date IS NOT NULL
    AND order_estimated_delivery_date IS NOT NULL
  GROUP BY c.customer_state
)

SELECT 
  customer_state,
  avg_diff_days    -- Negative value = delivered early
FROM state_delivery_speed
ORDER BY avg_diff_days ASC
LIMIT 5;


#PAYMENT TYPE DISTRIBUTION

SELECT 
  payment_type,
  COUNT(DISTINCT order_id) AS num_orders,
  ROUND(
    COUNT(DISTINCT order_id) * 100.0 /
    SUM(COUNT(DISTINCT order_id)) OVER(),
    2
  ) AS percentage_orders
FROM `TARGET_SQL.Payments`
GROUP BY payment_type
ORDER BY num_orders DESC;


#INSTALLMENT DISTRIBUTION


SELECT 
  payment_installments,
  COUNT(DISTINCT order_id) AS num_orders,
  ROUND(
    COUNT(DISTINCT order_id) * 100.0 /
    SUM(COUNT(DISTINCT order_id)) OVER(),
    2
  ) AS percentage_orders
FROM `TARGET_SQL.Payments`
GROUP BY payment_installments
ORDER BY payment_installments;












