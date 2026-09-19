/* ================================================================
   EV CHARGING NETWORK ANALYTICS
   Advanced SQL Business Analysis
   ================================================================
   Database  : ev_charging_analytics
   Period    : January 2023 - December 2025
   Purpose   : Business, customer, station, revenue and operations
               analysis for an EV charging network.
   ================================================================ */


/* ================================================================
   00. DATABASE & TABLE SETUP
   ================================================================ */

USE ev_charging_analytics;


/* ----------------------------------------------------------------
   00.1 Locations
   ---------------------------------------------------------------- */

CREATE TABLE locations (
    location_id INT PRIMARY KEY,
    city VARCHAR(50),
    state VARCHAR(50),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    location_type VARCHAR(30),
    population_density INT
);


/* ----------------------------------------------------------------
   00.2 Stations
   ---------------------------------------------------------------- */

CREATE TABLE stations (
    station_id INT PRIMARY KEY,
    location_id INT,
    station_name VARCHAR(100),
    opened_date DATE,
    status VARCHAR(20),
    parking_slots INT
);


/* ----------------------------------------------------------------
   00.3 Chargers
   ---------------------------------------------------------------- */

CREATE TABLE chargers (
    charger_id INT PRIMARY KEY,
    station_id INT,
    charger_type VARCHAR(20),
    power_kw DECIMAL(6,2),
    connector_type VARCHAR(30),
    installation_date DATE,
    status VARCHAR(20)
);


/* ----------------------------------------------------------------
   00.4 Customers
   ---------------------------------------------------------------- */

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    signup_date DATE,
    customer_segment VARCHAR(30),
    city VARCHAR(50),
    acquisition_channel VARCHAR(30),
    date_of_birth DATE
);


/* ----------------------------------------------------------------
   00.5 Vehicles
   ---------------------------------------------------------------- */

CREATE TABLE vehicles (
    vehicle_id INT PRIMARY KEY,
    customer_id INT,
    vehicle_model VARCHAR(50),
    vehicle_type VARCHAR(30),
    battery_capacity_kwh DECIMAL(6,2),
    purchase_year YEAR
);


/* ----------------------------------------------------------------
   00.6 Subscriptions
   ---------------------------------------------------------------- */

CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY,
    customer_id INT,
    plan_name VARCHAR(30),
    start_date DATE,
    end_date DATE,
    monthly_fee DECIMAL(8,2),
    status VARCHAR(20)
);


/* ----------------------------------------------------------------
   00.7 Charging Sessions
   ---------------------------------------------------------------- */

CREATE TABLE charging_sessions (
    session_id BIGINT PRIMARY KEY,
    customer_id INT,
    vehicle_id INT,
    charger_id INT,
    start_time DATETIME,
    end_time DATETIME,
    energy_kwh DECIMAL(8,2),
    session_status VARCHAR(20),
    amount DECIMAL(10,2)
);


/* ----------------------------------------------------------------
   00.8 Payments
   ---------------------------------------------------------------- */

CREATE TABLE payments (
    payment_id BIGINT PRIMARY KEY,
    session_id BIGINT,
    payment_date DATETIME,
    payment_method VARCHAR(20),
    amount_paid DECIMAL(10,2),
    payment_status VARCHAR(20)
);


/* ----------------------------------------------------------------
   00.9 Maintenance
   ---------------------------------------------------------------- */

CREATE TABLE maintenance (
    maintenance_id INT PRIMARY KEY,
    charger_id INT,
    issue_type VARCHAR(40),
    reported_date DATETIME,
    resolved_date DATETIME,
    downtime_hours DECIMAL(8,2),
    maintenance_cost DECIMAL(10,2),
    status VARCHAR(20)
);


/* ----------------------------------------------------------------
   00.10 Energy Consumption
   ---------------------------------------------------------------- */

CREATE TABLE energy_consumption (
    energy_id BIGINT PRIMARY KEY,
    session_id BIGINT,
    energy_kwh DECIMAL(8,2),
    energy_cost DECIMAL(10,2),
    recorded_at DATETIME
);


/* ================================================================
   01. DATABASE & IMPORT VERIFICATION
   ================================================================ */

SHOW TABLES;

SHOW VARIABLES LIKE 'secure_file_priv';


