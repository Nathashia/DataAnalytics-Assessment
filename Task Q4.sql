-- Estimate CLV using account tenure and transaction volume

-- Step 1: Aggregate basic metrics per customer
WITH customer_txns AS (
    SELECT 
        u.id AS customer_id,                          -- Customer ID
		CONCAT(u.first_name, ' ', u.last_name) AS name, -- Customer name
        MIN(u.date_joined) AS joined_date,            -- Signup date
        COUNT(s.id) AS total_transactions,            -- Total transactions
        SUM(s.confirmed_amount) AS total_amount       -- Total transaction value (in kobo)
    FROM users_customuser u
    JOIN savings_savingsaccount s ON u.id = s.owner_id
    GROUP BY u.id, u.name
),

-- Step 2: Calculate tenure and estimate CLV
clv_calc AS (
    SELECT 
        customer_id,
        name,
        TIMESTAMPDIFF(MONTH, joined_date, CURDATE()) AS tenure_months, -- Duration in months
        total_transactions,
        (total_amount / NULLIF(total_transactions, 0)) * 0.001 AS avg_profit_per_txn, -- 0.1% of transaction value in naira
        ROUND((total_transactions / NULLIF(TIMESTAMPDIFF(MONTH, joined_date, CURDATE()), 0)) 
              * 12 * ((total_amount / NULLIF(total_transactions, 0)) * 0.001), 2) AS estimated_clv -- CLV formula
    FROM customer_txns
)

-- Step 3: Show final output sorted by CLV
SELECT customer_id, name, tenure_months, total_transactions, estimated_clv
FROM clv_calc
ORDER BY estimated_clv DESC;
