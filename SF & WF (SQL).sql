/*This is a data analytics project where I analyze 3 tables related to Whatfix usage at the University of Arizona. The 'whatfix' table
shows a list of users who have downloaded this 'helper' tool and indicates how many times they have engaged with it. The 'campuswide' table
is a list of all workers on the University of Arizona campus. The 'sep' table shows the actions each user took in Salesforce during the
month of September. */

#STEP 1: Data Cleaning Phase

#1a: Changing Table Names
ALTER TABLE `whatfix(old)` RENAME TO whatfix;
ALTER TABLE `whatfix(sep)` RENAME TO campuswide;
ALTER TABLE `whatfix(oct)` RENAME TO sep;

#1b: Dropping Unnecessary Columns
ALTER TABLE sep DROP COLUMN `MyUnknownColumn`;

#1c: Changing Column Names
ALTER TABLE campuswide CHANGE `Full Name` FullName text;
ALTER TABLE campuswide CHANGE `Trellis User` TrellisUser int;
ALTER TABLE campuswide CHANGE `User: Active` ActiveUser int;
ALTER TABLE campuswide CHANGE `Emplid` EmplID int;
ALTER TABLE campuswide CHANGE `Job Family` JobFamily text;
ALTER TABLE campuswide CHANGE `Job Function` JobFunction text;
ALTER TABLE campuswide CHANGE `User: Feature` Features text;
ALTER TABLE campuswide CHANGE `Contact ID` ContactID text;
ALTER TABLE campuswide CHANGE `Parent Organization` ParentOrganization text;
ALTER TABLE campuswide CHANGE `Organization: Account Name` AccountName text;
ALTER TABLE campuswide CHANGE `User: Profile: Name` ProfileName text;
ALTER TABLE sep CHANGE Id ID text;
ALTER TABLE whatfix CHANGE `Last Active Date` LastActiveDate text;
ALTER TABLE whatfix CHANGE `User Name` Email text;
ALTER TABLE whatfix CHANGE `Engaged with Whatfix?` EngagedwithWhatfix text;
ALTER TABLE whatfix CHANGE `Last Engagement Date` LastEngagementDate text;
ALTER TABLE whatfix CHANGE `Number of Engagements` NumberofEngagements text;

#1d: Updating the Blank Values in a few columns
UPDATE campuswide
SET JobFamily = 'Unknown'
WHERE JobFamily = '';

UPDATE campuswide
SET JobFunction = 'Unknown'
WHERE JobFunction = '';

UPDATE campuswide
SET Features = 'None'
WHERE Features = '';

UPDATE campuswide
SET ProfileName = 'Unknown'
WHERE ProfileName = '';

#1e: Changing Data Types
ALTER TABLE whatfix MODIFY NumberofEngagements int; 


#STEP 2: Data Analysis Phase For All 3 Tables

#Question 1: How many users are Trellis users (1) vs non-Trellis users (0)?
SELECT TrellisUser, COUNT(*) AS TotalUsers
FROM campuswide
GROUP BY TrellisUser
ORDER BY TotalUsers DESC;

#Question 2: How many users are Active users (1) vs non-Active users (0)?
SELECT ActiveUser, COUNT(*) AS TotalUsers
FROM campuswide
GROUP BY ActiveUser
ORDER BY TotalUsers DESC;

#Question 3: How many Employees are there per Job Title?
SELECT Title, COUNT(*) AS NumberofEmployees
FROM campuswide
GROUP BY Title
ORDER BY NumberofEmployees DESC;

#Question 4: How many Employees are there per Job Family?
SELECT JobFamily, COUNT(*) AS NumberofEmployees
FROM campuswide
GROUP BY JobFamily
ORDER BY NumberofEmployees DESC;

#Question 5: How many Employees are there per Job Function?
SELECT JobFunction, COUNT(*) AS NumberofEmployees
FROM campuswide
GROUP BY JobFunction
ORDER BY NumberofEmployees DESC;

#Question 6: How many Employees are there per Parent Organization?
SELECT ParentOrganization, COUNT(*) AS NumberofEmployees
FROM campuswide
GROUP BY ParentOrganization
ORDER BY NumberofEmployees DESC;

#Question 7: How many Employees are there per Account Name?
SELECT AccountName, COUNT(*) AS NumberofEmployees
FROM campuswide
GROUP BY AccountName
ORDER BY NumberofEmployees DESC;

#Question 8: How many Employees are there per Profile Name?
SELECT ProfileName, COUNT(*) AS NumberofEmployees
FROM campuswide
GROUP BY ProfileName
ORDER BY NumberofEmployees DESC;

#Question 9: How many Employees are there per Role?
SELECT Role, COUNT(*) AS NumberofEmployees
FROM campuswide
GROUP BY Role
ORDER BY NumberofEmployees DESC;

#Question 10: Which users are a Trellis User and Active User and have a title that contains: Manager or Senior or Director?
WITH TrellisUsers AS (
	SELECT *
	FROM campuswide
    WHERE TrellisUser = 1
)
SELECT FullName, Email, Title
FROM TrellisUsers
WHERE ActiveUser = 1 AND (Title LIKE '%Manager%' OR Title LIKE '%Senior%' OR Title LIKE '%Director%');

