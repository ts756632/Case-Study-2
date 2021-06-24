
/*
Wellness Data Cleaning and Exploration 
Skills used: Aggregate Functions, Converting Data Types, Windows Functions, CTE's, Temp Tables, Joins, Subqueries
*/

-- Data at a glance

SELECT *
  FROM project_wellness.dbo.dailyActivity_merged

SELECT *
  FROM project_wellness.dbo.sleepDay_merged



-- Check Id length

SELECT Id, LEN(Id)
  FROM project_wellness.dbo.dailyActivity_merged
 WHERE LEN(Id) > 10

 SELECT Id, LEN(Id)
  FROM project_wellness.dbo.sleepDay_merged
 WHERE LEN(Id) > 10


 -- Identify duplicate rows

SELECT Id, ActivityDate, COUNT(*) AS Count
FROM project_wellness.dbo.dailyActivity_merged
GROUP BY Id, ActivityDate
HAVING COUNT(*)>1

SELECT Id, SleepDay, COUNT(*) AS Count
FROM project_wellness.dbo.sleepDay_merged
GROUP BY Id, SleepDay
HAVING COUNT(*)>1



-- Delete duplicate rows in Table SleepDay using the row_number() function with CTE

WITH CTE_SleepDay AS 
(SELECT Id, SleepDay, TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed,           
           ROW_NUMBER() OVER (PARTITION BY Id, SleepDay
           ORDER BY Id, SleepDay) AS DuplicateCount
    FROM project_wellness.dbo.sleepDay_merged
)

SELECT * FROM CTE_SleepDay
WHERE DuplicateCount > 1

WITH CTE_SleepDay AS 
(SELECT Id, SleepDay, TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed,           
           ROW_NUMBER() OVER (PARTITION BY Id, SleepDay
           ORDER BY Id, SleepDay) AS DuplicateCount
    FROM project_wellness.dbo.sleepDay_merged
)
DELETE FROM CTE_SleepDay
WHERE DuplicateCount > 1

SELECT Id, SleepDay, COUNT(*) AS Count
FROM project_wellness.dbo.sleepDay_merged
GROUP BY Id, SleepDay
HAVING COUNT(*)>1


-- Converting Data Types

SELECT CAST (ActivityDate AS date) AS ActivityDate
FROM project_wellness.dbo.dailyActivity_merged

Update project_wellness.dbo.dailyActivity_merged
SET ActivityDate = CAST (ActivityDate AS date)

SELECT CAST (SleepDay AS smalldatetime) AS SleepDay
FROM project_wellness.dbo.sleepDay_merged

Update project_wellness.dbo.sleepDay_merged
SET SleepDay = CAST (SleepDay AS smalldatetime)



ALTER TABLE project_wellness.dbo.sleepDay_merged
Add SleepDayConverted smalldatetime;

Update project_wellness.dbo.sleepDay_merged
SET SleepDayConverted = CONVERT(smalldatetime,SleepDay)


SELECT *
  FROM project_wellness.dbo.sleepDay_merged




-- Average data from all records

 SELECT AVG(TotalSteps) AS Average_Steps, ROUND(AVG(TotalDistance), 2) AS Average_Distance,
		AVG(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes) AS Average_Minutes, 
		AVG(Calories) AS Average_Calories
 FROM project_wellness.dbo.dailyActivity_merged


--  Using subsequery to calculate average

SELECT Id, Average_steps, Average_distance, Average_Calories
 FROM ( 
SELECT Id, AVG(TotalSteps) AS Average_steps, AVG(TotalDistance) AS Average_distance, AVG(VeryActiveDistance) AS Average_VeryActiveDistance,
       AVG(ModeratelyActiveDistance) AS Average_ModeratelyActiveDistance, AVG(LightActiveDistance) AS Average_LightActiveDistance, 
	   AVG(SedentaryActiveDistance) AS Average_SedentaryActiveDistance, AVG(VeryActiveMinutes) AS Average_VeryActiveMinutes, 
	   AVG(FairlyActiveMinutes) AS Average_FairlyActiveMinutes, AVG(LightlyActiveMinutes) AS Average_LightlyActiveMinutes,¡@
	   AVG(SedentaryMinutes) AS Average_SedentaryMinutes, AVG(Calories) AS Average_Calories
  FROM project_wellness.dbo.dailyActivity_merged
 GROUP BY Id
  ) sub

 WHERE Average_steps > 9000
 ORDER BY Average_steps



 -- Subquery in conditional logic - Find the row with maximum total steps

 SELECT *
 FROM project_wellness.dbo.dailyActivity_merged

 WHERE Id = 2320127002 AND 
 TotalSteps = (SELECT Max(TotalSteps)
				FROM project_wellness.dbo.dailyActivity_merged
				WHERE Id = 2320127002
				)  



-- Top 10 total steps

SELECT TOP 10 Id,  SUM(TotalSteps) AS TotalStep
FROM project_wellness.dbo.dailyActivity_merged
GROUP BY Id
ORDER BY 2 DESC 


