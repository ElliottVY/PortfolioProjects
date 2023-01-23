-- Analyize starting grid position to final position differential over the all races for each driver. A metric to be explored over a few differes axes in Tableau.
-- SQL queries are for the 'Formula 1 World Championship (1950 - 2022)' dataset on Kaggle. https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020
-- I use Azure Data Studio.

-- Joining the relevant tables.

SELECT
	F1..results$.driverId,
    F1..results$.grid,
    F1..results$.position,
    F1..drivers$.forename,
    F1..drivers$.surname,
    F1..results$.grid-F1..results$.position as grid_improvment
FROM
	F1..results$
INNER JOIN 
	F1..drivers$
	ON F1..drivers$.driverId=F1..results$.driverId
ORDER BY
	F1..results$.grid

-- Aggregate the data. I am not certain if the aggregate function MAX is is the correct way to return the driver's names in this table, but it works.

SELECT
	F1..results$.driverId,
    ROUND(AVG(F1..results$.grid),2) AS grid_position,
    ROUND(AVG(F1..results$.position),2) AS Finish,
    ROUND(AVG(F1..results$.grid-F1..results$.position),2)AS grid_improvement,
    COUNT(F1..results$.raceId) as Total_Races,
    MAX(F1..drivers$.forename),
    MAX(F1..drivers$.surname)
FROM 
	F1..results$
INNER JOIN
	F1..drivers$
	ON F1..drivers$.driverId=F1..results$.driverId
GROUP BY
	F1..results$.driverId
ORDER BY
	MAX(F1..drivers$.surname)

--Limit the list to only the top 100 drivers in terms of races completed

SELECT TOP 100
	F1..results$.driverId,
    ROUND(AVG(F1..results$.grid),2) AS grid_position,
    ROUND(AVG(F1..results$.position),2) AS Finish,
    ROUND(AVG(F1..results$.grid-F1..results$.position),2)AS grid_improvement,
    COUNT(F1..results$.raceId) as Total_Races,
    MAX(F1..drivers$.forename),
    MAX(F1..drivers$.surname)
FROM 
	F1..results$
INNER JOIN
	F1..drivers$
	ON F1..drivers$.driverId=F1..results$.driverId
GROUP BY
	F1..results$.driverId
ORDER BY 
	COUNT(F1..results$.raceId) DESC

--Remove every row with a NULL in any column, which would indicate a DNF, DNS, DNQ, or DSQ. Add a few more relevant columns to draw from.

SELECT
	CONCAT(MAX(F1..drivers$.forename), ' ', MAX(F1..drivers$.surname)) AS Name,
	ROUND(AVG(F1..results$.grid),2) AS Grid, ROUND(AVG(F1..results$.position),2) AS Finish, 
	ROUND(AVG(F1..results$.grid-F1..results$.position),2) AS Improvement,
	COUNT(F1..results$.raceId) as Total_Finished_Races, 
	MAX(F1..drivers$.nationality) as Nationality,
	MIN(F1..drivers$.dob) as DOB
FROM 
	F1..results$
INNER JOIN
	F1..drivers$
	ON F1..drivers$.driverId=F1..results$.driverId
WHERE
	F1..results$.grid is not null
	AND F1..results$.position is not null
GROUP BY
	F1..results$.driverId
ORDER BY 
	COUNT(F1..results$.raceId) DESC

-- Remove any driver with less than 20 races to reduce noise.

SELECT
	CONCAT(MAX(F1..drivers$.forename), ' ', MAX(F1..drivers$.surname)) AS Name,
	ROUND(AVG(F1..results$.grid),2) AS Grid, ROUND(AVG(F1..results$.position),2) AS Finish, 
	ROUND(AVG(F1..results$.grid-F1..results$.position),2) AS Improvement,
	COUNT(F1..results$.raceId) as Total_Finished_Races, 
	MAX(F1..drivers$.nationality) as Nationality,
	MIN(F1..drivers$.dob) as DOB
FROM 
	F1..results$
INNER JOIN
	F1..drivers$
	ON F1..drivers$.driverId=F1..results$.driverId
