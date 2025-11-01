SELECT 
    p.id AS plan_id,
    p.owner_id,
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Unknown'
    END AS type,
    last_txn.last_transaction_date,
    DATEDIFF(CURDATE(), last_txn.last_transaction_date) AS inactivity_days
FROM plans_plan p
LEFT JOIN (
    SELECT 
        owner_id, 
        MAX(transaction_date) AS last_transaction_date
    FROM savings_savingsaccount
    GROUP BY owner_id
) last_txn ON p.owner_id = last_txn.owner_id
WHERE (p.is_a_fund = 1 OR p.is_regular_savings = 1)
AND (last_txn.last_transaction_date IS NULL OR last_txn.last_transaction_date < CURDATE() - INTERVAL 365 DAY);
