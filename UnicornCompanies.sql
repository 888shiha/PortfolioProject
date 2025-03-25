/*This dataset contains private companies with a valuation over $1 billion as of March 2022, including each company's current valuation, 
funding, country of origin, industry, select investors, and the years they were founded and became unicorns.*/

#DATA CLEANING

#Removing the '$' and 'B' from the Valuation column in order to convert the column to an integer
UPDATE unicorn_companies
SET Valuation = SUBSTRING(LEFT(Valuation, LENGTH(Valuation) - 1),2) * 1000000000;

#Converting the Valuation column from TEXT to BIGINT for calculations and storage purposes
ALTER TABLE unicorn_companies
MODIFY COLUMN Valuation BIGINT;

#Converting the Date Joined column from TEXT to DATE for date manipulations
ALTER TABLE unicorn_companies
MODIFY COLUMN `Date Joined` DATE;

#Renaming the Date Joined column
ALTER TABLE unicorn_companies
RENAME COLUMN `Date Joined` TO DateJoined;

#Converting the Industry column from TEXT to VARCHAR(50) for consistency and storage
ALTER TABLE unicorn_companies
MODIFY COLUMN Industry VARCHAR(50);

#Converting the City column from TEXT to VARCHAR(50) for consistency and storage
ALTER TABLE unicorn_companies
MODIFY COLUMN City VARCHAR(50);

#Converting the Country column from TEXT to VARCHAR(50) for consistency and storage
ALTER TABLE unicorn_companies
MODIFY COLUMN Country VARCHAR(50);

#Converting the Continent column from TEXT to VARCHAR(50) for consistency and storage
ALTER TABLE unicorn_companies
MODIFY COLUMN Continent VARCHAR(50);

#Renaming the Year Founded column
ALTER TABLE unicorn_companies
RENAME COLUMN `Year Founded` TO YearFounded;

#Removing the '$', 'B', and 'M' from the Funding column in order to convert the column to an integer
UPDATE unicorn_companies
SET Funding = CASE WHEN Funding LIKE '%B%' THEN SUBSTRING(LEFT(Funding, LENGTH(Funding) - 1),2) * 1000000000
				   WHEN Funding LIKE '%M%' THEN SUBSTRING(LEFT(Funding, LENGTH(Funding) - 1),2) * 1000000
				   WHEN Funding = 'Unknown' THEN NULL
			  END;

#Converting the Funding column from TEXT to BIGINT for calculations and storage purposes
ALTER TABLE unicorn_companies
MODIFY COLUMN Funding BIGINT;

#Renaming the Select Investors column
ALTER TABLE unicorn_companies
RENAME COLUMN `Select Investors` TO SelectInvestors;

#Creating backup in case the original, raw data is needed
CREATE TABLE unicorn_backup;

#Adding an ID column so the table can have a primary key
ALTER TABLE unicorn_companies 
ADD COLUMN ID INT AUTO_INCREMENT PRIMARY KEY FIRST;

#Adding new column that holds the age of the company
ALTER TABLE unicorn_companies
ADD CompanyAge INT;

#Updating the Company Age column to 2025 minus the Year Founded
UPDATE unicorn_companies
SET CompanyAge = 2025 - YearFounded;

#Adding new column that holds the tier of a company
ALTER TABLE unicorn_companies
ADD Tier VARCHAR(50);

#Updating the Tier column with a CASE statement that buckets the company into 3 unicorn levels based on the Valuation
UPDATE unicorn_companies
SET Tier = (CASE
               WHEN Valuation >= 100000000000 THEN 'Hectocorn'
               WHEN Valuation >= 10000000000 THEN 'Decacorn'
			   WHEN Valuation >= 1000000000 THEN 'Unicorn'
		    END);

#Adding new column that holds the funding categorization of a company
ALTER TABLE unicorn_companies
ADD FundingBucket VARCHAR(50);

