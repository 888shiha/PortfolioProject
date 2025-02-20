/* This Crime Dataset contains 630,010 rows of crime data, specifically about Murder and Manslaughter only, with the following 21 fields:
   1. Record ID: A unique identifier for each crime record.
   2. Agency Code: A unique code assigned to law enforcement agencies.
   3. Agency Name: The name of the law enforcement agency that reported the crime.
   4. Agency Type: The type of law enforcement agency (e.g., Municipal Police, Sheriff, etc.).
   5. City: The city where the crime occurred.
   6. State: The state where the crime occurred.
   7. Year: The year when the crime was recorded.
   8. Month: The month when the crime was recorded.
   9. Incident: The number of incidents recorded in a specific crime case.
   10. Crime Type: The type of crime committed (e.g., Murder or Manslaughter).
   11. Crime Solved: Indicates whether the crime was solved (Yes or No).
   12. Victim Sex: The sex of the victim (Male, Female, or Unknown).
   13. Victim Age: The age of the victim (can be Unknown if not recorded).
   14. Victim Race: The racial category of the victim.
   15. Victim Ethnicity: The ethnic background of the victim (Hispanic, Non-Hispanic, Unknown).
   16. Perpetrator Sex: The sex of the perpetrator (Male, Female, or Unknown).
   17. Perpetrator Age: The age of the perpetrator (can be Unknown if not recorded).
   18. Perpetrator Race: The racial category of the perpetrator.
   19. Perpetrator Ethnicity: The ethnic background of the perpetrator (Hispanic, Non-Hispanic, Unknown).
   20. Relationship: The relationship between the victim and the perpetrator (e.g., Acquaintance, Family, Stranger, etc.).
   21. Weapon: The type of weapon used in the crime (Gun, Knife, Blunt Object, etc.).
The first step was data cleaning which involved changing column names, changing data types, checking for duplicates

*/

#STEP 1: CHANGING COLUMN NAMES
#Changing column names to Snake_Case to remove spaces between words.
ALTER TABLE us_crime_dataset 
RENAME COLUMN `Record ID` TO Record_ID;

ALTER TABLE us_crime_dataset 
RENAME COLUMN `Agency Code` TO Agency_Code;

ALTER TABLE us_crime_dataset 
RENAME COLUMN `Agency Name` TO Agency_Name;

ALTER TABLE us_crime_dataset 
RENAME COLUMN `Agency Type` TO Agency_Type;

ALTER TABLE us_crime_dataset 
RENAME COLUMN `Crime Type` TO Crime_Type;

ALTER TABLE us_crime_dataset 
RENAME COLUMN `Crime Solved` TO Crime_Solved;

ALTER TABLE us_crime_dataset 
RENAME COLUMN `Victim Sex` TO Victim_Sex;

ALTER TABLE us_crime_dataset 
RENAME COLUMN `Victim Age` TO Victim_Age;

ALTER TABLE us_crime_dataset 
RENAME COLUMN `Victim Race` TO Victim_Race;

ALTER TABLE us_crime_dataset 
RENAME COLUMN `Victim Ethnicity` TO Victim_Ethnicity;

ALTER TABLE us_crime_dataset 
RENAME COLUMN `Perpetrator Sex` TO Perpetrator_Sex;

ALTER TABLE us_crime_dataset 
RENAME COLUMN `Perpetrator Age` TO Perpetrator_Age;

ALTER TABLE us_crime_dataset 
RENAME COLUMN `Perpetrator Race` TO Perpetrator_Race;

ALTER TABLE us_crime_dataset 
RENAME COLUMN `Perpetrator Ethnicity` TO Perpetrator_Ethnicity;

#STEP 2: CHANGING DATA TYPES

#Altering the Record_ID to make it a Primary Key
ALTER TABLE us_crime_dataset 
ADD PRIMARY KEY (Record_ID);

#Changing Agency_Code data type to CHAR(7) for more efficent storage and performance benefits
ALTER TABLE us_crime_dataset
MODIFY COLUMN Agency_Code CHAR(7);

#Changing Agency_Name data type to VARCHAR(255) to allow for longer agency names while optimizing storage
ALTER TABLE us_crime_dataset
MODIFY COLUMN Agency_Name VARCHAR(255);

#Changing Agency_Type data type to VARCHAR(50) to optimize storage while accommodating different agency types
ALTER TABLE us_crime_dataset
MODIFY COLUMN Agency_Type VARCHAR(50);