#Question 11: How many Employees Engaged with Whatfix and how many didn't?
SELECT EngagedWithWhatfix, COUNT(*) AS TotalEmployees
FROM whatfix
GROUP BY EngagedWithWhatfix
ORDER BY TotalEmployees DESC;

#Question 12: What are the top 10 users based on the Number of Engagements with Whatfix?
SELECT Email, NumberofEngagements
FROM whatfix
ORDER BY NumberofEngagements DESC
LIMIT 10;

#Question 13: Split the Feature column by the ';' delimiter.
SELECT 
    `Feature__c.x`, 
    SUBSTRING_INDEX(`Feature__c.x`, ';', 1) AS item_1,
    SUBSTRING_INDEX(SUBSTRING_INDEX(CONCAT(`Feature__c.x`, ';'), ';', 2), ';', -1) AS item_2,
    SUBSTRING_INDEX(SUBSTRING_INDEX(CONCAT(`Feature__c.x`, ';'), ';', 3), ';', -1) AS item_3,
	SUBSTRING_INDEX(SUBSTRING_INDEX(CONCAT(`Feature__c.x`, ';'), ';', 4), ';', -1) AS item_4,
	SUBSTRING_INDEX(SUBSTRING_INDEX(CONCAT(`Feature__c.x`, ';'), ';', 5), ';', -1) AS item_5,
	SUBSTRING_INDEX(SUBSTRING_INDEX(CONCAT(`Feature__c.x`, ';'), ';', 6), ';', -1) AS item_6,
	SUBSTRING_INDEX(SUBSTRING_INDEX(CONCAT(`Feature__c.x`, ';'), ';', 7), ';', -1) AS item_7,
	SUBSTRING_INDEX(SUBSTRING_INDEX(CONCAT(`Feature__c.x`, ';'), ';', 8), ';', -1) AS item_8,
	SUBSTRING_INDEX(SUBSTRING_INDEX(CONCAT(`Feature__c.x`, ';'), ';', 9), ';', -1) AS item_9,
	SUBSTRING_INDEX(SUBSTRING_INDEX(CONCAT(`Feature__c.x`, ';'), ';', 10), ';', -1) AS item_10,
	SUBSTRING_INDEX(SUBSTRING_INDEX(CONCAT(`Feature__c.x`, ';'), ';', 11), ';', -1) AS item_11,
	SUBSTRING_INDEX(SUBSTRING_INDEX(CONCAT(`Feature__c.x`, ';'), ';', 12), ';', -1) AS item_12,
	SUBSTRING_INDEX(SUBSTRING_INDEX(CONCAT(`Feature__c.x`, ';'), ';', 13), ';', -1) AS item_13,
	SUBSTRING_INDEX(SUBSTRING_INDEX(CONCAT(`Feature__c.x`, ';'), ';', 14), ';', -1) AS item_14
FROM sep;

#Question 14: What are the Sum and Average Engagements (ex: total logins, total cases) by Role?
SELECT 
    `UserRole.Name.x`,
    SUM(tot_logins) AS sum_tot_logins,
    ROUND(AVG(tot_logins), 0) AS avg_tot_logins,
    SUM(tot_cases) AS sum_tot_cases,
    ROUND(AVG(tot_cases), 0) AS avg_tot_cases,
    SUM(tot_case_details) AS sum_tot_case_details,
    ROUND(AVG(tot_case_details), 0) AS avg_tot_case_details,
    SUM(tot_events) AS sum_tot_events,
    ROUND(AVG(tot_events), 0) AS avg_tot_events,
    SUM(tot_campaigns) AS sum_tot_campaigns,
    ROUND(AVG(tot_campaigns), 0) AS avg_tot_campaigns,
    SUM(tot_case_updates) AS sum_tot_case_updates,
    ROUND(AVG(tot_case_updates), 0) AS avg_tot_case_updates,
    SUM(tot_appt) AS sum_tot_appt,
    ROUND(AVG(tot_appt), 0) AS avg_tot_appt,
    SUM(tot_avail) AS sum_tot_avail,
    ROUND(AVG(tot_avail), 0) AS avg_tot_avail,
    SUM(tot_act) AS sum_tot_act,
    ROUND(AVG(tot_act), 0) AS avg_tot_act
FROM sep
GROUP BY `UserRole.Name.x`
ORDER BY sum_tot_logins DESC;

#Question 15: What's The total Cases, Events, Campaigns, and Appointments by User?
SELECT `Name.x`, 
		SUM(tot_cases) AS total_cases, 
        SUM(tot_events) AS total_events, 
        SUM(tot_campaigns) AS total_campaigns, 
        SUM(tot_appt) AS total_appointments
FROM sep
GROUP BY `Name.x`
ORDER BY SUM(tot_cases) DESC, SUM(tot_events) DESC, SUM(tot_campaigns) DESC, SUM(tot_appt) DESC;

#Question 16: Who has Engaged with Whatfix and what is their Email, Title, Job Family, and Number of Engagements?
SELECT c.Email, Title, JobFamily, NumberofEngagements
FROM campuswide c
JOIN whatfix w
ON c.Email = w.Email
WHERE EngagedWithWhatfix = 'Yes'
ORDER BY NumberofEngagements DESC;