#Updating the FudingBucket column with a CASE statement that buckets the company into 5 funding levels based on the Funding
UPDATE unicorn_companies
SET FundingBucket = (CASE 
						  WHEN funding < 100000000 THEN 'Small'
					      WHEN funding >= 100000000 AND funding < 300000000 THEN 'Medium'
						  WHEN funding >= 300000000 AND funding < 600000000 THEN 'Large'
						  WHEN funding >= 600000000 AND funding < 1000000000 THEN 'Very Large'
						  ELSE 'Mega'
                      END);

#Adding new column that calculates the Funding to Valuation ratio for each company
ALTER TABLE unicorn_companies
ADD COLUMN FVRatio INT;

#Updating the FVRatio column with the calculation
UPDATE unicorn_companies
SET FVRatio = Funding/Valuation *100;

#Adding new column that calculates the Valuation to Funding ratio for each company
ALTER TABLE unicorn_companies
ADD COLUMN VFRatio INT;

#Updating the VFRatio column with the calculation
UPDATE unicorn_companies
SET VFRatio = Valuation/Funding *100;

#DATA ANALYSIS PART 1--EXPLORATORY DATA ANALYSIS

#Question 1: How many unicorn companies are in this dataset?
SELECT COUNT(Company) AS NumberOfCompanies
FROM unicorn_companies;
#Notes: As of March 2022, there are 1,054 unicorn companies across the world.

#Question 2: What's the minimum, maximum, and average valuation across all companies?
SELECT MIN(Valuation) AS MinimumValuation,
	   MAX(Valuation) AS MaximumValuation,
	   ROUND(AVG(Valuation),0) AS AverageValuation
FROM unicorn_companies;
#Notes: The minimum valuation is $1,000,000,000, the maximum valuation is $180,000,000,000, and the average valuation is $3,483,870,968.

#Question 3: What were the earliest and latest dates that a company reached $1 billion in valuation?
SELECT MIN(DateJoined) AS EarliestDateJoined, 
	   MAX(DateJoined) AS LastestDateJoined
FROM unicorn_companies;
#Notes: The earliest date in which a company reached $1 billion in valuation was July 2nd, 2007 and the latest was April 5th, 2022.

#Question 4: What years did most companies join the 2022 unicorn list?
SELECT YEAR(DateJoined) AS YearJoined, 
       COUNT(*) AS TotalCompanies
FROM unicorn_companies
GROUP BY YearJoined
ORDER BY TotalCompanies DESC;
#Notes: 931 companies joined the 2022 unicorn list in the years 2018 to 2022. 

#Question 5: How many distinct industries, cities, countries, and continents are there?
SELECT COUNT(DISTINCT Industry) AS NumberOfIndustries, 
	   COUNT(DISTINCT City) AS NumberOfCities, 
       COUNT(DISTINCT Country) AS NumberOfCountries,
	   COUNT(DISTINCT Continent) AS NumberOfContinents
FROM unicorn_companies;
#Notes: There are 15 industries, 248 cities, 45 countries, and 6 continents.

#Question 6: How many companies are there for each industry?
SELECT Industry, 
	   COUNT(*) AS TotalCompanies
FROM unicorn_companies
GROUP BY Industry
ORDER BY TotalCompanies DESC;
#Notes: Fintech, Internet software & services, and E-commerce & direct-to-consumer have the most companies, at 222, 203, and 111 respectively.

#Question 7: How many companies are there for each city?
SELECT City, 
	   COUNT(*) AS TotalCompanies
FROM unicorn_companies
GROUP BY City
ORDER BY TotalCompanies DESC;
#Notes: San Francisco, New York, and Beijing have the most companies, at 152, 103, and 63 respectively.

#Question 8: How many companies are there for each country?
SELECT Country, 
	   COUNT(*) AS TotalCompanies
FROM unicorn_companies
GROUP BY Country
ORDER BY TotalCompanies DESC;
#Notes: United States and China have the most companies, at 562 and 173 respectively.

#Question 9: How many companies are there for each continent?
SELECT Continent, 
	   COUNT(*) AS TotalCompanies
FROM unicorn_companies
GROUP BY Continent
ORDER BY TotalCompanies DESC;
#Notes: North America and Asia have the most companies, at 589 and 290 respectively.

#Question 10: What were the earliest and latest founding year?
SELECT MIN(YearFounded) AS EarliestYearFounded, 
	   MAX(YearFounded) AS LatestYearFounded
