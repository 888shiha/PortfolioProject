/*This is a data analytics project where I analyze 3 tables that stem from the Handshake app. This data shows company's engagements 
with the University of Arizona via Career Fairs, Events, and Interviews (each item represented by 1 table). */

#STEP 1: Data Cleaning Phase

#1a: Changing Table Names
ALTER TABLE hs_scorecard_careerfairs RENAME TO careerfairs;
ALTER TABLE hs_scorecard_events RENAME TO `events`;
ALTER TABLE hs_scorecard_interviews RENAME TO interviews;

#1b: Dropping Unnecessary Columns
ALTER TABLE careerfairs DROP COLUMN `Registrations Status`;
ALTER TABLE careerfairs DROP COLUMN `Employers Count`;

#1c: Changing Column Names
ALTER TABLE careerfairs CHANGE `Career Fair ID` ID int;
ALTER TABLE careerfairs CHANGE `Career Fairs Name` CareerFairName text;
ALTER TABLE careerfairs CHANGE `Employers Name` Employer text;
ALTER TABLE careerfairs CHANGE `Career Fair Dates and Times Start Date` `Date` text;
ALTER TABLE careerfairs CHANGE `Career Center Name` CareerCenter text;
ALTER TABLE `events` CHANGE `Events ID` ID int;
ALTER TABLE `events` CHANGE `Employers Name` Employer text;
ALTER TABLE `events` CHANGE `Events Name` EventName text;
ALTER TABLE `events` CHANGE `Event Type Name` EventType text;
ALTER TABLE `events` CHANGE `Career Center Name` CareerCenter text;
ALTER TABLE `events` CHANGE `Events Start Date` `Date` text;
ALTER TABLE `events` CHANGE `Attendees Count` AttendeesCount int;
ALTER TABLE interviews CHANGE `Employer ID` ID int;
ALTER TABLE interviews CHANGE `Employer Name` Employer text;
ALTER TABLE interviews CHANGE `Career Center Name` CareerCenter text;
ALTER TABLE interviews CHANGE `Interview Date` `Date` text;

#1d: Changing Data Types
ALTER TABLE careerfairs MODIFY `Date` DATE;
UPDATE `events` SET `Date` = DATE_FORMAT(STR_TO_DATE(`Date`, '%m/%d/%Y'), '%Y-%m-%d'); ALTER TABLE `events` MODIFY `Date` DATE;
ALTER TABLE interviews MODIFY `Date` DATE;

#1e: Adding 2 New Columns to Categorize Career Fair Name by Category and Format
ALTER TABLE careerfairs
ADD COLUMN CareerFairCategory VARCHAR(255)
AFTER CareerFairName;
UPDATE careerfairs
SET CareerFairCategory = 
	CASE 
		WHEN CareerFairName LIKE '%All Majors%' OR CareerFairName LIKE '%Career Mixer%' OR CareerFairName LIKE '%Impact Day%' THEN 'All Majors'
		WHEN CareerFairName LIKE '%CALS%' THEN 'CALS'
        WHEN CareerFairName LIKE '%Business%' OR CareerFairName LIKE '%Eller%' OR CareerFairName LIKE '%Commerce%' OR CareerFairName LIKE '%MBSA%' THEN 'Business'
		WHEN CareerFairName LIKE '%STEM%' OR CareerFairName LIKE '%Engineering%' OR CareerFairName LIKE '%Computer Science%' THEN 'STEM'
		WHEN CareerFairName LIKE '%Education%' THEN 'Education'
		WHEN CareerFairName LIKE '%CAPLA%' THEN 'CAPLA'
        WHEN CareerFairName LIKE '%Internship and Tucson Jobs%' THEN 'Internships & Tucson Jobs'
        WHEN CareerFairName LIKE '%Internship%' THEN 'Internships'
		WHEN CareerFairName LIKE '%Local%' OR CareerFairName LIKE '%Tucson%' THEN 'Tucson Jobs'
		WHEN CareerFairName LIKE '%Graduate%' THEN 'Graduate Fairs'
        WHEN CareerFairName LIKE '%Public Service%' OR CareerFairName LIKE '%Global Impact%' THEN 'Global Impact & Public Service'
		WHEN CareerFairName LIKE '%Wildcat Student Employment%' THEN 'Campus Jobs'
        WHEN CareerFairName LIKE '%International%' THEN 'International'
        WHEN CareerFairName LIKE '%Health%' THEN 'Health'
		ELSE 'Other'
	END;

