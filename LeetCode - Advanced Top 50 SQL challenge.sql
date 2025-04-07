'Here I dont want to waste your precious time by posting all the 50 challenge questions. 
Instead, I am going to post only the selected queries, which look interesting and difficult for me.


# 1357-report-contiguous-dates

'''
WITH CombinedDates AS (
    SELECT 'succeeded' AS period_state, success_date AS event_date
    FROM Succeeded
    WHERE YEAR(success_date) = 2019
    
    UNION ALL
    
    SELECT 'failed' AS period_state, fail_date AS event_date
    FROM Failed
    WHERE YEAR(fail_date) = 2019
),

DateGroups AS (
    SELECT 
        period_state,
        event_date,
        DATEADD(DAY, -ROW_NUMBER() OVER (PARTITION BY period_state ORDER BY event_date), event_date) AS date_group
    FROM CombinedDates
)

SELECT 
    period_state,
    MIN(event_date) AS start_date,
    MAX(event_date) AS end_date
FROM DateGroups
GROUP BY period_state, date_group
ORDER BY start_date;
'''    

    
# 0603-consecutive-available-seats

'''
SELECT DISTINCT seat_id
FROM (
    SELECT seat_id,
           free,
           LAG(free, 1) OVER (ORDER BY seat_id) AS prev_free,
           LEAD(free, 1) OVER (ORDER BY seat_id) AS next_free
    FROM Cinema
) t
WHERE free = 1 AND (prev_free = 1 OR next_free = 1)
ORDER BY seat_id;
'''


1291-immediate-food-delivery-i

'''    
SELECT ROUND(
    AVG(CASE WHEN order_date = customer_pref_delivery_date THEN 100 ELSE 0 END),
    2
) AS immediate_percentage
FROM Delivery;
'''

# 1339-team-scores-in-football-tournament

'''    
WITH TeamScores AS (
    -- Calculate points for host teams
    SELECT 
        host_team AS team_id,
        SUM(CASE 
            WHEN host_goals > guest_goals THEN 3
            WHEN host_goals = guest_goals THEN 1
            ELSE 0
        END) AS points
    FROM Matches
    GROUP BY host_team
    
    UNION ALL
    
    -- Calculate points for guest teams
    SELECT 
        guest_team AS team_id,
        SUM(CASE 
            WHEN guest_goals > host_goals THEN 3
            WHEN guest_goals = host_goals THEN 1
            ELSE 0
        END) AS points
    FROM Matches
    GROUP BY guest_team
),

AggregatedScores AS (
    SELECT 
        team_id,
        SUM(points) AS num_points
    FROM TeamScores
    GROUP BY team_id
)

SELECT 
    t.team_id,
    t.team_name,
    COALESCE(a.num_points, 0) AS num_points
FROM Teams t
LEFT JOIN AggregatedScores a ON t.team_id = a.team_id
ORDER BY num_points DESC, team_id ASC;
'''


# 1536-customers-who-bought-products-a-and-b-but-not-c

'''
SELECT c.customer_id, c.customer_name
FROM Customers c
WHERE EXISTS (
    SELECT 1 FROM Orders o 
    WHERE o.customer_id = c.customer_id AND o.product_name = 'A'
)
AND EXISTS (
    SELECT 1 FROM Orders o 
    WHERE o.customer_id = c.customer_id AND o.product_name = 'B'
)
AND NOT EXISTS (
    SELECT 1 FROM Orders o 
    WHERE o.customer_id = c.customer_id AND o.product_name = 'C'
)
ORDER BY c.customer_id;
'''


# 1546-find-the-quiet-students-in-all-exams
    
'''
WITH ExamScores AS (
    SELECT 
        student_id,
        exam_id,
        score,
        MIN(score) OVER (PARTITION BY exam_id) AS min_score,
        MAX(score) OVER (PARTITION BY exam_id) AS max_score
    FROM Exam
),

QuietStudents AS (
    SELECT DISTINCT e.student_id
    FROM ExamScores e
    GROUP BY e.student_id
    HAVING 
        -- Never had the lowest score in any exam
        SUM(CASE WHEN e.score = e.min_score THEN 1 ELSE 0 END) = 0
        AND
        -- Never had the highest score in any exam
        SUM(CASE WHEN e.score = e.max_score THEN 1 ELSE 0 END) = 0
)

SELECT s.student_id, s.student_name
FROM Student s
WHERE s.student_id IN (
    SELECT student_id FROM Exam  -- Students who took at least one exam
)
AND s.student_id IN (
    SELECT student_id FROM QuietStudents  -- Quiet students
)
ORDER BY s.student_id;
'''


# 1641-countries-you-can-safely-invest-in

'''
WITH CallDurations AS (
    -- Get all callers with their country codes and durations
    SELECT 
        c.caller_id AS person_id,
        LEFT(p.phone_number, 3) AS country_code,
        c.duration
    FROM Calls c
    JOIN Person p ON c.caller_id = p.id
    
    UNION ALL
    
    -- Get all callees with their country codes and durations
    SELECT 
        c.callee_id AS person_id,
        LEFT(p.phone_number, 3) AS country_code,
        c.duration
    FROM Calls c
    JOIN Person p ON c.callee_id = p.id
),

CountryAverages AS (
    SELECT 
        co.name AS country_name,
        AVG(cd.duration * 1.0) AS country_avg_duration
    FROM CallDurations cd
    JOIN Country co ON cd.country_code = co.country_code
    GROUP BY co.name
),

GlobalAverage AS (
    SELECT AVG(duration * 1.0) AS global_avg
    FROM Calls
)

SELECT 
    ca.country_name AS country
FROM CountryAverages ca
CROSS JOIN GlobalAverage ga
WHERE ca.country_avg_duration > ga.global_avg
ORDER BY ca.country_name;
'''