FROM unicorn_companies;
#Notes: The earliest founding year was 1919 and the latest was 2021.

#Question 11: How many companies are there for each year founded?
SELECT YearFounded, 
	   COUNT(*) AS TotalCompanies
FROM unicorn_companies
GROUP BY YearFounded
ORDER BY TotalCompanies DESC;
#Notes: 2015, 2016, 2014, and 2012 have the most companies, at 149, 110, 108, and 94 respectively.

#Question 12: What's the minimum, maximum, and average funding across all companies?
SELECT MIN(Funding) AS MinimumFunding,
	   MAX(Funding) AS MaximumFunding,
	   ROUND(AVG(Funding),0) AS AverageFunding
FROM unicorn_companies;
#Notes: The minimum funding is $250,000, the maximum funding is $14,000,000,000, and the average funding is $556,710,294.

#Question 13: How many distinct investors are there?
WITH split_investors AS (
    SELECT TRIM(value) AS investor
    FROM unicorn_companies,
    JSON_TABLE(CONCAT('["', REPLACE(SelectInvestors, ', ', '","'), '"]'),
               '$[*]' COLUMNS (value VARCHAR(255) PATH '$')) AS investors
)
SELECT COUNT(DISTINCT investor) AS NumberOfInvestors
FROM split_investors;
#Notes: There are 1,238 investors.

#Question 14: How many companies is each investor invested in?
WITH split_investors AS (
    SELECT TRIM(value) AS investor, 
		   Company
    FROM unicorn_companies,
    JSON_TABLE(CONCAT('["', REPLACE(SelectInvestors, ', ', '","'), '"]'),
               '$[*]' COLUMNS (value VARCHAR(255) PATH '$')) AS investors
)
SELECT investor, 
       COUNT(*) AS TotalCompanies
FROM split_investors
GROUP BY investor
ORDER BY TotalCompanies DESC;
#Notes: Accel, Tiger Global Management, and Andreessen Horowitz have the most companies invested in, at 60, 55, and 53 respectively.

#Question 15: What's the minimum, maximum, and average company age?
SELECT MIN(CompanyAge) AS MinimumCompanyAge,
	   MAX(CompanyAge) AS MaximumCompanyAge,
	   ROUND(AVG(CompanyAge),0) AS AverageCompanyAge
FROM unicorn_companies;
#Notes: The minimum company age is 4 years old, the maximum company age is 106 years old, and the average company age is 12 years old.

#Question 16: How many companies fall under each Tier valuation bucket?
SELECT Tier, 
	   COUNT(*) AS TotalCompanies
FROM unicorn_companies
GROUP BY Tier
ORDER BY TotalCompanies DESC;
#Notes: There are 993 unicorns, 58 decacorns, and 3 hectocorns.

#Question 17: How many companies fall under each Funding Bucket?
SELECT FundingBucket, 
	   COUNT(*) AS TotalCompanies
FROM unicorn_companies
GROUP BY FundingBucket
ORDER BY TotalCompanies DESC;
#Notes: There are 369 medium, 368 large, 157 very large, 114 mega, and 46 small.

#DATA ANALYSIS PART 2--DATA ANALYSIS

#Question 18: Which companies are hectocorns or decacorns in the United States?
SELECT Company, 
	   City, 
       Industry, 
       Tier,
       Valuation
FROM unicorn_companies
WHERE Country = "United States" 
AND Tier IN ("Hectocorn", "Decacorn")
ORDER BY Valuation DESC;
#Notes: There are 33 companies in the United States that are either Hectocorns or Decacorns.

#Question 19: What's the correlation between valuation and funding?
SELECT 
    (COUNT(*) * SUM(CAST(Funding AS DOUBLE) * CAST(Valuation AS DOUBLE)) - 
     SUM(CAST(Funding AS DOUBLE)) * SUM(CAST(Valuation AS DOUBLE))) /
    (SQRT(COUNT(*) * SUM(CAST(Funding AS DOUBLE) * CAST(Funding AS DOUBLE)) - 
          SUM(CAST(Funding AS DOUBLE)) * SUM(CAST(Funding AS DOUBLE))) *
     SQRT(COUNT(*) * SUM(CAST(Valuation AS DOUBLE) * CAST(Valuation AS DOUBLE)) - 
          SUM(CAST(Valuation AS DOUBLE)) * SUM(CAST(Valuation AS DOUBLE)))) 
    AS correlation_coefficient