ALTER TABLE careerfairs
ADD COLUMN CareerFairFormat VARCHAR(100)
AFTER CareerFairCategory;
UPDATE careerfairs
SET CareerFairFormat = 
	CASE 
		WHEN CareerFairName LIKE '%In%Person%' THEN 'In-Person' 
        WHEN CareerFairName LIKE '%Virtual%' THEN 'Virtual'
        WHEN CareerFairName LIKE '%Eller%' THEN 'In-Person'
        WHEN CareerFairName LIKE '%Expo%' THEN 'In-Person'
		WHEN CareerFairName LIKE '%2022 CAPLA Job Interview%' THEN 'In-Person & Virtual'
        WHEN CareerFairName LIKE '%2023 CAPLA Job%Interview%' THEN 'In-Person'
        WHEN CareerFairName LIKE '%2021%Fall Tucson Jobs Now%' THEN 'Virtual'
        ELSE 'In-Person'
	END;

#1f: Updating the Blank Values in the Career Center Column
UPDATE events
SET CareerCenter = 'Unknown'
WHERE CareerCenter = '';

#STEP 2: Data Analysis Phase For All 3 Tables

#Question 1: How many times was each Career Fair hosted?
SELECT CareerFairName, COUNT(*) AS TimesHosted
FROM careerfairs
GROUP BY CareerFairName
ORDER BY TimesHosted DESC;

#Question 2: How many Career Fairs did each Employer attend?
SELECT Employer, COUNT(*) AS NumberofCareerFairs
FROM careerfairs
GROUP BY Employer
ORDER BY NumberofCareerFairs DESC;

#Question 3: How many Career Fairs were hosted by Year, Quarter, and Month?
SELECT 
	  YEAR(`Date`) AS `Year`, 
      QUARTER(`Date`) AS `Quarter`, 
      MONTH(`Date`) AS `Month`, 
      COUNT(*) AS NumberofCareerFairs
FROM careerfairs
GROUP BY `Year`, `Quarter`, `Month`
ORDER BY `Year` ASC, `Quarter` ASC, `Month` ASC;

#Question 4: How many Career Fairs did each Career Center host?
SELECT CareerCenter, COUNT(*) AS NumberofCareerFairs
FROM careerfairs
GROUP BY CareerCenter
ORDER BY NumberofCareerFairs DESC;

#Question 5: Which Employers participated in 3 or more Career Fairs during the Fall semester?
SELECT Employer, 
	   MONTH(`Date`) AS `Month`, 
       COUNT(*) AS TotalTimes
FROM careerfairs
WHERE MONTH(`Date`) IN (9,10,11)
GROUP BY Employer, `Month`
HAVING TotalTimes >= 3
ORDER BY Employer ASC, `Month` ASC;

#Question 6: How many Career Fairs were In-Person vs Virtual vs Hybrid and what's the percentage of the total for each?
SELECT CareerFairFormat, COUNT(*) AS Total, ROUND(((COUNT(*)/2320)*100),2) AS Percentage
FROM careerfairs
GROUP BY CareerFairFormat
ORDER BY Total DESC;

#Question 7: What's the breakdown of Career Fairs by Categories along with the percentage of the total and the running total?
SELECT CareerFairCategory, 
	   COUNT(*) AS Total, 
       ROUND(((COUNT(*)/2320)*100),2) AS Percentage,
       SUM(ROUND(((COUNT(*)/2320)*100),2)) OVER (ORDER BY COUNT(*) DESC) AS RunningTotal
FROM careerfairs
GROUP BY CareerFairCategory;

#Question 8: How many Career Fairs has each Employer participated in, categorized by Category, and what is the running total?
SELECT Employer,
	   CareerFairCategory,
       COUNT(*) AS Total,
       SUM(COUNT(*)) OVER (PARTITION BY Employer ORDER BY CareerFairCategory) AS RunningTotal
FROM careerfairs
GROUP BY Employer, CareerFairCategory;

#Question 9: How many In-Person and/or Virtual Career Fairs has each Employer participated in?
SELECT DISTINCT Employer, CareerFairFormat, COUNT(*) AS Total
FROM careerfairs
GROUP BY Employer, CareerFairFormat
ORDER BY Employer, CareerFairFormat, Total DESC;

#Question 10: Which Career Centers hosted Career Fairs above average for In-Person and/or Virtual?
SELECT CareerCenter, CareerFairFormat, COUNT(*) AS Total
FROM careerfairs
GROUP BY CareerCenter, CareerFairFormat
HAVING COUNT(*) > (SELECT AVG(Total_Count) 
				   FROM (SELECT COUNT(*) AS Total_Count 
                         FROM careerfairs 
                         GROUP BY CareerCenter, CareerFairFormat) AS subquery)
ORDER BY CareerCenter DESC, CareerFairFormat, Total DESC;

#Question 11: How many Events did each Employer attend?
SELECT Employer, COUNT(*) AS NumberofEvents
FROM events
GROUP BY Employer
ORDER BY NumberofEvents DESC;

#Question 12: How many times was each Event hosted?
SELECT EventName, COUNT(*) AS TimesHosted
FROM events
GROUP BY EventName
ORDER BY TimesHosted DESC;

#Question 13: How many times did each Event Type occur and what was that Percentage of the Total?
SELECT EventType, 
       COUNT(*) AS NumberofTimes,
       ROUND((COUNT(*)/1527)*100,2) AS Percentage