WHERE
	F1..results$.position is not null
	AND F1..results$.grid > 0
GROUP BY
	F1..results$.driverId
HAVING
	COUNT(F1..results$.raceId) > 19
	
ORDER BY 
	COUNT(F1..results$.raceId) DESC

-- Determine rookie year for each driver to give an idea of what era the driver was racing in. This query will provide the table for the graph comparing drivers. 
-- Will be exported as drivers.xls

SELECT
	CONCAT(MAX(F1..drivers$.forename), ' ', MAX(F1..drivers$.surname)) AS Name,
	ROUND(AVG(F1..results$.grid),2) AS Grid, ROUND(AVG(F1..results$.position),2) AS Finish, 
	ROUND(AVG(F1..results$.grid-F1..results$.position),2) AS Improvement,
	COUNT(F1..results$.raceId) as Total_Finished_Races, 
	MAX(F1..drivers$.nationality) as Nationality,
	MIN(F1..races$.year) as Rookie_Year,
	MIN(F1..drivers$.dob) as DOB,
	MAX(F1..drivers$.url) as URL
FROM 
	F1..results$
INNER JOIN
	F1..drivers$
	ON F1..drivers$.driverId=F1..results$.driverId
INNER JOIN
	F1..races$
	ON F1..results$.raceId=F1..races$.raceId
WHERE
	F1..results$.position is not null
	AND F1..results$.grid > 0
--	AND F1..races$.circuitId != '19'
GROUP BY
	F1..results$.driverId
--HAVING
--	COUNT(F1..results$.raceId)>19
ORDER BY 
	COUNT(F1..results$.raceId) DESC

--I want to visualize the metric over the history of F1 with lines for every driver using a per season average. So this query has different groupings and a few more
--columns for Tableau.
--Perhaps an area graph of various nation's contribution to overall differential will reveal interesting patterns. Also to look into trends in the motorsport as 
--whole, over time. Leave all drivers in and leave the filtering to Tableau.
--Will be exported as seasons.xls

SELECT
	CONCAT(MAX(F1..drivers$.forename), ' ', MAX(F1..drivers$.surname)) AS Name,
	ROUND(AVG(F1..results$.grid),2) AS Grid, ROUND(AVG(F1..results$.position),2) AS Finish, 
	ROUND(AVG(F1..results$.grid-F1..results$.position),2) AS Improvement,
	COUNT(F1..results$.raceId) as Season_Finished_Races, 
	MAX(F1..drivers$.nationality) as Nationality,
	YEAR(MIN(F1..drivers$.dob)) as YOB,
	MAX(F1..drivers$.url) as URL,
	races$.year
FROM 
	F1..results$
INNER JOIN
	F1..drivers$
	ON F1..drivers$.driverId=F1..results$.driverId
INNER JOIN
	F1..races$
	ON F1..results$.raceId=F1..races$.raceId
WHERE
	 F1..results$.position is not null
	AND F1..results$.grid > 0
--	AND F1..results$.grid is not null
GROUP BY
	F1..races$.year,
	F1..drivers$.driverId
ORDER BY 
	races$.year

--Aside from finding interesting data stories about some strange seasons and some interesting drivers, this is mostly, in the end, a complicated way of
--looking at the history of DNFs, DSQs, and DNSs in F1.
--There is certainly a way to normalize the defferential to eliminate or reduce the effect of nulls, so, let's do that.

--First a query of DNFs over time. These resuslts still eliminate drivers that did not start the race.

SELECT
	COUNT(f1..drivers$.driverId) as DNF,
	races$.year AS Season
FROM 
	F1..results$
INNER JOIN
	F1..drivers$
	ON F1..drivers$.driverId=F1..results$.driverId
INNER JOIN
	F1..races$
	ON F1..results$.raceId=F1..races$.raceId
WHERE
	F1..results$.position is null
	AND F1..results$.grid > 0
GROUP BY
	F1..races$.year
ORDER BY 
	races$.year

-- Now we will normalize. First we have to figure out what the max for each field is, which is different for each race. Then incorporate thiese new numbers
--into the orignial query.