/* ----------------------------------------------------------------
   01.1 Load Charging Sessions
   ---------------------------------------------------------------- */

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/charging_sessions.csv'
INTO TABLE charging_sessions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS charging_session_rows
FROM charging_sessions;


/* ----------------------------------------------------------------
   01.2 Load Payments
   ---------------------------------------------------------------- */

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/payments.csv'
INTO TABLE payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS payment_rows
FROM payments;


/* ----------------------------------------------------------------
   01.3 Load Energy Consumption
   ---------------------------------------------------------------- */

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/energy_consumption.csv'
INTO TABLE energy_consumption
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(energy_id, session_id, energy_kwh, recorded_at, energy_cost);


/* ================================================================
   02. DATASET ROW-COUNT VALIDATION
   ================================================================ */

SELECT
    'locations' AS table_name,
    COUNT(*) AS row_count
FROM locations

UNION ALL

SELECT 'stations', COUNT(*)
FROM stations

UNION ALL

SELECT 'chargers', COUNT(*)
FROM chargers

UNION ALL

SELECT 'customers', COUNT(*)
FROM customers

UNION ALL

SELECT 'vehicles', COUNT(*)
FROM vehicles

UNION ALL

SELECT 'subscriptions', COUNT(*)
FROM subscriptions

UNION ALL

SELECT 'charging_sessions', COUNT(*)
FROM charging_sessions

UNION ALL

SELECT 'payments', COUNT(*)
FROM payments

UNION ALL

SELECT 'energy_consumption', COUNT(*)
FROM energy_consumption

UNION ALL

SELECT 'maintenance', COUNT(*)
FROM maintenance;


/* ================================================================
   03. DATA QUALITY CHECKS
   ================================================================ */


/* ----------------------------------------------------------------
   03.1 Customer Duplicate Check
   ---------------------------------------------------------------- */

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customer_ids
FROM customers;


/* ----------------------------------------------------------------
   03.2 Vehicle Duplicate Check
   ---------------------------------------------------------------- */

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT vehicle_id) AS unique_vehicle_ids
FROM vehicles;


/* ----------------------------------------------------------------
   03.3 Station Duplicate Check
   ---------------------------------------------------------------- */

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT station_id) AS unique_station_ids
FROM stations;


/* ----------------------------------------------------------------
   03.4 Customer NULL Check
   ---------------------------------------------------------------- */

SELECT
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN signup_date IS NULL THEN 1 ELSE 0 END) AS null_signup_date,
    SUM(CASE WHEN customer_segment IS NULL THEN 1 ELSE 0 END) AS null_customer_segment,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN acquisition_channel IS NULL THEN 1 ELSE 0 END) AS null_acquisition_channel
FROM customers;


/* ----------------------------------------------------------------
   03.5 Charging Session NULL Check
   ---------------------------------------------------------------- */

SELECT
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN vehicle_id IS NULL THEN 1 ELSE 0 END) AS null_vehicle_id,
    SUM(CASE WHEN charger_id IS NULL THEN 1 ELSE 0 END) AS null_charger_id,
    SUM(CASE WHEN start_time IS NULL THEN 1 ELSE 0 END) AS null_start_time,
    SUM(CASE WHEN end_time IS NULL THEN 1 ELSE 0 END) AS null_end_time,
    SUM(CASE WHEN energy_kwh IS NULL THEN 1 ELSE 0 END) AS null_energy_kwh,
    SUM(CASE WHEN session_status IS NULL THEN 1 ELSE 0 END) AS null_session_status,
    SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) AS null_amount
FROM charging_sessions;


/* ----------------------------------------------------------------
   03.6 Invalid Value / Date Consistency Check
   ---------------------------------------------------------------- */

SELECT *
FROM charging_sessions
WHERE energy_kwh < 0
   OR amount < 0
   OR end_time < start_time;


/* ----------------------------------------------------------------
   03.7 Customer Foreign-Key / Orphan Check
   ---------------------------------------------------------------- */

SELECT *
FROM charging_sessions
LEFT JOIN customers
    ON charging_sessions.customer_id = customers.customer_id
WHERE customers.customer_id IS NULL;


/* ----------------------------------------------------------------
   03.8 Vehicle Foreign-Key / Orphan Check
   ---------------------------------------------------------------- */