# 1654-customer-order-frequency

'''
WITH MonthlySpending AS (
    SELECT 
        o.customer_id,
        c.name,
        FORMAT(o.order_date, 'yyyy-MM') AS month,
        SUM(o.quantity * p.price) AS monthly_total
    FROM Orders o
    JOIN Customers c ON o.customer_id = c.customer_id
    JOIN Product p ON o.product_id = p.product_id
    WHERE FORMAT(o.order_date, 'yyyy-MM') IN ('2020-06', '2020-07')
    GROUP BY o.customer_id, c.name, FORMAT(o.order_date, 'yyyy-MM')
),

JuneHighSpenders AS (
    SELECT customer_id, name
    FROM MonthlySpending
    WHERE month = '2020-06'
    GROUP BY customer_id, name
    HAVING SUM(monthly_total) >= 100
)

SELECT 
    ms.customer_id,
    ms.name
FROM MonthlySpending ms
WHERE ms.month = '2020-07'
AND ms.customer_id IN (SELECT customer_id FROM JuneHighSpenders)
GROUP BY ms.customer_id, ms.name
HAVING SUM(monthly_total) >= 100
ORDER BY ms.customer_id;
'''


# 1842-number-of-calls-between-two-persons

'''
SELECT 
    LEAST(from_id, to_id) AS person1,
    GREATEST(from_id, to_id) AS person2,
    COUNT(*) AS call_count,
    SUM(duration) AS total_duration
FROM Calls
GROUP BY 
    LEAST(from_id, to_id),
    GREATEST(from_id, to_id)
ORDER BY person1, person2;
'''


# 1852-biggest-window-between-visits

'''
WITH VisitGaps AS (
    SELECT 
        user_id,
        visit_date,
        -- Calculate days between current and next visit
        DATEDIFF(
            day, 
            visit_date, 
            LEAD(visit_date) OVER (PARTITION BY user_id ORDER BY visit_date)
        ) AS gap_days
    FROM UserVisits
),

FirstLastGaps AS (
    SELECT 
        user_id,
        -- Days between first visit and '2021-01-01'
        DATEDIFF(day, MIN(visit_date), '2021-01-01') AS first_gap,
        -- Days between last visit and '2021-01-01'
        DATEDIFF(day, MAX(visit_date), '2021-01-01') AS last_gap
    FROM UserVisits
    GROUP BY user_id
),

AllGaps AS (
    -- Gaps between visits
    SELECT user_id, gap_days AS window_size
    FROM VisitGaps
    WHERE gap_days IS NOT NULL
    
    UNION ALL
    
    -- Gap before first visit
    SELECT user_id, first_gap AS window_size
    FROM FirstLastGaps
    
    UNION ALL
    
    -- Gap after last visit
    SELECT user_id, last_gap AS window_size
    FROM FirstLastGaps
)

SELECT 
    user_id,
    MAX(window_size) AS biggest_window
FROM AllGaps
GROUP BY user_id
ORDER BY user_id;
'''


# 1898-leetflex-banned-accounts

'''
WITH OverlappingSessions AS (
    SELECT DISTINCT
        l1.account_id
    FROM LogInfo l1
    JOIN LogInfo l2 ON 
        l1.account_id = l2.account_id 
        AND l1.ip_address != l2.ip_address
        AND (
            (l1.login BETWEEN l2.login AND l2.logout) OR
            (l1.logout BETWEEN l2.login AND l2.logout) OR
            (l2.login BETWEEN l1.login AND l1.logout) OR
            (l2.logout BETWEEN l1.login AND l1.logout)
        )
)

SELECT account_id
FROM OverlappingSessions
ORDER BY account_id;
'''


# 1914-find-the-subtasks-that-did-not-execute

'''
WITH RECURSIVE TaskSubtaskRange AS (
    -- Base case: Start with 1
    SELECT 1 AS subtask_id
    
    UNION ALL
    
    -- Recursive case: Increment until 20
    SELECT subtask_id + 1
    FROM TaskSubtaskRange
    WHERE subtask_id < 20
),

AllPossibleSubtasks AS (
    SELECT 
        t.task_id,
        ts.subtask_id
    FROM Tasks t
    JOIN TaskSubtaskRange ts ON ts.subtask_id <= t.subtasks_count
)

SELECT 
    a.task_id,
    a.subtask_id
FROM AllPossibleSubtasks a
LEFT JOIN Executed e ON 
    a.task_id = e.task_id AND 
    a.subtask_id = e.subtask_id
WHERE e.task_id IS NULL
ORDER BY a.task_id, a.subtask_id;
'''


# 1948-rearrange-products-table

'''
SELECT 
    product_id,
    'store1' AS store,
    store1 AS price
FROM Products
WHERE store1 IS NOT NULL

UNION ALL

SELECT 
    product_id,
    'store2' AS store,
    store2 AS price
FROM Products
WHERE store2 IS NOT NULL

UNION ALL

SELECT 
    product_id,
    'store3' AS store,
    store3 AS price
FROM Products
WHERE store3 IS NOT NULL

ORDER BY product_id, store;
'''
