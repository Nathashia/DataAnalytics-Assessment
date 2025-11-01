-- Analyze average number of transactions per customer per month
-- Classify customers by frequency: High, Medium, or Low

-- Step 1: Count transactions per customer per month
WITH monthly_txn AS (
    SELECT 
        owner_id,
        COUNT(*) AS txn_count,
        MONTH(transaction_date) AS month
    FROM savings_savingsaccount
    GROUP BY owner_id, MONTH(transaction_date)
),

-- Step 2: Calculate average monthly transactions per customer
avg_txn_per_cust AS (
    SELECT 
        owner_id,
        AVG(txn_count) AS avg_txn_per_month
    FROM monthly_txn
    GROUP BY owner_id
)

-- Step 3: Categorize customers based on average transaction frequency
SELECT 
    CASE 
        WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
        WHEN avg_txn_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,                        -- Category based on average frequency
    COUNT(*) AS customer_count,                       -- Number of customers in each category
    ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month  -- Average monthly txns
FROM avg_txn_per_cust
GROUP BY frequency_category
ORDER BY avg_transactions_per_month DESC;
