# World Life Expectancy Project (Data Cleaning Phase)

#Identifying and removing Duplicates
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1
;

SELECT *
FROM (
	SELECT Row_ID, CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy
	) AS Row_Table
WHERE Row_Num > 1
;

DELETE FROM world_life_expectancy
WHERE Row_ID IN (
	SELECT Row_ID
	FROM (
	SELECT Row_ID, CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy
	) AS Row_Table
	WHERE Row_Num > 1)
;

#Identifying missing values in Status column and populating them
SELECT *
FROM world_life_expectancy
WHERE status = ''
;

SELECT DISTINCT status
FROM world_life_expectancy
WHERE status <> ''
;

SELECT DISTINCT Country
FROM world_life_expectancy
WHERE status = 'Developing'
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.status = 'Developing'
WHERE t1.status = ''
AND t2.status <> ''
AND t2.status = 'Developing'
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.status = 'Developed'
WHERE t1.status = ''
AND t2.status <> ''
AND t2.status = 'Developed'
;

#Identifying missing values in Life Expectancy and populating them
SELECT *
FROM world_life_expectancy
WHERE `life expectancy` = ''
;

SELECT Country, Year, `life expectancy`
FROM world_life_expectancy
;

SELECT t1.Country, t1.Year, t1.`Life expectancy`,
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2,1) AS 'Average Life Expectancy'
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country AND t1.year = t2.year - 1
JOIN world_life_expectancy t3
	ON t1.country = t3.country AND t1.year = t3.year + 1
WHERE t1.`Life expectancy` = ''
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country AND t1.year = t2.year - 1
JOIN world_life_expectancy t3
	ON t1.country = t3.country AND t1.year = t3.year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2,1)
WHERE t1.`Life expectancy` = ''
;


# World Life Expectancy Project (EDA Phase)

#Looking at the minimum and maximum life expectancy of each country, along witht the life increase ove 15 years
SELECT Country, 
MIN(`Life expectancy`) AS 'Min Life expectancy', 
MAX(`Life expectancy`) AS 'Max Life expectancy',
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS 'Life Increase Over 15 Years'
FROM world_life_expectancy
GROUP BY Country
HAVING  MIN(`Life expectancy`) <> 0 AND MAX(`Life expectancy`) <> 0
ORDER BY ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) DESC
;

#Looking at average life expectancy around the world by year
SELECT Year, ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0 
GROUP BY Year
ORDER BY Year
;

#Looking at the correlation between average life expectancy and average GDP for each country
SELECT Country, ROUND(AVG(`Life expectancy`),1) AS 'Average Life Expectancy', ROUND(AVG(GDP),1) AS 'Average GDP'
FROM world_life_expectancy
GROUP BY Country
HAVING ROUND(AVG(`Life expectancy`),1) <> 0 AND ROUND(AVG(GDP),1) <> 0
ORDER BY ROUND(AVG(GDP),1) DESC
;

#Correlation continued...
SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS 'High GDP Count',
ROUND(AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END),2) AS 'High GDP Life Expectancy',
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) AS 'Low GDP Count',
ROUND(AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END),2) AS 'Low GDP Life Expectancy'
FROM world_life_expectancy
;

#Looking at number of countries and their average life expectancy grouped by the status
SELECT Status, COUNT(DISTINCT Country) AS 'Number of Countries', ROUND(AVG(`Life expectancy`),1) AS 'Average Life expectancy'
FROM world_life_expectancy
GROUP BY Status
;

#Looking at the correlation between average life expectancy and average BMI for each country
SELECT Country, ROUND(AVG(`Life expectancy`),1) AS 'Average Life expectancy', ROUND(AVG(BMI),1) AS 'Average BMI'
FROM world_life_expectancy
GROUP BY Country
HAVING ROUND(AVG(`Life expectancy`),1) <> 0 AND ROUND(AVG(BMI),1) <> 0
ORDER BY ROUND(AVG(BMI),1) ASC
;

#Looking at the adult mortality rolling total for each country
SELECT Country, Year, `Life expectancy`, `Adult Mortality`, 
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS 'Rolling Total'
FROM world_life_expectancy
;

#Ranking countires based on their average BMI across the 16 years
SELECT *
FROM (
SELECT Country, ROUND(AVG(BMI),1), DENSE_RANK() OVER(ORDER BY ROUND(AVG(BMI),1)) AS rank_bmi
FROM world_life_expectancy
GROUP BY country
) AS rank_table
ORDER BY rank_bmi DESC
;

#Displaying the total sum of measles for each country across 16 years, ranking them, and categorizing them
SELECT Country, SUM(Measles) AS 'Sum of Measles', DENSE_RANK() OVER(ORDER BY SUM(Measles)) AS 'Measles Rank',
CASE
	WHEN SUM(Measles) >= 700000 THEN 'Very High'
    WHEN SUM(Measles) BETWEEN 100000 AND 300000 THEN 'High'
    WHEN SUM(Measles) BETWEEN 10000 AND 100000 THEN 'Low'
    ELSE 'Very Low'
END AS 'Category'
FROM world_life_expectancy
GROUP BY Country
ORDER BY SUM(Measles) DESC;

#Looking at the average percentage expenditure for each country and ranking them based on how much they spend
SELECT Country, ROUND(AVG(`percentage expenditure`),2) AS 'Average Percentage Expenditure',
DENSE_RANK() OVER(ORDER BY ROUND(AVG(`percentage expenditure`),2) DESC) AS 'Percentage Expenditure Rank'
FROM world_life_expectancy
GROUP BY Country
;

