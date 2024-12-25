/*This is a data analytics project where I analyze a table that contains companies that engaged with the University of Arizona through
6 different categories: Research (R), Talent (T), Campus Engagement (CE), Innovation (INN), Philosophy (PHIL), & Procurement (PROC). 
Data Dictionary:
--There are 6 main categories as described above and these are made up of 2-4 categories. If a column ends in R, T, CE, INN, PHIL, or PROC,
  that means it's a part of one of those categories.
--Columns that start with "t" are the values for that respective category. For example t_proposals_R could be 10 or 1000 for a company.
--Columns that start with "ss" are the score out of 4 based on the value. For example ss_proposals_R would be 1 if t_proposals_R is only 2.
--Columns that have "overall" are the normalized score for each of the 6 categories out of 4. For example, PHIL_overall_ss would be the 
  average of ss_donations_PHIL and ss_dollarsdonated_PHIL.
--The Engagement Score column is the overall score, which is the average of the 6 categories with "overall" in their name out of 10.
*/

#STEP 1: Data Cleaning Phase

#1a: Changing Table Names
ALTER TABLE fake_scorecard_5years RENAME TO scorecard;

#1b: Changing Column Names
ALTER TABLE scorecard CHANGE `OrgName` Company text;

#1c: Adding new column
ALTER TABLE scorecard
ADD COLUMN NumberofEngagements int
AFTER `Year`;

UPDATE scorecard
SET NumberofEngagements =
		(CASE WHEN t_negotiations_R > 0 THEN 1 ELSE 0 END) +
        (CASE WHEN t_awarddollars_R > 0 THEN 1 ELSE 0 END) +
	    (CASE WHEN t_proposals_R > 0 THEN 1 ELSE 0 END) +
        (CASE WHEN t_careerfairs_T > 0 THEN 1 ELSE 0 END) +
        (CASE WHEN t_careerevents_T > 0 THEN 1 ELSE 0 END) +
        (CASE WHEN t_interviews_T > 0 THEN 1 ELSE 0 END) +
        (CASE WHEN t_eventattendees_T > 0 THEN 1 ELSE 0 END) +
        (CASE WHEN t_eventssponsored_CE > 0 THEN 1 ELSE 0 END) +
        (CASE WHEN t_coursementors_CE > 0 THEN 1 ELSE 0 END) +
        (CASE WHEN t_eventattendees_CE > 0 THEN 1 ELSE 0 END) +
        (CASE WHEN t_collab_INN > 0 THEN 1 ELSE 0 END) +
        (CASE WHEN t_partners_INN > 0 THEN 1 ELSE 0 END) +
        (CASE WHEN t_donations_PHIL > 0 THEN 1 ELSE 0 END) +
        (CASE WHEN t_dollarsdonated_PHIL > 0 THEN 1 ELSE 0 END) +
        (CASE WHEN t_contacts_PROC > 0 THEN 1 ELSE 0 END) +
        (CASE WHEN t_contractdollars_PROC > 0 THEN 1 ELSE 0 END);

#STEP 2: Data Analysis Phase

#Question 1: What is the average Engagement Score by company and year?
SELECT Company, ROUND(AVG(EngagementScore),2) AS AverageEngagementScore
FROM scorecard
GROUP BY Company
ORDER BY AverageEngagementScore DESC;

#Question 2: How much money did each Company donate across the 5 years and how does this correlate with the Engagement Score?
SELECT Company, Year, t_awarddollars_R + t_dollarsdonated_PHIL + t_contractdollars_PROC AS TotalDonated,
       ROUND(EngagementScore,2) AS EngagementScore
FROM scorecard
ORDER BY Company, Year, TotalDonated DESC, EngagementScore DESC;

#Question 3: What's the trend of Engagement Score for each company over the 5 years?
SELECT Company, Year, ROUND(EngagementScore,2) AS EngagementScore
FROM scorecard
ORDER BY Company, Year, EngagementScore DESC;

#Question 4: What's the average Engagement Score for the large financial institutions across the 5 years?
SELECT Company, ROUND(AVG(EngagementScore),2) AS AverageEngagementScore
FROM scorecard
WHERE Company IN ("JPMorgan Chase & Co.", "Wells Fargo", "Bank of America", "Goldman Sachs")
GROUP BY Company
ORDER BY AverageEngagementScore DESC;

#Question 5: What's the average Overall Score for each of the 6 items and the Engagement Score for each company across the 5 Years?
SELECT Company, 
	   ROUND(AVG(CE_overall_ss),1) AS AvgCE, 
       ROUND(AVG(PROC_overall_ss),1) AS AvgPROC, 
       ROUND(AVG(INN_overall_ss),1) AS AvgINN, 
       ROUND(AVG(PHIL_overall_ss),1) AS AvgPHIL, 
       ROUND(AVG(T_overall_ss),1) AS AvgT, 
       ROUND(AVG(R_overall_ss),1) AS AvgR,
       ROUND(AVG(EngagementScore),1) AS AvgScore
FROM scorecard
GROUP BY Company
ORDER BY AvgScore DESC;

#Question 6: What are top 10 companies by number of Career Events, and what is their Attendees?
SELECT Company, Year, t_careerevents_T, t_eventattendees_T
FROM scorecard
ORDER BY t_careerevents_T DESC, t_eventattendees_T DESC
LIMIT 10;

#Question 7: Is there a correlation between the number of Donations (PHIL) and Dollars Donated (PHIL)?
SELECT t_donations_PHIL, t_dollarsdonated_PHIL
FROM scorecard
ORDER BY t_donations_PHIL DESC, t_dollarsdonated_PHIL DESC;

#Question 8: Which Companies had an Engagement Score above the average in 2024?
SELECT Company, ROUND(EngagementScore,1)
FROM scorecard
WHERE EngagementScore >= (SELECT AVG(EngagementScore) FROM scorecard) AND Year = 2024
ORDER BY EngagementScore DESC;

/*Question 9: How many total engagements did each company have over the years? 
			  Note: NumberofEngagements refers to the 16 columns that have "t" in front of them. If that column is greater than "0", then 
              that counts as an engagement. Thus, the max amount of engagements a company can have is 16. */
SELECT Company, Year, NumberofEngagements
FROM scorecard
ORDER BY Company, Year;

#Question 10: Which companies have a Number of Engagements that's above average?
SELECT Company, Year, NumberofEngagements
FROM scorecard
WHERE NumberofEngagements >= (SELECT AVG(NumberofEngagements) FROM scorecard)
ORDER BY Company, NumberofEngagements DESC, Year;

#Question 11: What's the various overall scores for the 6 categories for each company?
SELECT Company, 
	   ROUND(CE_overall_ss,1) AS CE_overall_ss, 
       ROUND(PROC_overall_ss,1) AS PROC_overall_ss, 
       ROUND(INN_overall_ss,1) AS INN_overall_ss, 
       ROUND(PHIL_overall_ss,1) AS PHIL_overall_ss, 
       ROUND(T_overall_ss,1) AS T_overall_ss, 
       ROUND(R_overall_ss,1) AS R_overall_ss
FROM scorecard;