SELECT *
FROM charging_sessions
LEFT JOIN vehicles
    ON charging_sessions.vehicle_id = vehicles.vehicle_id
WHERE vehicles.vehicle_id IS NULL;


/* ----------------------------------------------------------------
   03.9 Charger Foreign-Key / Orphan Check
   ---------------------------------------------------------------- */

SELECT *
FROM charging_sessions
LEFT JOIN chargers
    ON charging_sessions.charger_id = chargers.charger_id
WHERE chargers.charger_id IS NULL;


/* ----------------------------------------------------------------
   03.10 Payment Completeness Check
   ---------------------------------------------------------------- */

SELECT *
FROM charging_sessions
LEFT JOIN payments
    ON payments.session_id = charging_sessions.session_id
WHERE payments.session_id IS NULL;


/* ----------------------------------------------------------------
   03.11 Energy Record Completeness Check
   ---------------------------------------------------------------- */

SELECT COUNT(*) AS missing_energy_records
FROM charging_sessions cs
LEFT JOIN energy_consumption ec
    ON cs.session_id = ec.session_id
WHERE ec.session_id IS NULL;


/* ----------------------------------------------------------------
   03.12 Payment Amount Reconciliation
   ---------------------------------------------------------------- */

SELECT
    COUNT(*) AS mismatch_count
FROM charging_sessions cs
JOIN payments p
    ON cs.session_id = p.session_id
WHERE cs.session_status = 'Completed'
  AND p.payment_status = 'Success'
  AND cs.amount <> p.amount_paid;


/* ================================================================
   04. CORE BUSINESS KPIs
   ================================================================ */


/* KPI 1: Total Successful Charging Sessions */

SELECT
    COUNT(charger_id) AS total_successful_sessions
FROM charging_sessions
WHERE session_status = 'Completed';


/* KPI 2: Total Revenue from Successful Sessions */

SELECT
    SUM(amount) AS total_revenue
FROM charging_sessions
WHERE session_status = 'Completed';


/* KPI 3: Total Energy Delivered */

SELECT
    SUM(energy_kwh) AS total_energy_kwh
FROM energy_consumption;


/* KPI 4: Unique Customers Using the Network */

SELECT
    COUNT(DISTINCT customer_id) AS active_customers
FROM charging_sessions;


/* KPI 5: Average Revenue per Successful Session */

SELECT
    AVG(amount) AS avg_revenue_per_successful_session
FROM charging_sessions
WHERE session_status = 'Completed';


/* KPI 6: Average Energy per Successful Session */

SELECT
    AVG(ec.energy_kwh) AS avg_energy_per_successful_session
FROM charging_sessions cs
JOIN energy_consumption ec
    ON cs.session_id = ec.session_id
WHERE cs.session_status = 'Completed';


/* KPI 7: Payment Success Rate */

SELECT
    (
        SELECT COUNT(*)
        FROM payments
        WHERE payment_status = 'Success'
    ) / COUNT(*) AS payment_success_rate
FROM payments;


/* KPI 8: Average Session Duration */

WITH session_duration AS (
    SELECT
        TIMESTAMPDIFF(MINUTE, start_time, end_time) AS duration_minutes
    FROM charging_sessions
)

SELECT
    AVG(duration_minutes) AS avg_session_duration_minutes
FROM session_duration;


/* KPI 9: Station Utilization */

SELECT
    s.station_id,
    COUNT(*) AS total_sessions
FROM charging_sessions cs
JOIN chargers c
    ON cs.charger_id = c.charger_id
JOIN stations s
    ON c.station_id = s.station_id
GROUP BY s.station_id
ORDER BY total_sessions DESC;


/* KPI 10: Revenue per Station */

SELECT
    s.station_id,
    SUM(cs.amount) AS total_revenue
FROM charging_sessions cs
JOIN chargers c
    ON cs.charger_id = c.charger_id
JOIN stations s
    ON c.station_id = s.station_id
GROUP BY s.station_id
ORDER BY total_revenue DESC;


/* KPI 11: Average Downtime per Charger */

SELECT
    charger_id,
    AVG(downtime_hours) AS avg_downtime_hours
FROM maintenance
GROUP BY charger_id;


/* KPI 12: Revenue per kWh */

SELECT
    SUM(cs.amount) / SUM(ec.energy_kwh) AS revenue_per_kwh
