-- Analyize starting grid position to final position differential over the all races for each driver. A 'tenacity' metric explored to be over a few differes axes in Tableau.

-- Finding the data.

SELECT
F1..results$.driverId, F1..results$.grid, F1..results$.position, F1..drivers$.forename, F1..drivers$.surname, F1..results$.grid-F1..results$.position as grid_improvment
FROM
	F1..results$
INNER JOIN 
	F1..drivers$
	ON F1..drivers$.driverId=F1..results$.driverId
ORDER BY
	F1..results$.driverId


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
	F1..results$.grid is not null
	AND F1..results$.position is not null
GROUP BY
	F1..results$.driverId
HAVING
	COUNT(F1..results$.raceId) > 19
ORDER BY 
	COUNT(F1..results$.raceId) DESC

-- Determine Year of First Race to give an idea of what era the driver was racing in. 

SELECT
	CONCAT(MAX(F1..drivers$.forename), ' ', MAX(F1..drivers$.surname)) AS Name,
	ROUND(AVG(F1..results$.grid),2) AS Grid, ROUND(AVG(F1..results$.position),2) AS Finish, 
	ROUND(AVG(F1..results$.grid-F1..results$.position),2) AS Improvement,
	COUNT(F1..results$.raceId) as Total_Finished_Races, 
	MAX(F1..drivers$.nationality) as Nationality,
	MIN(F1..races$.year) as Rookie_Year,
	MIN(F1..drivers$.dob) as DOB
FROM 
	F1..results$
INNER JOIN
	F1..drivers$
	ON F1..drivers$.driverId=F1..results$.driverId
INNER JOIN
	F1..races$
	ON F1..results$.raceId=F1..races$.raceId
WHERE
	F1..results$.grid is not null
	AND F1..results$.position is not null
GROUP BY
	F1..results$.driverId
--HAVING
--	COUNT(F1..results$.raceId)>19
ORDER BY 
	COUNT(F1..results$.raceId) DESC

--I want to visualize the tenacity metric over the history of F1 with lines for every driver using a per season average.
--Perhaps an area graph of various nation's contribution to overall tenacity will reveal interesting patterns. Also to look into trends in the motorsport as whole, over time.

SELECT
	CONCAT(MAX(F1..drivers$.forename), ' ', MAX(F1..drivers$.surname)) AS Name,
	ROUND(AVG(F1..results$.grid),2) AS Grid, ROUND(AVG(F1..results$.position),2) AS Finish, 
	ROUND(AVG(F1..results$.grid-F1..results$.position),2) AS Improvement,
	COUNT(F1..results$.raceId) as Total_Finished_Races, 
	MAX(F1..drivers$.nationality) as Nationality,
	MIN(F1..drivers$.dob) as DOB,
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
	F1..results$.grid is not null
	AND F1..results$.position is not null
GROUP BY
	F1..races$.year,
	F1..drivers$.driverId
HAVING
	COUNT(F1..results$.raceId)>2
	AND races$.year<
ORDER BY 
	races$.year


-- Figuring out why the data contained two Mika Hakkinens, there weren't, there were simply two Mikas, I just didn't Finnish.

SELECT
	*
FROM
	F1..drivers$
Where 
	forename = 'Mika'