WITH normalized_results AS (
    SELECT 
        driverId, raceId, 
        grid / MAX(grid) OVER () AS normalized_grid,
        position / MAX(position) OVER () AS normalized_position
    FROM 
		F1..results$
    WHERE 
		position IS NOT NULL 
		AND grid > 0
)
SELECT
    CONCAT(MAX(F1..drivers$.forename), ' ', MAX(F1..drivers$.surname)) AS Name,
    ROUND(AVG(normalized_grid),2) AS Normalized_Grid, 
    ROUND(AVG(normalized_position),2) AS Normalized_Finish, 
    ROUND(AVG(normalized_grid - normalized_position),2) AS Normalized_Improvement,
    COUNT(normalized_results.raceId) as Season_Finished_Races, 
    MAX(F1..drivers$.nationality) as Nationality,
    YEAR(MIN(F1..drivers$.dob)) as YOB,
    MAX(F1..drivers$.url) as URL,
    races$.year
FROM 
    normalized_results
INNER JOIN
    F1..drivers$
    ON F1..drivers$.driverId = normalized_results.driverId
INNER JOIN
    F1..races$
    ON normalized_results.raceId = F1..races$.raceId
GROUP BY
    F1..races$.year,
    F1..drivers$.driverId
ORDER BY 
    races$.year

-- That looked like it worked, but I failed to seperate out the races in the window. A properly partitioned query:

WITH normalized_results AS (
    SELECT 
        driverId, raceId, 
        grid / MAX(grid) OVER (PARTITION BY raceId) AS normalized_grid,
        position / MAX(position) OVER (PARTITION BY raceId) AS normalized_position
    FROM F1..results$
    WHERE position IS NOT NULL AND grid > 0
)
SELECT
    CONCAT(MAX(F1..drivers$.forename), ' ', MAX(F1..drivers$.surname)) AS Name,
    ROUND(AVG(normalized_grid),2) AS Normalized_Grid, 
    ROUND(AVG(normalized_position),2) AS Normalized_Finish, 
    ROUND(AVG(normalized_grid - normalized_position),2) AS Normalized_Differential,
    COUNT(normalized_results.raceId) as Season_Finished_Races, 
    MAX(F1..drivers$.nationality) as Nationality,
    YEAR(MIN(F1..drivers$.dob)) as YOB,
    MAX(F1..drivers$.url) as URL,
    races$.year
FROM 
    normalized_results
INNER JOIN
    F1..drivers$
    ON F1..drivers$.driverId = normalized_results.driverId
INNER JOIN
    F1..races$
    ON normalized_results.raceId = F1..races$.raceId
GROUP BY
    F1..races$.year,
    F1..drivers$.driverId
ORDER BY 
    races$.year

	
--I wrote a query to find the MIN and MAX Normalized Differential from each race, and used that for a season min average and max average for another graph.
--This just produced noise, what I want is average deviation from 0. Min_max is all chaos, crashes, and epic charges.
--The math is simple since I am only looking for deviation from 0. I simply need to make the negative numbers positive with the ABS function and make an
--average for each race, then for each season. This will give me a per season metric that I hope will be illuminating.

WITH normalized_results AS (
    SELECT 
        driverId, raceId, 
        grid / MAX(grid) OVER (PARTITION BY raceId) AS normalized_grid,
        position / MAX(position) OVER (PARTITION BY raceId) AS normalized_position
    FROM F1..results$
    WHERE position IS NOT NULL AND grid > 0
),
super_normal AS (
SELECT
    CONCAT(F1..drivers$.forename, ' ', F1..drivers$.surname) AS Name,
    ROUND(normalized_grid - normalized_position,3) AS norm,
	races$.raceId as raceId,
	races$.year
FROM 
    normalized_results
INNER JOIN
    F1..drivers$
    ON F1..drivers$.driverId = normalized_results.driverId
INNER JOIN
    F1..races$
    ON normalized_results.raceId = F1..races$.raceId
),
min_max AS (
SELECT
	AVG(ABS(norm)) AS absoulte_norm,
	raceId,
	max(year) AS YEAR
FROM
	super_normal
GROUP BY
	raceId
)
SELECT
	ROUND(AVG(absoulte_norm),3) AS norm_dev,
	MAX(f1..seasons$.URL) AS URL,
	min_max.YEAR