FROM charging_sessions cs
JOIN energy_consumption ec
    ON cs.session_id = ec.session_id;


/* KPI 13: Sessions per Active Customer */

SELECT
    COUNT(*) / COUNT(DISTINCT customer_id) AS sessions_per_customer
FROM charging_sessions;


/* KPI 14: Successful Session Rate */

SELECT
    (
        SELECT COUNT(*)
        FROM charging_sessions
        WHERE session_status = 'Completed'
    ) / COUNT(*) * 100 AS successful_session_rate
FROM charging_sessions;


/* ================================================================
   05. ADVANCED BUSINESS ANALYSIS
   ================================================================ */


/* ----------------------------------------------------------------
   Q1. Monthly Charging Demand
   ---------------------------------------------------------------- */

SELECT
    YEAR(start_time) AS year,
    MONTH(start_time) AS month,
    COUNT(*) AS total_sessions
FROM charging_sessions
GROUP BY
    YEAR(start_time),
    MONTH(start_time)
ORDER BY
    year,
    month;


/* ----------------------------------------------------------------
   Q2. Monthly Revenue
   ---------------------------------------------------------------- */

SELECT
    YEAR(start_time) AS year,
    MONTH(start_time) AS month,
    SUM(amount) AS total_revenue
FROM charging_sessions
WHERE session_status = 'Completed'
GROUP BY
    YEAR(start_time),
    MONTH(start_time)
ORDER BY
    year,
    month;


/* ----------------------------------------------------------------
   Q3. Monthly Energy Consumption
   ---------------------------------------------------------------- */

SELECT
    YEAR(recorded_at) AS year,
    MONTH(recorded_at) AS month,
    SUM(energy_kwh) AS total_energy_kwh
FROM energy_consumption
GROUP BY
    YEAR(recorded_at),
    MONTH(recorded_at)
ORDER BY
    year,
    month;


/* ----------------------------------------------------------------
   Q4. Monthly Active Customers
   ---------------------------------------------------------------- */

SELECT
    YEAR(start_time) AS year,
    MONTH(start_time) AS month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM charging_sessions
GROUP BY
    YEAR(start_time),
    MONTH(start_time)
ORDER BY
    year,
    month;


/* ----------------------------------------------------------------
   Q5. Month-over-Month Session Growth
   ---------------------------------------------------------------- */

WITH monthly_sessions AS (
    SELECT
        YEAR(start_time) AS year,
        MONTH(start_time) AS month,
        COUNT(*) AS current_month_sessions
    FROM charging_sessions
    GROUP BY
        YEAR(start_time),
        MONTH(start_time)
),

session_growth AS (
    SELECT
        *,
        LAG(current_month_sessions) OVER (
            ORDER BY year, month
        ) AS previous_month_sessions
    FROM monthly_sessions
)

SELECT
    year,
    month,
    current_month_sessions,
    previous_month_sessions,
    (
        (current_month_sessions - previous_month_sessions)
        / previous_month_sessions
    ) * 100 AS mom_growth_percentage
FROM session_growth;


/* ----------------------------------------------------------------
   Q6. City Performance
   ---------------------------------------------------------------- */

SELECT
    l.city,
    COUNT(*) AS total_sessions,

    SUM(
        CASE
            WHEN cs.session_status = 'Completed' THEN 1
            ELSE 0
        END
    ) AS successful_sessions,

    SUM(
        CASE
            WHEN cs.session_status = 'Completed' THEN cs.amount
            ELSE 0
        END
    ) AS total_revenue,

    SUM(
        CASE
            WHEN cs.session_status = 'Completed' THEN ec.energy_kwh
            ELSE 0
        END
    ) AS total_energy_kwh

FROM charging_sessions cs
JOIN chargers c
    ON cs.charger_id = c.charger_id
JOIN stations s
    ON c.station_id = s.station_id
JOIN locations l
    ON s.location_id = l.location_id
JOIN energy_consumption ec
    ON cs.session_id = ec.session_id

GROUP BY l.city
ORDER BY total_revenue DESC;


/* ----------------------------------------------------------------
   Q7. Station Performance
   ---------------------------------------------------------------- */

