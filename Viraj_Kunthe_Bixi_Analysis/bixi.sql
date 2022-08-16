USE bixi;

SELECT 
    is_member
FROM
    trips
ORDER BY start_date ASC;
-- LIMIT 1000;

-- q1.1

SELECT 
    COUNT(*)
FROM
    trips
WHERE
    YEAR(start_date) = 2016;

-- alternatively

SELECT 
    YEAR(start_date) AS START_YEAR, COUNT(*) AS trips
FROM
    trips
GROUP BY YEAR(start_date);


-- q1.3 and 1.4

SELECT 
    MONTH(start_date) AS MONTH, COUNT(*) AS TRIPS
FROM
    trips
WHERE
    YEAR(start_date) = 2016
GROUP BY MONTH(start_date);

SELECT 
    MONTH(start_date) AS month, COUNT(*) AS trips
FROM
    trips
WHERE
    YEAR(start_date) = 2017
GROUP BY MONTH(start_date);

-- 1.5 The average number of trips a day for each year-month combination in the dataset.

DROP TABLE IF EXISTS working_table1;
CREATE TABLE working_table1 SELECT YEAR(start_date) AS yr,
    MONTH(start_date) AS mnth,
    COUNT(DISTINCT (DAY(start_date))) AS number_of_days,
    (COUNT(*) * 1.0 / COUNT(DISTINCT (DAY(start_date)))) AS avg_trips_per_day FROM
    trips
GROUP BY yr , mnth;

SELECT 
    *
FROM
    working_table1;

DROP TABLE working_table1;


-- Q2  

SELECT 
    is_member, COUNT(*)
FROM
    trips
WHERE
    YEAR(start_date) = '2017'
GROUP BY is_member;

-- 2.2


SELECT 
    MONTH(start_date) AS month,
    SUM(is_member) AS member_trips,
    COUNT(*) AS total_trips,
    ((SUM(is_member) * 100.0 / COUNT(*))) AS pct_member
FROM
    TRIPS
WHERE
    YEAR(start_date) = 2017
GROUP BY month;

-- Q3

SELECT 
    MONTH(start_date) AS mnth,
    COUNT(DISTINCT (DAY(start_date))) AS number_of_days,
    (COUNT(*) * 1.0 / COUNT(DISTINCT (DAY(start_date)))) AS avg_trips_per_day
FROM
    trips
GROUP BY mnth
ORDER BY avg_trips_per_day;

-- q4 

SELECT 
    trips.start_station_code, stations.name, COUNT(*) AS trips
FROM
    trips
        LEFT JOIN
    stations ON trips.start_station_code = stations.code
GROUP BY start_station_code
ORDER BY trips DESC
LIMIT 5;

-- 4.2 using a subquery 2.735

SELECT 
    stations.code, stations.name, popular_stations.trips
FROM
    (SELECT 
        start_station_code, COUNT(*) AS trips
    FROM
        trips
    GROUP BY start_station_code
    ORDER BY trips DESC
    LIMIT 5) AS popular_stations
        LEFT JOIN
    stations ON stations.code = popular_stations.start_station_code;



-- Q5

SELECT 
    *
FROM
    trips
        INNER JOIN
    (SELECT 
        code
    FROM
        stations
    WHERE
        name = 'Mackay / de Maisonneuve') AS mackay_code ON trips.start_station_code = mackay_code.code;


-- alternatively  (faster 0.687)

SELECT 
    CASE
        WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN 'morning'
        WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN 'afternoon'
        WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN 'evening'
        ELSE 'night'
    END AS 'time_of_day',
    COUNT(*) as trips
FROM
    trips
WHERE
    start_station_code IN (SELECT 
            code
        FROM
            stations
        WHERE
            name = 'Mackay / de Maisonneuve')
GROUP BY time_of_day;



-- Q6

SELECT 
    start_station_code, COUNT(*) AS trips_per_station
FROM
    trips
GROUP BY start_station_code;

-- 6.2 112 seconds

SELECT 
    start_station_code, COUNT(*) AS round_trips
FROM
    trips
WHERE
    start_station_code = end_station_code
GROUP BY start_station_code;

-- 6.3  round trip percentage 17.781s


SELECT 
    trips.start_station_code,
    stations.name,
    SUM(CASE
        WHEN start_station_code = end_station_code THEN 1
        ELSE 0
    END) AS 'round_trips',
    COUNT(*) AS total_trips,
    (SUM(CASE
        WHEN start_station_code = end_station_code THEN 1
        ELSE 0
    END) * 100.00 / COUNT(*)) AS pct_round_trips
FROM
    trips
        JOIN
    stations ON trips.start_station_code = stations.code
GROUP BY start_station_code;


-- 6.4 round trip % above 10 and trips > 500

SELECT 
    trips.start_station_code,
    stations.name,
    SUM(CASE
        WHEN start_station_code = end_station_code THEN 1
        ELSE 0
    END) AS 'round_trips',
    COUNT(*) AS total_trips,
    (SUM(CASE
        WHEN start_station_code = end_station_code THEN 1
        ELSE 0
    END) * 100.00 / COUNT(*)) AS pct_round_trips
FROM
    trips
        JOIN
    stations ON trips.start_station_code = stations.code
GROUP BY start_station_code
HAVING pct_round_trips >= 10
    AND total_trips >= 500;