FROM
	min_max
INNER JOIN
	F1..seasons$
	ON F1..seasons$.year = min_max.YEAR
GROUP BY
	min_max.YEAR
ORDER BY
	min_max.YEAR

--Now to redo the driver ranking from earlier, but with normalized data.

WITH normalized_results AS (
    SELECT 
        driverId, raceId, 
        grid / MAX(grid) OVER (PARTITION BY raceId) AS normalized_grid,
        position / MAX(position) OVER (PARTITION BY raceId) AS normalized_position
    FROM F1..results$
    WHERE position IS NOT NULL AND grid > 0
)
SELECT
    CONCAT(MAX(F1..drivers$.forename), ' ', MAX(F1..drivers$.surname)) AS Name,
    ROUND(AVG(normalized_grid - normalized_position),4) AS Normalized_Differential,
    COUNT(normalized_results.raceId) as Total_Finished_Races, 
    MIN(F1..races$.year) as Rookie_Year,
    MAX(F1..drivers$.url) as URL
FROM 
    normalized_results
INNER JOIN
    F1..drivers$
    ON F1..drivers$.driverId = normalized_results.driverId
INNER JOIN
    F1..races$
    ON normalized_results.raceId = F1..races$.raceId
GROUP BY
    F1..drivers$.driverId
HAVING
    COUNT(normalized_results.raceId) > 19





--What follows are some dead ends and unfruitfull explorations.

--look at every start from pole.

SELECT
	CONCAT(drivers$.forename, ' ', drivers$.surname),
	results$.position,
	races$.name,
	races$.year
FROM 
	F1..results$
INNER JOIN
	F1..drivers$
	ON F1..drivers$.driverId=F1..results$.driverId
INNER JOIN
	F1..races$
	ON F1..results$.raceId=F1..races$.raceId
WHERE
	F1..results$.grid = 1
ORDER BY
    races$.[date]

--How did the first two rows do over time, meaning the drivers starting the race from pole position 1,2,3, or 4?

SELECT
	ROUND(AVG(results$.[position]),2) AS Average,
	races$.year
FROM 
	F1..results$
INNER JOIN
	F1..drivers$
	ON F1..drivers$.driverId=F1..results$.driverId
INNER JOIN
	F1..races$
	ON F1..results$.raceId=F1..races$.raceId
WHERE
	F1..results$.[grid] BETWEEN 1 and 4
GROUP BY
	races$.[year]
ORDER BY
	races$.[year]


--Exploring pit starts, which the data has as a F1..results$.grid entry of 0. Rather than just deleting a pit start I would like to have it be a
--last place + 1 start to better flesh out our data.
--There have been 1,609 individual pit starts and 393 races with pit starts in championship racing, it would be a fun later project to explore
--those more, lost of great stories in there.
--Actually, no. The data does not differentiate between a pit start and no start at all. Further digging into the data reveals only 37 races that have
--completed with a start in the pits. No doubt a few interesting stories,
--but this won't have a huge impact on the visualizations. It does however remain important to cull the pit starts since it is entered as position 0,
--which puts it above the top of the pole as far as our differantial math is considered.

SELECT
raceId, driverId, grid, position
FROM 
F1..results$
WHERE
grid = 0
AND position >= 1

--Out of curiosity, what drivers have gotten a top-ten finish from pit lane?

SELECT
forename, surname, grid, position
FROM 
F1..results$
INNER JOIN
	F1..drivers$
	ON F1..drivers$.driverId=F1..results$.driverId
WHERE
grid = 0
AND position between 1 AND 10
Order BY
	raceId

-- Figuring out why the data contained two Mika Hakkinens, there weren't, there were simply two Mikas, I just didn't Finnish.

SELECT
	forename, surname
FROM
	F1..drivers$
Where 
	forename = 'Mika'