#Changing City data type to VARCHAR(255) to support long city names while maintaining flexibility
ALTER TABLE us_crime_dataset
MODIFY COLUMN City VARCHAR(255);

#Changing State data type to VARCHAR(50) to optimize storage for the different state name lengths
ALTER TABLE us_crime_dataset
MODIFY COLUMN State VARCHAR(50);

#Adding Month_Num column as TINYINT for more efficient numerical representation of months
ALTER TABLE us_crime_dataset
ADD COLUMN Month_Num TINYINT AFTER Year;
#Populating Month_Num column by converting month names to their corresponding numerical values
UPDATE us_crime_dataset
SET Month_Num = 
  CASE Month
    WHEN 'January' THEN 1
    WHEN 'February' THEN 2
    WHEN 'March' THEN 3
    WHEN 'April' THEN 4
    WHEN 'May' THEN 5
    WHEN 'June' THEN 6
    WHEN 'July' THEN 7
    WHEN 'August' THEN 8
    WHEN 'September' THEN 9
    WHEN 'October' THEN 10
    WHEN 'November' THEN 11
    WHEN 'December' THEN 12
  END;
#Dropping the original Month column since Month_Num now represents month values efficiently
ALTER TABLE us_crime_dataset DROP COLUMN Month;
#Renaming Month_Num column to Month for clarity while keeping it as TINYINT
ALTER TABLE us_crime_dataset CHANGE COLUMN Month_Num Month TINYINT;

#Changing Crime_Type data type to VARCHAR(100) to optimize storage while supporting various crime types
ALTER TABLE us_crime_dataset
MODIFY COLUMN Crime_Type VARCHAR(100);

#Adding Crime_Solved_Char column as CHAR(1) to store 'Y' or 'N' for more efficient storage
ALTER TABLE us_crime_dataset
ADD COLUMN Crime_Solved_Char CHAR(1) AFTER Crime_Type;
# Populating Crime_Solved_Char column by converting 'Yes'/'No' values to 'Y'/'N'
UPDATE us_crime_dataset
SET Crime_Solved_Char = 
  CASE Crime_Solved
    WHEN 'Yes' THEN 'Y'
    WHEN 'No' THEN 'N'
  END;
#Dropping the original Crime_Solved column since Crime_Solved_Char now represents the same data more efficiently
ALTER TABLE us_crime_dataset DROP COLUMN Crime_Solved;
#Renaming Crime_Solved_Char column to Crime_Solved for consistency while keeping it CHAR(1)
ALTER TABLE us_crime_dataset CHANGE COLUMN Crime_Solved_Char Crime_Solved CHAR(1);

#Adding Victim_Sex_Char column as CHAR(2) to store 'M', 'F', or 'NA' for more efficient storage
ALTER TABLE us_crime_dataset
ADD COLUMN Victim_Sex_Char CHAR(2) AFTER Crime_Solved;
# Populating Victim_Sex_Char column by converting 'Male'/'Female'/'Unknown' values to 'M'/'F'/'NA'
UPDATE us_crime_dataset
SET Victim_Sex_Char = 
  CASE Victim_Sex
    WHEN 'Male' THEN 'M'
    WHEN 'Female' THEN 'F'
    WHEN 'Unknown' THEN 'NA'
  END;
#Dropping the original Victim_Sex column since Victim_Sex_Char now represents the same data more efficiently
ALTER TABLE us_crime_dataset DROP COLUMN Victim_Sex;
#Renaming Victim_Sex_Char column to Victim_Sex for consistency while keeping it CHAR(2)
ALTER TABLE us_crime_dataset CHANGE COLUMN Victim_Sex_Char Victim_Sex CHAR(2);

#Converting 'Unknown' values in Victim_Age to NULL for accurate numerical representation
UPDATE us_crime_dataset
SET Victim_Age = NULL
WHERE Victim_Age = 'Unknown';
#Changing Victim_Age data type to INT for efficient numerical storage
ALTER TABLE us_crime_dataset
MODIFY COLUMN Victim_Age INT;

#Changing Victim_Race data type to VARCHAR(100) to allow flexibility in representing different races
ALTER TABLE us_crime_dataset
MODIFY COLUMN Victim_Race VARCHAR(100);

#Changing Victim_Ethnicity data type to VARCHAR(50) for optimized storage while allowing diverse ethnicity values
ALTER TABLE us_crime_dataset
MODIFY COLUMN Victim_Ethnicity VARCHAR(50);

