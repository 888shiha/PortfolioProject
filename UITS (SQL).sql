/*This is a data analytics project where I analyze IT support data. */

#STEP 1: Data Cleaning Phase

#1a: Changing Table Name
ALTER TABLE uits RENAME TO it_support;

#1b: Changing Column Names
ALTER TABLE it_support CHANGE `Number` ID text;
ALTER TABLE it_support CHANGE `Short Description` ShortDescription text;
ALTER TABLE it_support CHANGE `Assignment Group` AssignmentGroup text;
ALTER TABLE it_support CHANGE `Unit Grouping` UnitGrouping text;
ALTER TABLE it_support CHANGE `Assigned To` AssignedTo text;
ALTER TABLE it_support CHANGE `Opened By` OpenedBy text;
ALTER TABLE it_support CHANGE `Opened` DateOpened text;
ALTER TABLE it_support CHANGE `Task Type` TaskType text;

#1c: Changing Data Types
ALTER TABLE it_support
MODIFY COLUMN DateOpened DATE;

#1d: Updating the Blank Values in the OpenedBy and Navigator columns
UPDATE it_support
SET OpenedBy = 'Unknown'
WHERE OpenedBy = '';

UPDATE it_support
SET Navigator = 'Unknown'
WHERE Navigator = '';

#STEP 2: Data Analysis Phase

#Question 1: How many IT support tickets are there in each State (closed, canceled, etc)?
SELECT State, COUNT(*) AS Total
FROM it_support
GROUP BY State
ORDER BY Total DESC;

#Question 2: How many IT support tickets are there in each Assignment Group?
SELECT AssignmentGroup, COUNT(*) AS Total
FROM it_support
GROUP BY AssignmentGroup
ORDER BY Total DESC;

#Question 3: How many IT support tickets are from the UITS Assignment Group, either Closed or Canceled, and have over 100 cases?
SELECT State, AssignmentGroup, COUNT(*) AS Total
FROM it_support
WHERE AssignmentGroup LIKE '%UITS%' AND State IN ('Closed', 'Canceled')
GROUP BY State, AssignmentGroup
HAVING Total > 100
ORDER BY Total DESC;

#Question 4: What are the most common (4+) reasons a case was opened?
SELECT ShortDescription, COUNT(*) AS Total
FROM it_support
GROUP BY ShortDescription
HAVING Total >= 4
ORDER BY Total DESC;

#Question 5: What's the distribution of the Unit Groupings?
SELECT UnitGrouping, COUNT(*) AS Total
FROM it_support
GROUP BY UnitGrouping
ORDER BY Total DESC;

#Question 6: How many cases were assigned to each customer support representative?
SELECT AssignedTo, COUNT(*) AS Total
FROM it_support
GROUP BY AssignedTo
ORDER BY Total DESC;

#Question 7: When did the most IT support cases occur?
SELECT DateOpened, COUNT(*) AS Total
FROM it_support
GROUP BY DateOpened
ORDER BY Total DESC;

#Question 8: How many cases did each Manager manage?
SELECT Manager, COUNT(*) AS Total
FROM it_support
GROUP BY Manager
ORDER BY COUNT(*) DESC;

#Question 9: Which Employees does each Manager manage?
SELECT DISTINCT is1.Manager, is1.AssignedTo AS Employee
FROM it_support is1
LEFT JOIN it_support is2
ON is1.Manager = is2.AssignedTo
ORDER BY is1.Manager, is1.AssignedTo;

#Question 10: What's the distribution of Navigators for all the cases?
SELECT Navigator, COUNT(*) AS Total
FROM it_support
GROUP BY Navigator
ORDER BY Total DESC;

#Question 11: What's the distribution of each Task Type?
SELECT TaskType, COUNT(*) AS Total
FROM it_support
GROUP BY TaskType
ORDER BY Total DESC;

#Question 12: What's the count of cases for each State and Task Type?
SELECT State, TaskType, COUNT(*) AS Total
FROM it_support
GROUP BY State, TaskType
ORDER BY Total DESC;

#Question 13: What are the total cases by Employee and State, with only employees with 20 or more cases shown?
SELECT AssignedTo, State, COUNT(*) AS Total
FROM it_support
GROUP BY AssignedTo, State
HAVING Total >= 20
ORDER BY Total DESC;