SELECT
    s.station_id,
    s.station_name,
    COUNT(*) AS total_sessions,

    SUM(
        CASE
            WHEN cs.session_status = 'Completed' THEN 1
            ELSE 0
        END
    ) AS successful_sessions,

    SUM(
        CASE
            WHEN cs.session_status = 'Completed' THEN cs.amount
            ELSE 0
        END
    ) AS total_revenue,

    AVG(
        CASE
            WHEN cs.session_status = 'Completed' THEN cs.amount
        END
    ) AS avg_revenue_per_successful_session

FROM charging_sessions cs
JOIN chargers c
    ON cs.charger_id = c.charger_id
JOIN stations s
    ON c.station_id = s.station_id

GROUP BY
    s.station_id,
    s.station_name

ORDER BY total_revenue DESC;


/* ----------------------------------------------------------------
   Q8. Customer Behavior / Segment Analysis
   ---------------------------------------------------------------- */

SELECT
    c.customer_segment,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(cs.session_id) AS total_sessions,

    SUM(
        CASE
            WHEN cs.session_status = 'Completed' THEN 1
            ELSE 0
        END
    ) AS successful_sessions,

    SUM(
        CASE
            WHEN cs.session_status = 'Completed' THEN cs.amount
            ELSE 0
        END
    ) AS total_revenue,

    AVG(
        CASE
            WHEN cs.session_status = 'Completed' THEN cs.amount
        END
    ) AS avg_revenue_per_successful_session

FROM customers c
LEFT JOIN charging_sessions cs
    ON c.customer_id = cs.customer_id

GROUP BY c.customer_segment
ORDER BY total_revenue DESC;


/* ----------------------------------------------------------------
   Q9. Peak Hour Analysis
   ---------------------------------------------------------------- */

SELECT
    HOUR(start_time) AS hour_of_day,
    COUNT(*) AS total_sessions,

    SUM(
        CASE
            WHEN session_status = 'Completed' THEN 1
            ELSE 0
        END
    ) AS successful_sessions,

    SUM(
        CASE
            WHEN session_status = 'Completed' THEN amount
            ELSE 0
        END
    ) AS total_revenue

FROM charging_sessions

GROUP BY HOUR(start_time)
ORDER BY total_sessions DESC;


/* ----------------------------------------------------------------
   Q10. Revenue by Payment Method
   ---------------------------------------------------------------- */

SELECT
    p.payment_method,
    COUNT(*) AS total_payments,

    SUM(
        CASE
            WHEN p.payment_status = 'Success' THEN 1
            ELSE 0
        END
    ) AS successful_payments,

    SUM(
        CASE
            WHEN p.payment_status = 'Success' THEN p.amount_paid
            ELSE 0
        END
    ) AS total_revenue

FROM payments p

GROUP BY p.payment_method
ORDER BY total_revenue DESC;


/* ----------------------------------------------------------------
   Q11. Station Revenue Ranking
   ---------------------------------------------------------------- */

WITH station_revenue AS (
    SELECT
        s.station_id,
        s.station_name,

        SUM(
            CASE
                WHEN cs.session_status = 'Completed' THEN cs.amount
                ELSE 0
            END
        ) AS total_revenue

    FROM charging_sessions cs
    JOIN chargers c
        ON cs.charger_id = c.charger_id
    JOIN stations s
        ON c.station_id = s.station_id

    GROUP BY
        s.station_id,
        s.station_name
)

SELECT
    station_id,
    station_name,
    total_revenue,
    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank
FROM station_revenue
ORDER BY revenue_rank;


/* ----------------------------------------------------------------
   Q12. Monthly Running Revenue
   ---------------------------------------------------------------- */

WITH monthly_revenue AS (
    SELECT
        YEAR(start_time) AS year,
        MONTH(start_time) AS month,

        SUM(
            CASE
                WHEN session_status = 'Completed' THEN amount
                ELSE 0
            END
        ) AS monthly_revenue

    FROM charging_sessions

    GROUP BY
        YEAR(start_time),
        MONTH(start_time)
)

SELECT
    year,
    month,
    monthly_revenue,

    SUM(monthly_revenue) OVER (
        ORDER BY year, month
    ) AS running_revenue

FROM monthly_revenue
ORDER BY
    year,
    month;


/* ----------------------------------------------------------------
   Q13. Three-Month Moving Average of Sessions
   ---------------------------------------------------------------- */