FROM unicorn_companies;
#Notes: The correlation is approximately 0.6, indicating a moderate to strong positive linear relationship.

#Question 20: How does the average valuation and average funding differ across industries?
SELECT Industry,
	   ROUND(AVG(Valuation),0) AS AverageValuation,
       ROUND(AVG(Funding),0) AS AverageFunding
FROM unicorn_companies
GROUP BY Industry
ORDER BY AverageValuation DESC;
#Notes: Artificial Intelligence has the highest average valuation at $4,604,938,272 and Mobile & Telecommunications has the lowest at $2,270,270,270.
#Notes: Auto & Transportation has the highest average funding at $1,131,419,355 and Internet Software & Services has the lowest at $356,975,369.

#Question 21: What's the ranking of each company based on its valuation and how many companies are ranked last?
WITH ranked AS (
				SELECT Company,
					   Valuation,
		               DENSE_RANK() OVER(ORDER BY Valuation DESC) AS CompanyRank
				FROM unicorn_companies
                )
SELECT *
FROM ranked
WHERE CompanyRank = (SELECT MAX(CompanyRank) FROM ranked);
#Notes: Bytedance is ranked #1, having a valuation of $180 billion. 
#Notes: 461 companies are ranked the lowest, rank 30, and all have a valuation of $1 billion.

#Question 22: Which companies are decacorns and fall under the funding bucket of medium or large?
SELECT Company,
	   Valuation,
       Tier,
       Funding,
       FundingBucket
FROM unicorn_companies
WHERE Tier = 'Decacorn' AND FundingBucket IN ('Medium', 'Large');
#Notes: There are 13 companies that are decacorns and fall under the funding bucket of medium or large.

#Question 23: What's the count of companies and total valuation by city, as well as the top industry in each city?
SELECT City,
	   COUNT(*) AS TotalCompanies,
       ROUND(SUM(Valuation),0) AS TotalValuation,
	   (SELECT Industry 
        FROM unicorn_companies uc2 
        WHERE uc2.City = uc1.City 
        GROUP BY Industry 
        ORDER BY SUM(Valuation) DESC 
        LIMIT 1) AS TopIndustry
FROM unicorn_companies uc1
GROUP BY City
ORDER BY TotalValuation DESC;
#Notes: San Francisco has the highest companies, 152, and the highest valuation, $724,000,000,000. The top industry in this city if Fintech.

#Question 24: What's the average valuation and count of companies by continent?
SELECT Continent,
       ROUND(AVG(Valuation),0) AS AverageValuation,
	   COUNT(*) AS TotalCompanies
FROM unicorn_companies
GROUP BY Continent
ORDER BY AverageValuation DESC;
/*Notes: -Asia, Europe, and North America almost have the same average valuation, at around $3.5 billion.
         -South America and Africa are both the lowest in terms of average valuation, at around $1.6 to $2.2 billion.
         -Oceania is a different and interesting story: the average valuation is $7 billion with only 8 companies, let's explore this.*/
         
#Question 25: Why is the average valuation for Oceania so high?
SELECT Company,
	   Valuation
FROM unicorn_companies
WHERE Continent = 'Oceania'
ORDER BY Valuation DESC;
#Notes: Canva has a valuation of $40 billion, which explains why the average valuation of Oceania is so high.

#Question 26: What's the average funding and count of companies by continent?
SELECT Continent,
       ROUND(AVG(Funding),0) AS AverageFunding,
	   COUNT(*) AS TotalCompanies
FROM unicorn_companies
GROUP BY Continent
ORDER BY AverageFunding DESC;
#Notes: All continents have consisent average funding, between $3.3 and $6.5 billion; there are no outliers.

