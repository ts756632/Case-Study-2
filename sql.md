Check Id length

SELECT Id, LEN(Id)
  FROM project_wellness.dbo.dailyActivity_merged
 WHERE LEN(Id) > 10

 SELECT Id, LEN(Id)
  FROM project_wellness.dbo.sleepDay_merged
 WHERE LEN(Id) > 10