#Adding Perpetrator_Sex_Char column as CHAR(2) to store 'M', 'F', or 'NA' for more efficient storage
ALTER TABLE us_crime_dataset
ADD COLUMN Perpetrator_Sex_Char CHAR(2) AFTER Victim_Ethnicity;
#Populating Perpetrator_Sex_Char column by converting 'Male'/'Female'/'Unknown' values to 'M'/'F'/'NA'
UPDATE us_crime_dataset
SET Perpetrator_Sex_Char = 
  CASE Perpetrator_Sex
    WHEN 'Male' THEN 'M'
    WHEN 'Female' THEN 'F'
    WHEN 'Unknown' THEN 'NA'
  END;
#Dropping the original Perpetrator_Sex column since Perpetrator_Sex_Char now represents the same data more efficiently
ALTER TABLE us_crime_dataset DROP COLUMN Perpetrator_Sex;
#Renaming Perpetrator_Sex_Char column to Perpetrator_Sex for consistency while keeping it CHAR(2)
ALTER TABLE us_crime_dataset CHANGE COLUMN Perpetrator_Sex_Char Perpetrator_Sex CHAR(2);

#Converting 'Unknown' values in Perpetrator_Age to NULL for accurate numerical representation
UPDATE us_crime_dataset
SET Perpetrator_Age = NULL
WHERE Perpetrator_Age = 'Unknown';
#Changing Perpetrator_Age data type to INT for efficient numerical storage
ALTER TABLE us_crime_dataset
MODIFY COLUMN Perpetrator_Age INT;

#Changing Perpetrator_Race data type to VARCHAR(100) to allow flexibility in representing different races
ALTER TABLE us_crime_dataset
MODIFY COLUMN Perpetrator_Race VARCHAR(100);

#Changing Perpetrator_Ethnicity data type to VARCHAR(50) for optimized storage while allowing diverse ethnicity values
ALTER TABLE us_crime_dataset
MODIFY COLUMN Perpetrator_Ethnicity VARCHAR(50);

#Changing Relationship data type to VARCHAR(50) to optimize storage while accommodating different relationship types
ALTER TABLE us_crime_dataset
MODIFY COLUMN Relationship VARCHAR(50);

#Changing Weapon data type to VARCHAR(50) to optimize storage while allowing diverse weapon types
ALTER TABLE us_crime_dataset
MODIFY COLUMN Weapon VARCHAR(50);

#STEP 3: CHECKING FOR DUPLICATES

#Checking for duplicates resulted in finding 1,676 records that were duplicates
SELECT Agency_Code, Agency_Name, Agency_Type, City, State, Year, Month, Incident, Crime_Type, Crime_Solved, Victim_Sex, Victim_Age, 
       Victim_Race, Victim_Ethnicity, Perpetrator_Sex, Perpetrator_Age, Perpetrator_Race, Perpetrator_Ethnicity, Relationship, Weapon, 
       COUNT(*) AS duplicate_count
FROM us_crime_dataset
GROUP BY Agency_Code, Agency_Name, Agency_Type, City, State, Year, Month, Incident, Crime_Type, Crime_Solved, Victim_Sex, 
         Victim_Age, Victim_Race, Victim_Ethnicity, Perpetrator_Sex, Perpetrator_Age, Perpetrator_Race, Perpetrator_Ethnicity, 
         Relationship, Weapon
HAVING COUNT(*) > 1;

#Deleting the duplicate records
WITH duplicate_records AS (
    SELECT MIN(Record_ID) AS keep_id
    FROM us_crime_dataset
    GROUP BY Agency_Code, Agency_Name, Agency_Type, City, State, Year, Month, Incident, Crime_Type, Crime_Solved, 
             Victim_Sex, Victim_Age, Victim_Race, Victim_Ethnicity, Perpetrator_Sex, Perpetrator_Age, 
             Perpetrator_Race, Perpetrator_Ethnicity, Relationship, Weapon
)
DELETE FROM us_crime_dataset
WHERE Record_ID NOT IN (SELECT keep_id FROM duplicate_records);

