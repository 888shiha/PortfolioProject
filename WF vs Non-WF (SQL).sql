/*This is a data analytics project where I analyze 2 related tables: Salesforce Users and Whatfix Users. The Salesforce table includes users
who use Salesforce and also includes the important columns that will be used in the analysis. The Whatfix table includes users who use Whatfix.
The Users in both these tables don't match. */

#STEP 1: Data Cleaning Phase

#1a: Changing Table Names
ALTER TABLE sfusers RENAME TO salesforce;
ALTER TABLE whatfixusers RENAME TO whatfix;

#1b: Dropping Unnecessary Columns
ALTER TABLE salesforce DROP COLUMN `First Name`;
ALTER TABLE salesforce DROP COLUMN `Last Name`;
ALTER TABLE salesforce DROP COLUMN `Trellis User`;
ALTER TABLE whatfix DROP COLUMN `Event`;
ALTER TABLE whatfix DROP COLUMN Total;

#1c: Changing Column Names
ALTER TABLE salesforce CHANGE `Full Name` `Name` text;
ALTER TABLE salesforce CHANGE `Emplid` `EmplID` text;
ALTER TABLE salesforce CHANGE `Emplid` `EmplID` text;
ALTER TABLE salesforce CHANGE `Primary Department: Account Name` `PrimaryDepartment` text;
ALTER TABLE salesforce CHANGE `User: Profile: Name` `ProfileName` text;
ALTER TABLE salesforce CHANGE `User: Feature` `Features` text;
ALTER TABLE salesforce CHANGE `Parent Organization` `ParentOrganization` text;
ALTER TABLE salesforce CHANGE `EDS Primary Affiliation` `EDSPrimaryAffiliation` text;
ALTER TABLE salesforce CHANGE `EDS Affiliations` `EDSAffiliations` text;
ALTER TABLE salesforce CHANGE `Created Date` `CreatedDate` text;
ALTER TABLE salesforce CHANGE `User: Role: Name` `Role` text;
ALTER TABLE whatfix CHANGE `User Id` `UserID` text;

#1d: Changing Data Types
UPDATE salesforce SET CreatedDate = DATE_FORMAT(STR_TO_DATE(CreatedDate, '%m/%d/%Y'), '%Y-%m-%d'); 
ALTER TABLE salesforce MODIFY CreatedDate DATE;

#1e: Standardizing Data
UPDATE salesforce
SET EDSPrimaryAffiliation = CONCAT((UPPER(SUBSTRING(EDSPrimaryAffiliation,1,1))), LOWER(SUBSTRING(EDSPrimaryAffiliation, 2)));

#1f: Updating Blank Values
UPDATE salesforce
SET PrimaryDepartment = 'na'
WHERE PrimaryDepartment = '';

UPDATE salesforce
SET Title = 'na'
WHERE Title = '';

UPDATE salesforce
SET Features = 'na'
WHERE Features = '';

#1g: Checking for Duplicates
SELECT NetID, COUNT(*) As Occurrences
FROM salesforce 
GROUP BY NetID 
HAVING Occurrences > 1;

#1h: Adding new column
ALTER TABLE salesforce
ADD COLUMN UserType VARCHAR(50) AFTER EmplID;

UPDATE salesforce s
LEFT JOIN whatfix w ON s.Email = w.UserID
SET s.UserType = CASE
					WHEN w.UserID IS NOT NULL THEN 'Whatfix User'
					ELSE 'Non-Whatfix User'
				 END;


#STEP 2: Data Analysis Phase

#Question 1: What's the number of employees who are Non-Whatfix Users vs Whatfix Users?
SELECT UserType, COUNT(*) AS TotalEmployees
FROM salesforce
GROUP BY UserType;

#Question 2: What's the breakdown of Departments by Whatfix vs Non-Whatfix Users, and their respective percentages?
SELECT UserType, 
       PrimaryDepartment, 
       COUNT(*) AS Total, 
       ROUND(COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY PrimaryDepartment) * 100,1) AS Percent
FROM salesforce
GROUP BY UserType, PrimaryDepartment
ORDER BY PrimaryDepartment, UserType DESC;

#Question 3: What's the breakdown of Profile Names by Whatfix vs Non-Whatfix Users, and their respective percentages?
SELECT UserType, 
       ProfileName, 
       COUNT(*) AS Total, 
       ROUND(COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY ProfileName) * 100,1) AS Percent
FROM salesforce
GROUP BY UserType, ProfileName
ORDER BY ProfileName, UserType DESC;

#Question 4: What's the breakdown of Parent Organization by Whatfix vs Non-Whatfix Users, and their respective percentages?
SELECT UserType, 
       ParentOrganization, 
       COUNT(*) AS Total, 
       ROUND(COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY ParentOrganization) * 100,1) AS Percent
FROM salesforce
GROUP BY UserType, ParentOrganization
ORDER BY ParentOrganization, UserType DESC;

#Question 5: What's the breakdown of EDS Primary Affiliation by Whatfix vs Non-Whatfix Users, and their respective percentages?
SELECT UserType, 
       EDSPrimaryAffiliation, 
       COUNT(*) AS Total, 
       ROUND(COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY EDSPrimaryAffiliation) * 100,1) AS Percent
FROM salesforce
GROUP BY UserType, EDSPrimaryAffiliation
ORDER BY EDSPrimaryAffiliation, UserType DESC;

#Question 6: What's the breakdown of a user's Created Date by Whatfix vs Non-Whatfix Users, and their respective percentages?
SELECT UserType, 
       CreatedDate, 
       COUNT(*) AS Total, 
       ROUND(COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY CreatedDate) * 100,1) AS Percent
FROM salesforce
GROUP BY UserType, CreatedDate
ORDER BY CreatedDate, UserType DESC;

#Question 7: What's the breakdown of Roles by Whatfix vs Non-Whatfix Users, and their respective percentages?
SELECT UserType, 
       Role, 
       COUNT(*) AS Total, 
       ROUND(COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY Role) * 100,1) AS Percent
FROM salesforce
GROUP BY UserType, Role
ORDER BY Role, UserType DESC;

#Question 8: How many employees work for each Department?
SELECT PrimaryDepartment, COUNT(*) AS TotalEmployees
FROM salesforce
GROUP BY PrimaryDepartment
ORDER BY TotalEmployees DESC;

/*Question 9: "Which Parent Organizations have a higher-than-average number of employees who are Primary Affiliates in either Staff or 
			   Faculty, and are not a Whatfix User?*/
SELECT ParentOrganization, COUNT(*) AS TotalEmployees
FROM salesforce
WHERE Email NOT IN (SELECT UserID From whatfix) AND EDSPrimaryAffiliation IN ("Staff", "Faculty")
GROUP BY ParentOrganization
HAVING COUNT(*) > (SELECT AVG(Total) 
				   FROM(
						SELECT COUNT(*) AS Total 
						FROM salesforce 
						GROUP BY ParentOrganization) 
					AS subquery)
ORDER BY TotalEmployees DESC;

#Question 10: What Roles had over 15 total employees?
SELECT * 
FROM (SELECT Role, COUNT(*) AS TotalEmployees
	  FROM salesforce 
      GROUP BY Role) AS tab
WHERE TotalEmployees >= 15
GROUP BY Role
ORDER BY TotalEmployees DESC;

#Question 11: What's the Email, Department, Parent Organization, & Role of only Whatfix Users?
SELECT DISTINCT Email, PrimaryDepartment, ParentOrganization, Role
FROM salesforce s
JOIN whatfix w
ON s.Email = w.UserID;