#Question 27: What's the trend between year founded and average valuation?
SELECT YearFounded,
	   ROUND(AVG(Valuation),0) AS AverageValuation,
	   COUNT(*) AS TotalCompanies
FROM unicorn_companies
GROUP BY YearFounded
ORDER BY YearFounded;
/*Notes: -There are no significant trends between year founded and average valuation. 
		 -One interesting thing is that 1991 and 2002 had very high average valuation, let's explore this.*/

#Question 28: Why did 1991 and 2002 have high average valuations?
SELECT Company, Valuation, YearFounded
FROM unicorn_companies
WHERE YearFounded IN (1991, 2002)
ORDER BY YearFounded ASC, Valuation DESC;
/*Notes: -1991 had a high average valuation because only 1 company was founded that year, which was Epic Games.
	     -2002 had a high average valuation because SpaceX is pulling up the average, which is $100 billion.*/

#Question 29: Which companies have an above average valuation?
SELECT Company, Valuation, Industry
FROM unicorn_companies
WHERE Valuation >= (SELECT AVG(Valuation) FROM unicorn_companies)
ORDER BY Valuation DESC;
#Notes: 238 companies have an above average valuation, which is a valuation greater than $3.48 billion.

#Question 30: How has the valuation of each company changed compared to the previously highest-valued company within the same industry?
SELECT *,
	   PreviousValuation - Valuation AS ValuationDifference
FROM (
	  SELECT Company,
		     Industry,
		     Valuation,
			 LAG(Valuation) OVER(PARTITION BY Industry ORDER BY Valuation DESC) AS PreviousValuation
	  FROM unicorn_companies
      ) AS lagged_table;
#Notes: The results show the valuation difference between a company and the previous high valuation company within the same industry.

#Question 30: How has the funding of each company changed compared to the previously highest-funded company within the same industry?
SELECT *,
	   PreviousFunding - Funding AS FundingDifference
FROM (
	  SELECT Company,
		     Industry,
		     Funding,
			 LAG(Funding) OVER(PARTITION BY Industry ORDER BY Funding DESC) AS PreviousFunding
	  FROM unicorn_companies
      ) AS lagged_table;
#Notes: The results show the funding difference between a company and the previous highest funded company within the same industry.

#Question 31: What's the average FV Ratio and average VF Ratio?
SELECT ROUND(AVG(FVRatio),0) AS AverageFVRatio, 
	   ROUND(AVG(VFRatio),0) AS AverageVFRatio
FROM unicorn_companies;
#Notes: The average FV Ratio is 23% and the average VF Ratio is 3,805%.

#Question 32: What's the average VF and FV ratios by industry?
SELECT Industry,
	   COUNT(*) AS TotalCompanies,
	   ROUND(AVG(VFRatio),0) AS AverageVFRatio,
	   ROUND(AVG(FVRatio),0) AS AverageFVRatio
FROM unicorn_companies
GROUP BY Industry
ORDER BY AverageVFRatio DESC, AverageFVRatio DESC;
#Notes: The average VF Ratio is extremely high for e-commerce and health industries, while the FV Ratio is relatively uniform across all industries.

#Question 33: Why is the average VF ratio so high for e-commerce and health industries?
SELECT Company, 
	   Valuation, 
       Funding, 
       VFRatio
FROM unicorn_companies
WHERE Industry IN ('E-commerce & direct-to-consumer', 'Health')
ORDER BY VFRatio DESC;
#Notes: SSENSE and Otto Bock HealthCare both have very high VF ratio's because their funding is very low, while their valuation is very high.

#Question 34: What's the number of investors per company?
SELECT Company, LENGTH(SelectInvestors) - LENGTH(REPLACE(SelectInvestors, ',', '')) + 1 AS InvestorCount
FROM unicorn_companies
ORDER BY InvestorCount DESC;
#Notes: All companies have been 1 and 4 investors. 

#Question 35: What's the average company age by industry?
SELECT Industry,
	   ROUND(AVG(CompanyAge),1) AS AverageCompanyAge
FROM unicorn_companies
GROUP BY Industry
ORDER BY AverageCompanyAge DESC;
#Notes: The average company age by indsutry is constant across all industries, between 11 to 15 years.