WITH monthly_sessions AS (
    SELECT
        YEAR(start_time) AS year,
        MONTH(start_time) AS month,
        COUNT(*) AS total_sessions

    FROM charging_sessions

    GROUP BY
        YEAR(start_time),
        MONTH(start_time)
)

SELECT
    year,
    month,
    total_sessions,

    AVG(total_sessions) OVER (
        ORDER BY year, month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS three_month_moving_avg

FROM monthly_sessions
ORDER BY
    year,
    month;


/* ----------------------------------------------------------------
   Q14. Customer Activity Quartiles using NTILE
   ---------------------------------------------------------------- */

WITH customer_sessions AS (
    SELECT
        customer_id,
        COUNT(*) AS total_sessions
    FROM charging_sessions
    GROUP BY customer_id
)

SELECT
    customer_id,
    total_sessions,

    NTILE(4) OVER (
        ORDER BY total_sessions DESC
    ) AS activity_quartile

FROM customer_sessions
ORDER BY total_sessions DESC;


/* ----------------------------------------------------------------
   Q15. Customer Session-to-Session Behavior using LAG
   ---------------------------------------------------------------- */

SELECT
    customer_id,
    session_id,
    start_time,
    energy_kwh,
    amount,

    LAG(start_time) OVER (
        PARTITION BY customer_id
        ORDER BY start_time
    ) AS previous_session_time,

    LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY start_time
    ) AS previous_session_amount

FROM charging_sessions
ORDER BY
    customer_id,
    start_time;


/* ----------------------------------------------------------------
   Q16. Station Performance Score
   ---------------------------------------------------------------- */

WITH station_metrics AS (
    SELECT
        s.station_id,
        s.station_name,
        COUNT(cs.session_id) AS total_sessions,

        SUM(
            CASE
                WHEN cs.session_status = 'Completed' THEN 1
                ELSE 0
            END
        ) AS successful_sessions,

        SUM(
            CASE
                WHEN cs.session_status = 'Completed' THEN cs.amount
                ELSE 0
            END
        ) AS total_revenue

    FROM stations s
    JOIN chargers c
        ON s.station_id = c.station_id
    LEFT JOIN charging_sessions cs
        ON c.charger_id = cs.charger_id

    GROUP BY
        s.station_id,
        s.station_name
),

scored AS (
    SELECT
        *,
        successful_sessions * 100.0
        / NULLIF(total_sessions, 0) AS success_rate
    FROM station_metrics
)

SELECT
    station_id,
    station_name,
    total_sessions,
    successful_sessions,
    total_revenue,
    ROUND(success_rate, 2) AS success_rate,

    ROUND(
        (total_sessions / MAX(total_sessions) OVER () * 40)
        +
        (total_revenue / MAX(total_revenue) OVER () * 40)
        +
        (success_rate / 100 * 20),
        2
    ) AS performance_score

FROM scored
ORDER BY performance_score DESC;


/* ----------------------------------------------------------------
   Q17. Expansion Analysis
   ---------------------------------------------------------------- */

WITH station_metrics AS (
    SELECT
        s.station_id,
        s.station_name,
        COUNT(DISTINCT c.charger_id) AS total_chargers,
        COUNT(cs.session_id) AS total_sessions,

        SUM(
            CASE
                WHEN cs.session_status = 'Completed' THEN cs.amount
                ELSE 0
            END
        ) AS total_revenue

    FROM stations s
    JOIN chargers c
        ON s.station_id = c.station_id
    LEFT JOIN charging_sessions cs
        ON c.charger_id = cs.charger_id

    GROUP BY
        s.station_id,
        s.station_name
),

ranked AS (
    SELECT
        *,
        NTILE(4) OVER (
            ORDER BY total_sessions DESC
        ) AS demand_quartile,

        NTILE(4) OVER (
            ORDER BY total_chargers ASC
        ) AS capacity_quartile

    FROM station_metrics
)

SELECT
    station_id,
    station_name,
    total_chargers,
    total_sessions,
    total_revenue,
    demand_quartile,
    capacity_quartile

FROM ranked

WHERE demand_quartile = 1
  AND capacity_quartile = 1

ORDER BY total_sessions DESC;


/* ================================================================
   06. CUSTOMER ACQUISITION & COHORT ANALYSIS
   ================================================================ */


/* ----------------------------------------------------------------
   Q18. Monthly New Customer Acquisition
   ---------------------------------------------------------------- */

