WITH savings_summary AS (
    SELECT 
        s.owner_id,
        COUNT(DISTINCT s.id) AS savings_count,
        SUM(s.confirmed_amount) / 100 AS total_deposits
    FROM savings_savingsaccount s
    JOIN plans_plan p ON s.plan_id = p.id
    WHERE s.confirmed_amount > 0
      AND p.is_regular_savings = 1
    GROUP BY s.owner_id
),
investment_summary AS (
    SELECT 
        owner_id,
        COUNT(DISTINCT id) AS investment_count
    FROM plans_plan
    WHERE is_a_fund = 1
    GROUP BY owner_id
)
SELECT 
    s.owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    s.savings_count,
    i.investment_count,
    s.total_deposits
FROM users_customuser u
JOIN savings_summary s ON u.id = s.owner_id
JOIN investment_summary i ON u.id = i.owner_id
ORDER BY s.total_deposits DESC;
