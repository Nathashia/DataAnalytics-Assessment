## Introduction

This repository contains solutions to a series of SQL-based data analytics assessment questions designed to analyze customer and transaction data within a financial services context. The goal of these analyses is to provide actionable business insights that support customer segmentation, product cross-selling, customer engagement, and lifetime value estimation.

The four assessment tasks focus on:

1. **Identifying inactive savings or investment accounts** — to highlight customers with no inflow transactions over the past year, supporting re-engagement strategies.
2. **Finding high-value customers with multiple financial products** — to identify customers holding both savings and investment plans, enabling targeted cross-selling opportunities.
3. **Classifying customers by transaction frequency** — to categorize customers as high, medium, or low frequency based on their average monthly transactions, aiding in tailored marketing campaigns.
4. **Estimating Customer Lifetime Value (CLV)** — combining transaction volume and account tenure to prioritize customers based on their potential long-term profitability.

Each query is carefully constructed to optimize performance, handle data quality considerations, and deliver meaningful business intelligence to support strategic decision-making in customer relationship management and product development.

## Q1 Query Explanation

The primary goal of the main query is to **identify customers who have both a funded regular savings plan and a funded investment plan**

### Key Points:
- Savings accounts are filtered by joining the `savings_savingsaccount` table with the `plans_plan` table on `plan_id`, to include only accounts linked to regular savings plans (`is_regular_savings = 1`).
- Investment plans are identified in the `plans_plan` table where `is_a_fund = 1`.
- Two Common Table Expressions (CTEs) summarize:
  - Number of savings accounts and total deposits per customer (converted from kobo to naira).
  - Number of investment plans per customer.
- These summaries are joined with `users_customuser` to fetch customer details.
- `first_name` and `last_name` fields are concatenated to form the full customer name.
- The query returns only customers with **at least one funded savings plan and one funded investment plan**.
- Results are ordered by total deposits descending to highlight top customers.

### Challenges and Solutions:
- The `is_regular_savings` flag is only available in the `plans_plan` table, requiring a join to properly filter savings accounts.
- Customer names are split across `first_name` and `last_name`, so concatenation was used for clarity.
- CTEs were used to break down the query logically and improve readability.


## Q2 Customer Transaction Frequency Analysis

### Objective
This query analyzes customer transaction behavior by calculating the **average number of transactions per customer per month** and categorizing customers into three frequency groups: **High Frequency**, **Medium Frequency**, and **Low Frequency**.

### Thought Process

1. **Count transactions per customer per month:**  
   Transactions are grouped by customer (`owner_id`) and by month (extracted from `transaction_date`) to count how many transactions each customer made monthly.

2. **Calculate average monthly transactions per customer:**  
   Using the monthly transaction counts, the average transactions per month for each customer is computed to smooth out variations and identify typical customer activity levels.

3. **Classify customers by frequency:**  
   Customers are categorized based on average monthly transactions:
   - **High Frequency:** 10 or more transactions per month
   - **Medium Frequency:** 3 to 9 transactions per month
   - **Low Frequency:** fewer than 3 transactions per month

4. **Summarize frequency categories:**  
   The final result shows how many customers fall into each category and the average transactions per month within each group.

### Challenges and Solutions

- **Monthly grouping of transactions:**  
  Grouping transactions by month required extracting the month from the transaction date using the `MONTH()` function.

- **Handling months with no transactions:**  
  The average calculation considers only months with transactions; months without data are implicitly treated as zero or missing.

This analysis helps identify customer segments for targeted marketing and service improvements based on transaction activity.



## Q3 Identify Inactive Savings and Investment Plans

### Objective
This query aims to find **savings or investment accounts that have had no inflow transactions in the last 365 days**. It helps the business identify inactive customer accounts for possible re-engagement or cleanup.

### Thought Process

1. **Determine account types:**  
   Using the `plans_plan` table, each plan is classified as either a **Savings** plan (`is_regular_savings = 1`) or an **Investment** plan (`is_a_fund = 1`). If neither applies, the type is marked as `'Unknown'`.

2. **Find last transaction date per customer:**  
   To check for inactivity, the query finds the **most recent transaction date** for each customer from the `savings_savingsaccount` table using a subquery that groups by `owner_id`.

3. **Link plans to last transaction dates:**  
   A `LEFT JOIN` is used to associate each plan with the customer’s last transaction date. This ensures that plans without any transaction record (i.e., no transactions ever) are included as well.

**Filter inactive plans:**  
   The main query filters plans where the last transaction date is either:
   - **Null:** no transaction recorded at all, or
   - **Older than 365 days:** indicating inactivity for over a year.

5. **Calculate inactivity period:**  
   The number of days since the last transaction is calculated using `DATEDIFF()` for additional insight.

### Challenges and Solutions

- **Handling customers with no transactions:**  
  Using a `LEFT JOIN` allows inclusion of customers without any transaction history by returning `NULL` for `last_transaction_date`.

- **Efficiently getting the last transaction date:**  
  Using a subquery with `GROUP BY owner_id` and `MAX(transaction_date)` efficiently finds the latest transaction per customer.

- **Filtering by inactivity period:**  
  The condition `(last_transaction_date IS NULL OR last_transaction_date < CURDATE() - INTERVAL 365 DAY)` handles both no transactions and long inactivity.


## Q4 Customer Lifetime Value (CLV) Estimation

### Objective
Estimate the **Customer Lifetime Value (CLV)** based on customers’ transaction history and account tenure. This helps prioritize high-value customers and tailor marketing or retention strategies.

### Thought Process

1. **Aggregate customer transaction data:**  
   In the first Common Table Expression (CTE) `customer_txns`:
   - Retrieve customer details (`id`, concatenated full name).
   - Find the customer's signup date (`date_joined`).
   - Calculate total transactions count and total transaction value (in kobo) from the `savings_savingsaccount` table.

2. **Calculate account tenure and average profit:**  
   In the second CTE `clv_calc`, we:
   - Calculate the customer tenure in months using `TIMESTAMPDIFF` between `date_joined` and today.
   - Calculate the average profit per transaction as 0.1% of the transaction amount (converted from kobo to naira).
   - Estimate CLV by:
     - Calculating average transactions per month (`total_transactions / tenure_months`).
     - Annualizing this monthly transaction frequency by multiplying by 12.
     - Multiplying annual transactions by average profit per transaction.
   - The `ROUND` function formats the CLV value to two decimal places.

3. **Present sorted results:**  
   The final `SELECT` outputs the customer ID, name, tenure in months, total transactions, and estimated CLV, sorted by descending CLV to highlight the highest-value customers.

### Challenges and Solutions

- **Avoiding division by zero:**  
  We use `NULLIF(..., 0)` in denominators to prevent division by zero errors if a customer has zero transactions or zero tenure.

- **Handling transaction amounts in kobo:**  
  Since transaction amounts are stored in kobo, we convert to naira by dividing by 1000 (`* 0.001`) for profit calculations.

- **Estimating CLV simply but meaningfully:**  
  The formula balances transaction frequency and monetary value over tenure, giving a reasonable estimate of lifetime value without complex predictive modeling.