SELECT
    YEAR(signup_date) AS signup_year,
    MONTH(signup_date) AS signup_month,
    COUNT(*) AS new_customers

FROM customers

GROUP BY
    YEAR(signup_date),
    MONTH(signup_date)

ORDER BY
    signup_year,
    signup_month;


/* ----------------------------------------------------------------
   Q19. Customer Cohort & First Charging Month
   ---------------------------------------------------------------- */

SELECT
    c.customer_id,
    DATE_FORMAT(c.signup_date, '%Y-%m') AS cohort_month,
    DATE_FORMAT(MIN(cs.start_time), '%Y-%m') AS first_charging_month

FROM customers c
JOIN charging_sessions cs
    ON c.customer_id = cs.customer_id

GROUP BY
    c.customer_id,
    cohort_month;


/* ----------------------------------------------------------------
   Q20. Raw Cohort Retention Activity
   ---------------------------------------------------------------- */

WITH customer_activity AS (
    SELECT
        c.customer_id,
        DATE_FORMAT(c.signup_date, '%Y-%m') AS cohort_month,
        DATE_FORMAT(cs.start_time, '%Y-%m') AS activity_month

    FROM customers c
    JOIN charging_sessions cs
        ON c.customer_id = cs.customer_id

    GROUP BY
        c.customer_id,
        cohort_month,
        activity_month
)

SELECT
    cohort_month,
    activity_month,
    COUNT(DISTINCT customer_id) AS active_customers

FROM customer_activity

GROUP BY
    cohort_month,
    activity_month

ORDER BY
    cohort_month,
    activity_month;


/* ----------------------------------------------------------------
   Q21. Cohort Retention Rate
   ---------------------------------------------------------------- */

WITH customer_activity AS (
    SELECT
        c.customer_id,
        DATE_FORMAT(c.signup_date, '%Y-%m') AS cohort_month,
        DATE_FORMAT(cs.start_time, '%Y-%m') AS activity_month

    FROM customers c
    JOIN charging_sessions cs
        ON c.customer_id = cs.customer_id

    GROUP BY
        c.customer_id,
        cohort_month,
        activity_month
),

cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_customers

    FROM customer_activity

    GROUP BY cohort_month
),

monthly_activity AS (
    SELECT
        cohort_month,
        activity_month,
        COUNT(DISTINCT customer_id) AS active_customers

    FROM customer_activity

    GROUP BY
        cohort_month,
        activity_month
)

SELECT
    ma.cohort_month,
    ma.activity_month,
    ma.active_customers,
    cs.cohort_customers,

    ROUND(
        ma.active_customers * 100.0
        / cs.cohort_customers,
        2
    ) AS retention_rate

FROM monthly_activity ma
JOIN cohort_size cs
    ON ma.cohort_month = cs.cohort_month

ORDER BY
    ma.cohort_month,
    ma.activity_month;


/* ----------------------------------------------------------------
   Q22. Relative Month Retention
   ---------------------------------------------------------------- */

WITH customer_activity AS (
    SELECT
        c.customer_id,
        DATE_FORMAT(c.signup_date, '%Y-%m') AS cohort_month,

        TIMESTAMPDIFF(
            MONTH,
            c.signup_date,
            cs.start_time
        ) AS month_number

    FROM customers c
    JOIN charging_sessions cs
        ON c.customer_id = cs.customer_id

    WHERE cs.start_time >= c.signup_date

    GROUP BY
        c.customer_id,
        cohort_month,
        month_number
),

cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_customers

    FROM customer_activity

    WHERE month_number = 0

    GROUP BY cohort_month
)

SELECT
    ca.cohort_month,
    ca.month_number,
    COUNT(DISTINCT ca.customer_id) AS active_customers,
    cs.cohort_customers,

    ROUND(
        COUNT(DISTINCT ca.customer_id) * 100.0
        / cs.cohort_customers,
        2
    ) AS retention_rate

FROM customer_activity ca
JOIN cohort_size cs
    ON ca.cohort_month = cs.cohort_month

GROUP BY
    ca.cohort_month,
    ca.month_number,
    cs.cohort_customers

ORDER BY
    ca.cohort_month,
    ca.month_number;


/* ================================================================
   07. CUSTOMER SEGMENTATION
   ================================================================ */


