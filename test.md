# 🍕 Case Study #2 - Pizza Runner

## 🍝 Solution - A. Pizza Metrics _[MS SQL Server]_
## 🍝 Solution - A. Pizza Metrics

### 1. How many pizzas were ordered?

````sql
SELECT COUNT(*) AS pizza_order_count
FROM #customer_orders;
````

**Answer:**

@@ -15,9 +17,11 @@ FROM #customer_orders;

### 2. How many unique customer orders were made?

````sql
SELECT 
  COUNT(DISTINCT order_id) AS unique_order_count
FROM #customer_orders;
````

**Answer:**

@@ -26,23 +30,156 @@ FROM #customer_orders;
