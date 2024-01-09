#US Household Income Project (Date Cleaning Phase)

ALTER TABLE income_stats RENAME COLUMN `ï»¿id` TO `id`;
ALTER TABLE income_stats RENAME COLUMN State_Name TO State;
ALTER TABLE household_income RENAME COLUMN State_Name TO State;

#Identifying and removing duplicates
SELECT id, COUNT(id)
FROM household_income
GROUP BY id
HAVING COUNT(id) > 1;

SELECT *
FROM (
SELECT row_id, id,
ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_column
FROM household_income) AS row_table
WHERE row_column > 1;

DELETE FROM household_income
WHERE row_id IN (
	SELECT row_id
	FROM (
	SELECT row_id, id,
	ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_column
	FROM household_income) AS row_table
	WHERE row_column > 1);

SELECT id, COUNT(id)
FROM income_stats
GROUP BY id
HAVING COUNT(id) > 1;

#Standarizing State column
SELECT DISTINCT(State_Name), COUNT(State_Name)
FROM household_income
GROUP BY State_Name
ORDER BY 1;

UPDATE household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia';

UPDATE household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama';

SELECT DISTINCT State_ab
FROM household_income
ORDER BY 1;

#Filling in missing value for Place column
SELECT *
FROM household_income
WHERE Place = '';

UPDATE household_income
SET Place = 'Autaugaville'
WHERE County = 'Autauga County' AND City = 'Vinemont';

#Fixing spelling mistake in Type column
SELECT Type, COUNT(Type)
FROM household_income
GROUP BY Type;

UPDATE household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs';

#Checking Land and Water columns
SELECT AWater
FROM household_income
WHERE AWater IN (NULL, 0, '');

SELECT ALand
FROM household_income
WHERE ALand IN (NULL, 0, '');


#US Household Income Project (EDA Phase)

#Looking at top 10 states with regards to the land size
SELECT State, SUM(ALand) AS 'Sum of Land', SUM(AWater) As 'Sum of Water'
FROM household_income
GROUP BY State
ORDER BY 2 DESC
LIMIT 10;

#Looking at top 10 states with regards to the water size
SELECT State, SUM(ALand) AS 'Sum of Land', SUM(AWater) As 'Sum of Water'
FROM household_income
GROUP BY State
ORDER BY 3 DESC
LIMIT 10;

#Looking at any null values from the left table
SELECT *
FROM household_income h
RIGHT JOIN income_stats i
	ON h.id = i.id
WHERE h.id IS NULL;

#Looking at the average mean and median of each state
SELECT h.State, ROUND(AVG(Mean),0) AS 'Average Mean', ROUND(AVG(Median),0) AS 'Average Median'
FROM household_income h
INNER JOIN income_stats i
	ON h.id = i.id
WHERE Mean <> 0
GROUP BY h.State
ORDER BY 3 DESC
LIMIT 10
;

#Looking at the average mean and median of each Type of city
SELECT Type, COUNT(Type), ROUND(AVG(Mean),0) AS 'Average Mean', ROUND(AVG(Median),0) AS 'Average Median'
FROM household_income h
INNER JOIN income_stats i
	ON h.id = i.id
WHERE Mean <> 0
GROUP BY Type
HAVING COUNT(Type) > 100
ORDER BY 4 DESC
;

#Exploring which states have communities as their Type
SELECT *
FROM household_income
WHERE Type = 'Community'
;

#Looking at the average mean and average median of each city and its state
SELECT h.State, City, ROUND(AVG(Mean),0) AS 'Average Mean', ROUND(AVG(Median),0) AS 'Average Median'
FROM household_income h
INNER JOIN income_stats i
	ON h.id = i.id
GROUP BY h.State, City
ORDER BY 3 DESC
;