/* ----------------------------------------------------------------
   Q23. Behavioral Customer Segmentation
   ---------------------------------------------------------------- */

WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.customer_segment,
        COUNT(cs.session_id) AS total_sessions,

        SUM(
            CASE
                WHEN cs.session_status = 'Completed'
                THEN cs.energy_kwh
                ELSE 0
            END
        ) AS total_energy,

        SUM(
            CASE
                WHEN cs.session_status = 'Completed'
                THEN cs.amount
                ELSE 0
            END
        ) AS total_revenue

    FROM customers c
    LEFT JOIN charging_sessions cs
        ON c.customer_id = cs.customer_id

    GROUP BY
        c.customer_id,
        c.customer_segment
),

segmented AS (
    SELECT
        *,
        CASE
            WHEN total_sessions >= 40
                 AND total_revenue >= 20000
                THEN 'High Value'

            WHEN total_sessions >= 20
                 AND total_revenue >= 10000
                THEN 'Regular'

            WHEN total_sessions >= 5
                THEN 'Occasional'

            ELSE 'Low Activity'
        END AS behavior_segment

    FROM customer_metrics
)

SELECT
    behavior_segment,
    COUNT(*) AS customers,
    ROUND(AVG(total_sessions), 2) AS avg_sessions,
    ROUND(AVG(total_energy), 2) AS avg_energy,
    ROUND(AVG(total_revenue), 2) AS avg_revenue

FROM segmented

GROUP BY behavior_segment
ORDER BY avg_revenue DESC;


/* ================================================================
   08. STATION PERFORMANCE & EXPANSION
   ================================================================ */


/* ----------------------------------------------------------------
   Q24. Station Performance Score
   ---------------------------------------------------------------- */

WITH station_metrics AS (
    SELECT
        s.station_id,
        s.station_name,
        COUNT(cs.session_id) AS total_sessions,

        SUM(
            CASE
                WHEN cs.session_status = 'Completed'
                THEN 1
                ELSE 0
            END
        ) AS successful_sessions,

        SUM(
            CASE
                WHEN cs.session_status = 'Completed'
                THEN cs.amount
                ELSE 0
            END
        ) AS total_revenue

    FROM stations s
    JOIN chargers c
        ON s.station_id = c.station_id
    LEFT JOIN charging_sessions cs
        ON c.charger_id = cs.charger_id

    GROUP BY
        s.station_id,
        s.station_name
),

scored AS (
    SELECT
        *,
        successful_sessions * 100.0
        / NULLIF(total_sessions, 0) AS success_rate

    FROM station_metrics
)

SELECT
    station_id,
    station_name,
    total_sessions,
    successful_sessions,
    ROUND(success_rate, 2) AS success_rate,
    ROUND(total_revenue, 2) AS total_revenue,

    ROUND(
        (total_sessions / MAX(total_sessions) OVER () * 40)
        +
        (total_revenue / MAX(total_revenue) OVER () * 40)
        +
        (success_rate / 100 * 20),
        2
    ) AS performance_score

FROM scored
ORDER BY performance_score DESC;


/* ----------------------------------------------------------------
   Q25. Expansion Analysis - Demand vs Capacity
   ---------------------------------------------------------------- */

WITH station_metrics AS (
    SELECT
        s.station_id,
        s.station_name,
        COUNT(DISTINCT c.charger_id) AS total_chargers,
        COUNT(cs.session_id) AS total_sessions,

        SUM(
            CASE
                WHEN cs.session_status = 'Completed'
                THEN cs.amount
                ELSE 0
            END
        ) AS total_revenue

    FROM stations s
    JOIN chargers c
        ON s.station_id = c.station_id
    LEFT JOIN charging_sessions cs
        ON c.charger_id = cs.charger_id

    GROUP BY
        s.station_id,
        s.station_name
)

SELECT
    station_id,
    station_name,
    total_chargers,
    total_sessions,
    total_revenue,

    NTILE(4) OVER (
        ORDER BY total_sessions DESC
    ) AS demand_quartile,

    NTILE(4) OVER (
        ORDER BY total_chargers ASC
    ) AS capacity_quartile

FROM station_metrics

ORDER BY total_sessions DESC;


/* ================================================================
   END OF EV CHARGING NETWORK ANALYTICS
   ================================================================ */
