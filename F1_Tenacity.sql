-- Analyize starting grid position to final position differential over the all races for each driver. A 'tenacity' metric to be explored over a few differes axes in Tableau.
-- SQL Server queries are for the 'Formula 1 World Championship (1950 - 2022)' dataset on Kaggle. https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020


-- Joining the relevant tables.

SELECT
	F1..results$.driverId, F1..results$.grid, F1..results$.position, F1..drivers$.forename, F1..drivers$.surname, F1..results$.grid-F1..results$.position as grid_improvment
FROM
	F1..results$
INNER JOIN 
	F1..drivers$
	ON F1..drivers$.driverId=F1..results$.driverId
ORDER BY
	F1..results$.grid

-- Aggregate the data. I am not certain if the aggregate function MAX is is the correct way to return the driver's names in this table, but it works.

SELECT
	F1..results$.driverId, ROUND(AVG(F1..results$.grid),2) AS grid_position, ROUND(AVG(F1..results$.position),2) AS Finish, ROUND(AVG(F1..results$.grid-F1..results$.position),2)AS grid_improvement, COUNT(F1..results$.raceId) as Total_Races, MAX(F1..drivers$.forename), MAX(F1..drivers$.surname)
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
	F1..results$.driverId, ROUND(AVG(F1..results$.grid),2) AS grid_position, ROUND(AVG(F1..results$.position),2) AS Finish, ROUND(AVG(F1..results$.grid-F1..results$.position),2)AS grid_improvement, COUNT(F1..results$.raceId) as Total_Races, MAX(F1..drivers$.forename), MAX(F1..drivers$.surname)
FROM 
	F1..results$
INNER JOIN
	F1..drivers$
	ON F1..drivers$.driverId=F1..results$.driverId
GROUP BY
	F1..results$.driverId
ORDER BY 
	COUNT(F1..results$.raceId) DESC

--Remove every row with a NULL in any column, which would indicate a DNF, DNS, DNQ, or DSQ. Add a few more columns to play with.

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
--Will be exported as drivers.xls

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

--I want to visualize the tenacity metric over the history of F1 with lines for every driver using a per season average. So this query has different groupings and a few more columns for Tableau.
--Perhaps an area graph of various nation's contribution to overall tenacity will reveal interesting patterns. Also to look into trends in the motorsport as whole, over time. Leave all drivers in
--and leave the filtering out to Tableau.
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
GROUP BY
	F1..races$.year,
	F1..drivers$.driverId
ORDER BY 
	races$.year

--Aside from finding interesting data stories about some strange seasons and some interesting drivers, this is mostly, in the end, a complicated way of looking at the history of DNFs, DSQs, and DNSs in F1.
--There is certainly a way to normalize the tenacity metric to eliminate or reduce the effect of nulls, but that math is beyond me at the moment.


SELECT
	COUNT(f1..drivers$.driverId),
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
	F1..results$.position is null
	AND F1..results$.grid > 0
GROUP BY
	F1..races$.year
ORDER BY 
	races$.year

--Let's look at every start from pole.

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

How did the first two rows do over time?

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

SELECT
	CONCAT(drivers$.forename, ' ', drivers$.surname),
	results$.grid,
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
	F1..results$.[grid] BETWEEN 1 and 3
	AND races$.year = 1992
ORDER BY
    races$.[date]


--Exploring pit starts, which the data has as a F1..results$.grid entry of 0. Rather than just deleting a pit start I would like to have it be a last place + 1 start to better flesh out our data.
--There have been 1,609 individual pit starts and 393 races with pit starts in championship racing, it would be a fun later project to explore those more, lost of great stories in there.
--Actually, no. The data does not differentiate between a pit start and no start at all. Further digging into the data reveals only 37 races that have completed with a start in the pits. No doubt a few interesting stories,
--but this won't have a huge impact on the visualizations. It does however remain important to cull the pit starts since it is entered as position 0, which puts it above the top of the pole as far as our tenacity math is considered.


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