#Creating 20 indexes to optimize SQL queires and speed up process of retrieval
CREATE INDEX index_agency_code ON us_crime_dataset(Agency_Code);
CREATE INDEX index_agency_name ON us_crime_dataset(Agency_Name);
CREATE INDEX index_agency_type ON us_crime_dataset(Agency_Type);
CREATE INDEX index_city ON us_crime_dataset(City);
CREATE INDEX index_state ON us_crime_dataset(State);
CREATE INDEX index_year ON us_crime_dataset(Year);
CREATE INDEX index_month ON us_crime_dataset(Month);
CREATE INDEX index_incident ON us_crime_dataset(Incident);
CREATE INDEX index_crime_type ON us_crime_dataset(Crime_Type);
CREATE INDEX index_crime_solved ON us_crime_dataset(Crime_Solved);
CREATE INDEX index_victim_sex ON us_crime_dataset(Victim_Sex);
CREATE INDEX index_victim_age ON us_crime_dataset(Victim_Age);
CREATE INDEX index_victim_race ON us_crime_dataset(Victim_Race);
CREATE INDEX index_victim_ethnicity ON us_crime_dataset(Victim_Ethnicity);
CREATE INDEX index_perp_sex ON us_crime_dataset(Perpetrator_Sex);
CREATE INDEX index_perp_age ON us_crime_dataset(Perpetrator_Age);
CREATE INDEX index_perp_race ON us_crime_dataset(Perpetrator_Race);
CREATE INDEX index_perp_ethnicity ON us_crime_dataset(Perpetrator_Ethnicity);
CREATE INDEX index_relationship ON us_crime_dataset(Relationship);
CREATE INDEX index_weapon ON us_crime_dataset(Weapon);
SHOW INDEX FROM us_crime_dataset;

#STEP 4: DATA ANALYSIS

#Question 1: How many total crimes have there been from 1980 to 2014?
SELECT COUNT(*) AS Total_Crimes
FROM us_crime_dataset;
#Notes: There have been 636,670 total crimes.

#Question 2: How many total agencies are there and how many crimes are associated with each?
SELECT Agency_Name,
	   COUNT(Agency_Name) AS Total_Crimes
FROM us_crime_dataset
GROUP BY Agency_Name
ORDER BY Total_Crimes DESC;
/*Notes: 
-There are 9,215 total agencies.
-New York, Los Angeles, and Chicago agencies have the most crimes associated with them.*/

#Question 3: How many agency types are there and the number of crimes associated with each, as well as the running total and percentage of total?
SELECT Agency_Type, 
	   COUNT(Agency_Type) AS Total_Crimes,
       SUM(COUNT(Agency_Type)) OVER(ORDER BY COUNT(Agency_Type) DESC) AS Running_Total,
	   ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM us_crime_dataset),2) AS Percent_Total
FROM us_crime_dataset
GROUP BY Agency_Type
ORDER BY Total_Crimes DESC;
/*Notes:
-There are 7 agency types in the dataset.
-Municipal Police have the highest number of crimes associated with them by a long shot, 491,681 or 77.23% of the total.*/

#Question 4: How many cities are there, as well as the number of crimes in each and the percentage of total?
SELECT City,
	   COUNT(*) AS Total_Crimes,
       ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM us_crime_dataset),2) AS Percent_Total
FROM us_crime_dataset
GROUP BY City
ORDER BY Total_Crimes DESC;
/*Notes:
-There are 1,782 cities in the dataset.
-Los Angeles, New York, and Cook have the highest number of crimes.*/

#Question 5: How many states are there, as well as the number of crimes in each and the percentage of total?
SELECT State,
	   COUNT(*) AS Total_Crimes,
       ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM us_crime_dataset),2) AS Percent_Total
FROM us_crime_dataset
GROUP BY State
ORDER BY Total_Crimes DESC;
/*Notes:
-There are 51 states and terrotories in the dataset.
-California, Texas, and New York have the highest number of crimes.*/

#Question 6: What's the distribution of crimes from 1980 to 2014?
SELECT Year,
	   COUNT(*) AS Total_Crimes
FROM us_crime_dataset
GROUP BY Year
ORDER BY Year ASC;
#Notes: There was an overall decrease in number of crimes from 1980 to 2014, with a peak in 1993, followed by a relatvely sharp decline.

#Question 7: What's the month with the max number of crimes for each year?
WITH CrimeRank AS (
    SELECT Year,
           Month,
           COUNT(*) AS Total_Crimes,
           RANK() OVER (PARTITION BY Year ORDER BY COUNT(*) DESC) AS ranked
    FROM us_crime_dataset
    GROUP BY Year, Month
)
SELECT Year, 
       Month, 
       Total_Crimes
FROM CrimeRank
WHERE ranked = 1
ORDER BY Month;
#Notes: Throughout 1980 to 2014, the max amount of crimes most of the time happened during July, August, and December.

#Question 8: How mant total incidents are there?
SELECT SUM(Incident)
FROM us_crime_dataset;
#Notes: There was a total of 14,644,492 incidents.