-- Daily steps 

SELECT Id, CAST(ActivityDate AS date) AS ActivityDate, TotalSteps
FROM project_wellness.dbo.dailyActivity_merged
WHERE Id IN (1503960366, 2320127002, 2873212765)


SELECT Id, VeryActiveMinutes, FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes
FROM project_wellness.dbo.dailyActivity_merged
WHERE Id = 1503960366

-- Combine two tables to understand the relationship

 SELECT Activity.Id, AVG(Activity.TotalSteps) AS Average_Steps, AVG(Activity.TotalDistance) AS Average_Distance, 
		AVG((Activity.VeryActiveMinutes + Activity.FairlyActiveMinutes + Activity.LightlyActiveMinutes + Activity.SedentaryMinutes)/4) AS Average_Minutes, 
		AVG(Activity.Calories) AS Average_Calories, AVG(sleepDay.TotalMinutesAsleep) AS Average_Asleep¡@¡@
  FROM project_wellness.dbo.dailyActivity_merged Activity
  JOIN project_wellness.dbo.sleepDay_merged sleepDay
    ON Activity.Id = sleepDay.Id
 GROUP BY Activity.Id
 ORDER BY 2¡@DESC


 -- Combine two tables to understand the relationship between ActiveMinutes and dif_Asleep

 SELECT Activity.Id, AVG(Activity.VeryActiveMinutes + Activity.FairlyActiveMinutes) AS ActiveMinutes, 
		AVG(sleepDay.TotalMinutesAsleep) AS Average_TotalMinutesAsleep
  FROM project_wellness.dbo.dailyActivity_merged Activity
  JOIN project_wellness.dbo.sleepDay_merged sleepDay
    ON Activity.Id = sleepDay.Id
 GROUP BY Activity.Id
 ORDER BY 2¡@DESC


 --The percentage of each activity

  SELECT 
		 ROUND(SUM(VeryActiveDistance)/SUM(TotalDistance), 4) AS Percentage_VeryActiveDistance,
		 ROUND(SUM(ModeratelyActiveDistance)/SUM(TotalDistance), 4) AS Percentage_ModeratelyActiveDistance,
		 ROUND(SUM(LightActiveDistance)/SUM(TotalDistance), 4) AS Percentage_LightActiveDistance,
		 ROUND(SUM(SedentaryActiveDistance)/SUM(TotalDistance), 4) AS Percentage_SedentaryActiveDistance
    FROM project_wellness.dbo.dailyActivity_merged
 
 


 SELECT id, SUM(TotalDistance) AS Sum_distance, 
		ROUND(SUM(VeryActiveDistance)/SUM(TotalDistance), 4) AS Percentage_VeryActiveDistance,
		ROUND(SUM(ModeratelyActiveDistance)/SUM(TotalDistance), 4) AS Percentage_ModeratelyActiveDistance,
		ROUND(SUM(LightActiveDistance)/SUM(TotalDistance), 4) AS Percentage_LightActiveDistance,
		ROUND(SUM(SedentaryActiveDistance)/SUM(TotalDistance), 4) AS Percentage_SedentaryActiveDistance
   FROM project_wellness.dbo.dailyActivity_merged
 
 GROUP BY Id
 HAVING Id = 2320127002



-- Calculate accumulated steps for each person with partition by statement 

 SELECT CAST(ActivityDate AS date) AS ActivityDate, 
		SUM(TotalSteps) OVER (Partition by Id Order by ActivityDate) AS Accumulated_Steps
 FROM project_wellness.dbo.dailyActivity_merged
 WHERE Id = 2320127002




 -- Using CASE statement to determine activity type

 SELECT Id, AVG(Activity.VeryActiveMinutes + Activity.FairlyActiveMinutes) AS ActiveMinutes, 
		CASE WHEN AVG(Activity.VeryActiveMinutes + Activity.FairlyActiveMinutes) >= 60 THEN 'High Activity'
			 WHEN AVG(Activity.VeryActiveMinutes + Activity.FairlyActiveMinutes) >= 30 THEN 'Median Activity'
			 ELSE 'Low activity' END AS Type

  FROM project_wellness.dbo.dailyActivity_merged Activity
  
 GROUP BY Id
 ORDER BY 2 DESC¡@



 -- Count for each activity type

 WITH CTE_Activiy AS (
  SELECT Id, AVG(Activity.VeryActiveMinutes + Activity.FairlyActiveMinutes) AS ActiveMinutes, 
		CASE WHEN AVG(Activity.VeryActiveMinutes + Activity.FairlyActiveMinutes) >= 60 THEN 'High Activity'
			 WHEN AVG(Activity.VeryActiveMinutes + Activity.FairlyActiveMinutes) >= 30 THEN 'Median Activity'
			 ELSE 'Low activity' END AS Type

		
  FROM project_wellness.dbo.dailyActivity_merged Activity
  
 GROUP BY Id
)

 SELECT Type, COUNT(*) AS Count
 FROM CTE_Activiy
 GROUP BY Type
 ORDER BY 2