FROM events
GROUP BY EventType
ORDER BY NumberofTimes DESC;

#Question 14: How many Events were hosted by Year, Quarter, and Month?
SELECT YEAR(`Date`) AS `Year`, 
       QUARTER(`Date`) AS `Quarter`, 
       MONTH(`Date`) AS `Month`, 
       COUNT(*) AS NumberofEvents
FROM events
GROUP BY `Year`, `Quarter`, `Month`
ORDER BY `Year` ASC, `Quarter` ASC, `Month` ASC;

#Question 15: What's the breakdown of Events by Total Attendees along with the Percentage of the Total and the Running Total?
SELECT Employer, 
	   SUM(AttendeesCount) AS TotalAttendees,
       ROUND((SUM(AttendeesCount)/6891)*100,2) AS Percentage,
       SUM(SUM(AttendeesCount)) OVER (ORDER BY SUM(AttendeesCount) DESC, Employer) AS RunningTotal
FROM events
GROUP BY Employer;

#Question 16: How many Attendees were there for each Event Type?
SELECT EventType, SUM(AttendeesCount) AS TotalAttendees
FROM events
GROUP BY EventType
ORDER BY TotalAttendees DESC;

#Question 17: How many Events has each Employer participated in, categorized by Event Type, and what is the Running Total?
SELECT Employer, 
       EventType, 
       COUNT(*) AS Total,
       SUM(COUNT(*)) OVER (PARTITION BY Employer ORDER BY EventType) AS RunningTotal
FROM events
GROUP BY Employer, EventType;
	
#Question 18: During which Years and Months were there the most Attendees?
SELECT YEAR(`Date`) AS `Year`, 
       MONTH(`Date`) AS `Month`,
       SUM(AttendeesCount) AS TotalAttendees
FROM events
GROUP BY `Year`, `Month`
ORDER BY TotalAttendees DESC;

#Question 19: Which Employers have a total Attendees count that's higher than the average?
WITH EmployerTotals AS (
    SELECT Employer, SUM(AttendeesCount) AS TotalAttendees
    FROM events
    GROUP BY Employer)
SELECT Employer, TotalAttendees
FROM EmployerTotals
WHERE TotalAttendees >= (SELECT AVG(TotalAttendees) FROM EmployerTotals)
ORDER BY TotalAttendees DESC;

#Question 20: How many Interviews did each Employer conduct?
SELECT Employer, COUNT(*) AS TotalInterviews
FROM interviews
GROUP BY Employer
ORDER BY TotalInterviews DESC;

#Question 21: How many Interviews were conducted in each Career Center?
SELECT CareerCenter, COUNT(*) AS TotalInterviews
FROM interviews
GROUP BY CareerCenter
ORDER BY TotalInterviews DESC;

#Question 22: How many Interviews were conducted by Year, Quarter, and Month?
SELECT YEAR(`Date`) AS `Year`, 
       QUARTER(`Date`) AS `Quarter`, 
       MONTH(`Date`) AS `Month`,
       COUNT(*) AS TotalInterviews
FROM interviews
GROUP BY `Year`, `Quarter`, `Month`
ORDER BY `Year` ASC, `Quarter` ASC, `Month` ASC;

#Question 23: What's the breakdown of Interviews by both Employer and Career Center?
SELECT Employer, CareerCenter, COUNT(*) AS TotalInterviews
FROM interviews
GROUP BY Employer, CareerCenter
ORDER BY Employer, TotalInterviews DESC;

#Question 24: How many Total Engagements (Interviews+CareerFairs+Events) did each Employer engage in?
SELECT Employer, SUM(TotalEngagements) AS TotalEngagements
FROM (
	SELECT i.Employer, COUNT(*) AS TotalEngagements
    FROM interviews i
    GROUP BY i.Employer
    UNION ALL
    SELECT cf.Employer, COUNT(*) AS TotalEngagements
    FROM careerfairs cf
    GROUP BY cf.Employer
    UNION ALL
    SELECT e.Employer, COUNT(*) AS TotalEngagements
    FROM events e
    GROUP BY e.Employer
) combined
GROUP BY Employer
ORDER BY TotalEngagements DESC;

#Question 25: Use a CTE to determine descriptive statistics for the number of Attendees for Events with more than 0 Attendees?
WITH Attendees AS (
SELECT Employer, 
	   SUM(AttendeesCount) AS TotalAttendees,
       COUNT(AttendeesCount) AS NumberofEvents,
       ROUND(AVG(AttendeesCount),1) AS AverageAttendees,
       MAX(AttendeesCount) AS MaxAttendees,
       MIN(AttendeesCount) AS MinAttendees
FROM events
WHERE AttendeesCount != 0
GROUP BY Employer
)
SELECT *
FROM Attendees
ORDER BY TotalAttendees DESC, NumberofEvents DESC, AverageAttendees DESC, MaxAttendees DESC, MinAttendees DESC;