#Question 9: How many crimes were there for each crime type?
SELECT Crime_Type,
	   COUNT(*) AS Total_Crimes,
       ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM us_crime_dataset),2) AS Percent_Total
FROM us_crime_dataset
GROUP BY Crime_Type
ORDER BY Total_Crimes DESC;
/*Notes: 
-Murder or Manslaughter crime type had the most crimes, 627,585 or 98.57%.
-Manslaughter by Negligence had the lowest crimes, 9,085 or 1.43%.*/

#Question 10: How many crimes have been solved vs unsolved, as well as the percentage of totals?
SELECT Crime_Solved, 
	   COUNT(*) AS Crime_Count,
       ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM us_crime_dataset),2) AS Crime_Percentage
FROM us_crime_dataset
GROUP BY Crime_Solved
ORDER BY Crime_Count DESC;
/*Notes: 
-Number of solved crimes was 447,017 or 70.21%.
-Number of unsolved crimes was 189,653 or 29.79%.*/

#Question 11: How many different relationships are there, as well as the number of crimes associated with them.
SELECT Relationship,
	   COUNT(*) AS Total_Crimes
FROM us_crime_dataset
GROUP BY Relationship
ORDER BY Total_Crimes DESC;
/*Notes: 
-There were 28 different relationships.
-Acquaintance had the highest total crimes associated with it, 125,711.*/

#Question 12: How many different weapons were used in the crime, as well as the number of crimes associated with them.
SELECT Weapon,
	   COUNT(*) AS Total_Crimes
FROM us_crime_dataset
GROUP BY Weapon
ORDER BY Total_Crimes DESC;
/*Notes:
-There were 16 different weapons.
-Handgun had the highest total crimes associated with it, 316,526.*/

#Question 13: How many crimes were associated with each victim sex?
SELECT Victim_Sex,
	   COUNT(*) AS Total_Crimes
FROM us_crime_dataset
GROUP BY Victim_Sex
ORDER BY Total_Crimes DESC;
/*Notes: 
-Males were the victim 492,666 times.
-Females were the victim 143,038 times.*/

#Question 14: What's the average age for the victim across all crimes?
SELECT ROUND(AVG(Victim_Age),0) AS Average_Age
FROM us_crime_dataset;
#Notes: The average victim age was 34 years old.

#Question 15: How many different races were there, as well as the number of crimes per victim race and the percent total?
SELECT Victim_Race,
	   COUNT(*) AS Total_Crimes,
       ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM us_crime_dataset),2) AS Percent_Total
FROM us_crime_dataset
GROUP BY Victim_Race
ORDER BY Total_Crimes DESC;
/*Notes:
-There were 5 races, including unknowns.
-White and black races had the most crimes against them, 316,521 or 49.72% and 299,116 or 46.98% respectively.*/

#Question 16: How many crimes were associated with each victim ethnicity? 
SELECT Victim_Ethnicity,
	   COUNT(*) AS Total_Crimes
FROM us_crime_dataset
GROUP BY Victim_Ethnicity
ORDER BY Total_Crimes DESC;
/*Notes: 
-There were 367,165 unknown victim ethnicites.
-There were 197,086 non-hispanics and 72,419 hispanics for the victim ethnicites.*/

#Question 17: How many crimes were associated with each perpetrator sex?
SELECT Perpetrator_Sex,
	   COUNT(*) AS Total_Crimes
FROM us_crime_dataset
GROUP BY Perpetrator_Sex
ORDER BY Total_Crimes DESC;
/*Notes: 
-Males were the perpetrator 398,472 times.
-Females were the perpetrator 48,462 times.*/

#Question 18: What's the average age for the perpetrator across all crimes?
SELECT ROUND(AVG(Perpetrator_Age),0) AS Average_Age
FROM us_crime_dataset;
#Notes: The average perpetrator age was 31 years old.

#Question 19: How many different races were there, as well as the number of crimes per perpetrator race and the percent total?
SELECT Perpetrator_Race,
	   COUNT(*) AS Total_Crimes,
       ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM us_crime_dataset),2) AS Percent_Total
FROM us_crime_dataset
GROUP BY Perpetrator_Race
ORDER BY Total_Crimes DESC;
/*Notes:
-There were 5 races, including unknowns.
-White and black races had the most crimes, 217,671 or 34.19% and 213,994 or 33.61% respectively.*/

#Question 20: How many crimes were associated with each perpetrator ethnicity? 
SELECT Perpetrator_Ethnicity,
	   COUNT(*) AS Total_Crimes
FROM us_crime_dataset
GROUP BY Perpetrator_Ethnicity
ORDER BY Total_Crimes DESC;
/*Notes: 
-There were 445,013 unknown victim ethnicites.
-There were 144,909 non-hispanics and 46,748 hispanics for the perpetrator ethnicites.*/

#Question 21: What's the percentage of crimes solved per city, as well as their rank by highest solve rate?
WITH solved_city AS (
				SELECT City, 
					   ROUND((SUM(CASE WHEN Crime_Solved = 'Y' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),2) AS Solved_Rate
				FROM us_crime_dataset
				GROUP BY City
				ORDER BY Solved_Rate DESC
				)
SELECT *
FROM (
	  SELECT *,
	         DENSE_RANK() OVER (ORDER BY Solved_Rate DESC) AS `Rank`
	  FROM solved_city
      ) AS ranked;
#WHERE `Rank` = 1
/*Notes: 
-There were 277 cities that had 100% of crimes solved.
-There were 7 cities that had 0% of crimes solved.*/

#Question 22: What's the percentage of crimes solved per state, as well as their rank by highest solve rate?
WITH solved_state AS (
				SELECT State, 
					   ROUND((SUM(CASE WHEN Crime_Solved = 'Y' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),2) AS Solved_Rate
				FROM us_crime_dataset
				GROUP BY State
				ORDER BY Solved_Rate DESC
				)
SELECT *
FROM (
	  SELECT *,
	         DENSE_RANK() OVER (ORDER BY Solved_Rate DESC) AS `Rank`
	  FROM solved_state
      ) AS ranked;
#WHERE `Rank` = 1
/*Notes: 
-North Dakota had the highest solved rate, 93.18%.
-DC had the lowest solved rate, 34.38%.*/

#Question 23: What's the percentage of crimes solved per agency type, as well as the total crimes associated with each?
SELECT Agency_Type,
	   ROUND((SUM(CASE WHEN Crime_Solved = 'Y' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),2) AS Solved_Rate,
	   COUNT(*) AS Total_Crimes
FROM us_crime_dataset
GROUP BY Agency_Type
ORDER BY Solved_Rate DESC;
/*Notes:
-Tribal Police had the highest solved rate, 92.59%, but that's mainly because there were only 54 crimes associated with them.
-County Police had the lowest solved rate, 66.90%, but that's mainly because there were 22,625 crimes associated with them.*/

#Question 24: What's the percentage of crimes solved per state from 1980 to 2014, as well as the total crimes and total incidents?
SELECT State,
	   Year,
	   ROUND((SUM(CASE WHEN Crime_Solved = 'Y' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),2) AS Solved_Rate,
	   ROUND((SUM(CASE WHEN Crime_Solved = 'N' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),2) AS Unsolved_Rate,
       COUNT(*) AS Total_Crimes,
       SUM(Incident) AS Total_Incidents
FROM us_crime_dataset
GROUP BY State, Year
ORDER BY State, Year;
#Notes: The result shows the state, year, solved rate, unsolved rate, total crimes, and total incidents across all states from 1980 to 2014.

/*Question 25: What were the instances of murder cases between 1980 and 1999 in U.S. capital cities, where the victim was a female and less 
than or equal to 30 years old, and the perpetrator was a male and greater than or equal to 20 years old of the same race, and the 
relatonship was non-family?*/
SELECT City, State, Year, Month, Incident, Crime_Solved, Victim_Age, Victim_Race, Perpetrator_Age, Perpetrator_Race, Relationship, Weapon
FROM us_crime_dataset
WHERE City IN ('Montgomery', 'Juneau', 'Phoenix', 'Little Rock', 'Sacramento', 'Denver', 'Hartford', 'Dover', 'Tallahassee', 'Atlanta', 
'Honolulu', 'Boise', 'Springfield', 'Indianapolis', 'Des Moines', 'Topeka', 'Frankfort', 'Baton Rouge', 'Augusta', 'Annapolis', 'Boston', 
'Lansing', 'Saint Paul', 'Jackson', 'Jefferson City', 'Helena', 'Lincoln', 'Carson City', 'Concord', 'Trenton', 'Santa Fe', 'Albany', 
'Raleigh', 'Bismarck', 'Columbus', 'Oklahoma City', 'Salem', 'Harrisburg', 'Providence', 'Columbia', 'Pierre', 'Nashville', 'Austin', 
'Salt Lake City', 'Montpelier', 'Richmond', 'Olympia', 'Charleston', 'Madison', 'Cheyenne', 'District of Columbia')
AND Year BETWEEN '1980' AND '1999'
AND Victim_Race = Perpetrator_Race
AND Victim_Sex = 'F'
AND Perpetrator_Sex = 'M'
AND Victim_Age <= 30 
AND Victim_Age IS NOT NULL
AND Perpetrator_Age >= 20
AND Perpetrator_Age IS NOT NULL
AND Crime_Type LIKE '%Murder%'
AND Relationship IN ('Acquaintance', 'Friend', 'Stranger', 'Girlfriend', 'Boyfriend', 'Boyfriend/Girlfriend', 'Employer', 'Employee', 
'Ex-Wife', 'Ex-Husband', 'Neighbor', 'Unknown')
ORDER BY City, State, Year, Month, Incident;
#Notes: There were 737 cases for these specific crimes.

#Question 26: What were the total crimes and number of incidents by state and weapon?
SELECT State, 
       Weapon,
       COUNT(*) AS Total_Crimes,
       SUM(Incident) AS Total_Incidents
FROM us_crime_dataset
GROUP BY State, Weapon
ORDER BY State, Total_Crimes DESC, Total_Incidents DESC;
#Notes: The result shows the state, weapon, total crimes, and total incidents across all states.

#Question 27: How many crimes were there for when both the victim's and perpetrator's race were the same?
SELECT Victim_Race, 
	   Perpetrator_Race, 
       COUNT(*) AS Total_Crimes
FROM us_crime_dataset
WHERE Victim_Race = Perpetrator_Race
GROUP BY Victim_Race, Perpetrator_Race
ORDER BY Total_Crimes DESC;
/*Notes: 
-White race for both victim and perpetrator had the most crimes associated with them, 196,662 crimes.
-Native American/Alaska Native for both victim and perpetrator had the least crimes associated with them, 2,003 crimes.*/

#Question 28: How many crimes were there for when both the victim's and perpetrator's sex were the same?
SELECT Victim_Sex, 
	   Perpetrator_Sex, 
       COUNT(*) AS Total_Crimes
FROM us_crime_dataset
WHERE Victim_Sex = Perpetrator_Sex
GROUP BY Victim_Sex, Perpetrator_Sex
ORDER BY Total_Crimes DESC;
/*Notes:
-Male sex for both victim and perpetrator had the most crimes associated with them, 299,015 crimes.
-Female sex for both victim and perpetrator had the least crimes associated with them, 10,824 crimes.*/

#Question 29: Which cities had above average crime?
WITH city_crimes AS (SELECT City, COUNT(*) AS Crime_Count
			         FROM us_crime_dataset
				     GROUP BY City), 
     avg_crime AS (SELECT AVG(Crime_Count) AS Average_Crime FROM city_crimes)
SELECT City, Crime_Count
FROM city_crimes
WHERE Crime_Count > (SELECT Average_Crime FROM avg_crime)
ORDER BY Crime_Count DESC;
#Notes: 248 cities, or 14% of the total cities, had above average crime.

#Question 29: Which states had above average crime?
WITH state_crimes AS (SELECT State, COUNT(*) AS Crime_Count
			         FROM us_crime_dataset
				     GROUP BY State), 
     avg_crime AS (SELECT AVG(Crime_Count) AS Average_Crime FROM state_crimes)
SELECT State, Crime_Count
FROM state_crimes
WHERE Crime_Count > (SELECT Average_Crime FROM avg_crime)
ORDER BY Crime_Count DESC;
#Notes: 17 states, or 33% of the total states, had above average crime.

#Question 30: What's the number of solved vs unsolved crime cases by weapon type?
SELECT Weapon,
	   COUNT(*) AS Total_Crimes,
	   ROUND(SUM(CASE WHEN Crime_Solved = 'Y' THEN 1 ELSE 0 END) / COUNT(*) * 100,2) AS Solved_Percentage,
	   ROUND(SUM(CASE WHEN Crime_Solved = 'N' THEN 1 ELSE 0 END) / COUNT(*) * 100,2) AS Unsolved_Percentage
FROM us_crime_dataset
GROUP BY Weapon
ORDER BY Solved_Percentage DESC;
/*Notes:
-Drugs have the highest solve rate, 87.89%.
-Firearms have the lowest solve rate, 51.98%.*/

#Question 31: What's the percentage of crimes solved per agency, as well as the total crimes associated with each?
SELECT Agency_Name,
	   ROUND((SUM(CASE WHEN Crime_Solved = 'Y' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),2) AS Solved_Rate,
	   COUNT(*) AS Total_Crimes
FROM us_crime_dataset
GROUP BY Agency_Name
ORDER BY Total_Crimes DESC;
/*Notes:
-There was a large amount of agencies that had a 100% solve rate, but that was mostly because there was a handful of crimes commited.
-New York, Los Angeles, Chicago, and Detriot were the top 4 in terms of total crimes, and their solve rate was around 50%-64%.*/

#Question 32: What's the percentage of crimes solved per relationship, as well as the total crimes associated with each?
SELECT Relationship,
	   ROUND((SUM(CASE WHEN Crime_Solved = 'Y' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),2) AS Solved_Rate,
	   COUNT(*) AS Total_Crimes
FROM us_crime_dataset
GROUP BY Relationship
ORDER BY Solved_Rate DESC;
/*Notes:
-The solve rate for most defined relationships were greater than 90%.
-The solve rate for unknown relationships was only 34.75%.*/

#Question 33: Answer mutliple questions for solved crimes between 2000 and 2014 with more than 1 incident?
CREATE TEMPORARY TABLE solved_crimes_2000_2014 AS
SELECT *
FROM us_crime_dataset
WHERE Crime_Solved = 'Y' AND Year BETWEEN 2000 AND 2014 AND Incident > 1;

#Question 33a: What are the average number of incidents and total crimes for each state?
SELECT State, 
	   ROUND(AVG(Incident),0) AS Average_Incidents,
	   SUM(Incident) AS Total_Incidents, 
       COUNT(*) AS Total_Crimes
FROM solved_crimes_2000_2014
GROUP BY State
ORDER BY Average_Incidents DESC, Total_Crimes DESC;
/*Notes:
-Florida has a very high average incidents count, 491. This is largely due to the sum of incidents, 5,880,600 and high number of crimes, 11,988.
-The other 50 states have a much lower average, less than 40.*/

#Question 33b: What were the total number of solved crimes for each year and month, as well as the running total and max amount of crimes per year?
SELECT Year,
       Month,
       COUNT(*) AS Total_Crimes,
       SUM(COUNT(*)) OVER(PARTITION BY Year ORDER BY Year, Month) AS Running_Total,
       MAX(COUNT(*)) OVER(PARTITION BY Year ORDER BY Year) AS Max_Per_Year
FROM solved_crimes_2000_2014
GROUP BY Year, Month
ORDER BY Year, Month;
#Notes: The result shows the year, month, total crimes, running total, and the max amount of crimes per year based on the month.

#Question 34: How have solved vs unsolved rates changed over time, as well as the total crimes per year and the percentage of total crimes?
SELECT Year,
	   ROUND((SUM(CASE WHEN Crime_Solved = 'Y' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),2) AS Solved_Rate,
	   ROUND((SUM(CASE WHEN Crime_Solved = 'N' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),2) AS Unsolved_Rate,
       COUNT(*) AS Total_Crimes,
       ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM us_crime_dataset),2) AS Percentage_Crimes_Total
FROM us_crime_dataset
GROUP BY Year;
/*Notes:
-In the 1980s, the solve rate was the highest, and the number of crimes fluctuated between high and low.
-In the 1990s, the solve rate declined and the number of crimes were relatively high, until a sharp decline in 1996.
-In the 2000s, the solve rate was also relatively lower than previous decades, but the number of crimes was the lowest.*/

#Question 35: What are the total number of incidents by weapon, as well as the percentage total?
SELECT Weapon,
       SUM(Incident) AS Total_Incidents,
	   ROUND(SUM(Incident) * 100 / (SELECT SUM(Incident) FROM us_crime_dataset),2) AS Percentage_Total
FROM us_crime_dataset
GROUP BY Weapon
ORDER BY Total_Incidents DESC;
/*Notes:
-Handguns have the most incidents by far, 7,092,793 or 48.43%.
-Falling has the least incidents, 1,830 or 0.01%.*/

#Question 36: What were the total number of incidents by state, as well as the percentage of total?
SELECT State,
	   SUM(Incident) AS Total_Incidents,
	   ROUND(SUM(Incident) * 100 / (SELECT SUM(Incident) FROM us_crime_dataset),2) AS Percentage_Total
FROM us_crime_dataset
GROUP BY State
ORDER BY Total_Incidents DESC;
/*Notes:
-Florida had the most incidents, 8,100,047 or 55.31%.
-North Dakota had the least incidents, 314 or 0.00%.*/
