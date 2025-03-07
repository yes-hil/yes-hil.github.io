SELECT * FROM `heart failure prediction`.heart_failure_staging;

select *
from heart_failure_staging
where HeartDisease = 1;
-- 508 affected by heart disease --


select HeartDisease, avg(Cholesterol) as AvgChoresterol 
from heart_failure_staging
group by HeartDisease;
-- completes the avg of patients experiencing Heart Disease -- 


SELECT 
    Sex,
    COUNT(*) AS Total_Patients,
    COUNT(CASE WHEN HeartDisease = 1 THEN 1 END) AS HeartDisease_Patients,
    ROUND(100.0 * COUNT(CASE WHEN HeartDisease = 1 THEN 1 END) / COUNT(*), 2) AS HeartDisease_Percentage,
    COUNT(CASE WHEN HeartDisease = 0 THEN 1 END) AS NoHeartDiseaseCount,
    ROUND(100.0 * COUNT(CASE WHEN HeartDisease = 0 THEN 1 END) / COUNT(*), 2) AS NoHeartDisease_Percentage
FROM heart_failure_staging
GROUP BY Sex;
-- gives the total number of affected/unaffected HD patients and the percent of them -- 


select 
	sex,
	avg(cholesterol) as AvgCholesterol,
   HeartDisease
from heart_failure_staging
group by HeartDisease, sex
order by 3;
-- avg of cholesterol of affected pts based on sex -- 
 
 
select 
	ChestPainType,
    count(case when HeartDisease = 1 THEN 1 End) as HeartDiseaseSymptom
from heart_failure_staging
group by ChestPainType
ORDER BY HeartDiseaseSymptom DESC;  
-- most common chest pain --


SELECT 
    ST_Slope, 
    COUNT(*) AS TotalHeartDiseasePatients
FROM heart_failure_staging
WHERE HeartDisease = 1
GROUP BY ST_Slope;
-- ST level based on heart disease patients --


select 
	case
		when restingBP BETWEEN 0 and 95 then '80-95'
        when restingBP BETWEEN 96 and 110 then '96-110'
        when restingBP BETWEEN 111 and 130 then '111-130'
        when restingBP BETWEEN 131 and 150 then '131-150'
        when restingBP > 150 then '150+'
    end as restingBP_ranges,
	count(*) as totalHeartDiseasePatients
from heart_failure_staging
where HeartDisease = 1
group by RestingBP_ranges
order by totalHeartDiseasePatients asc;
-- resting BP ranges for patients affected by Heart Disease --


select 
	ROUND(100.0 * COUNT(CASE WHEN fastingBS = 1 THEN 1 END) / COUNT(*), 2) as BS_Percentage,
    count(*) as totalHeartDiseasePatients
from heart_failure_staging
where HeartDisease = 1;
-- percentage of fasted high blood sugar within heart disease patients --


SELECT 
    AVG(MaxHR) AS avg_MaxHR
FROM heart_failure_staging
WHERE HeartDisease = 1;
-- avg heart rate for Heart Disease patients-- 

SELECT 
    CASE
        WHEN MaxHR BETWEEN 60 AND 100 THEN '60-100'
        WHEN MaxHR BETWEEN 101 AND 130 THEN '101-130'
        WHEN MaxHR BETWEEN 131 AND 160 THEN '131-160'
        WHEN MaxHR > 160 THEN '161+'
    END AS MaxHR_Range,
    COUNT(*) AS totalHeartDiseasePatients
FROM heart_failure_staging
WHERE HeartDisease = 1
GROUP BY MaxHR_Range
ORDER BY MaxHR_Range;
-- the correlation with Max heart rate and Heart Disease --

SELECT 
    ExerciseAngina,
    AVG(MaxHR) AS Avg_MaxHR
FROM heart_failure_staging
GROUP BY ExerciseAngina;
-- patients who reported exercise induced angina had an avg heart rate of 125bpm --


select
	count(*) as total_patients,
	ST_Slope,
    avg(Oldpeak) as avg_oldpeak,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM heart_failure_staging), 2) AS Percentage
from heart_failure_staging
group by ST_Slope
order by percentage;
-- down/higher ST slope/Oldpeak results in more severe ischemia when exercising -- 

SELECT 
    ST_Slope,
    ROUND(AVG(Oldpeak), 2) AS Avg_Oldpeak,
    COUNT(CASE WHEN HeartDisease = 1 THEN 1 END) AS HeartDiseasePatients,
    COUNT(CASE WHEN HeartDisease = 0 THEN 1 END) AS NoHeartDiseasePatients,
    ROUND(100.0 * COUNT(CASE WHEN HeartDisease = 1 THEN 1 END) / COUNT(*), 1) AS HeartDisease_Percentage
FROM 
    heart_failure_staging
GROUP BY 
    ST_Slope
ORDER BY 
    Avg_Oldpeak DESC;
-- correlating Oldpeak with Heart Disease Diagnosis --


select distinct age
from heart_failure_staging;


SELECT 
    CASE
        WHEN age BETWEEN 28 AND 35 THEN '28-35'
        WHEN age BETWEEN 36 AND 50 THEN '36-50'
        WHEN age BETWEEN 51 AND 64 THEN '51-64'
        WHEN age > 64 THEN '65+'
    END AS age_groups,
    COUNT(*) AS TotalPatients,
    COUNT(CASE WHEN HeartDisease = 1 THEN 1 END) AS HeartDiseasePatients,
    ROUND(100.0 * COUNT(CASE WHEN HeartDisease = 1 THEN 1 END) / COUNT(*), 2) AS HeartDisease_Risk_Percentage,
    ROUND(AVG(FastingBS), 2) AS AvgFastingBS,
    ROUND(AVG(RestingBP), 2) AS AvgRestingBP,
    ROUND(AVG(MaxHR), 2) AS AvgMaxHR
FROM heart_failure_staging
GROUP BY age_groups
ORDER BY age_groups;
-- risk of heart disease based on blood sugar, restingHR -- 


    
SELECT 
    RestingECG,
    COUNT(*) AS TotalPatients,
    COUNT(CASE WHEN HeartDisease = 1 THEN 1 END) AS HeartDiseasePatients,
    ROUND(100.0 * COUNT(CASE WHEN HeartDisease = 1 THEN 1 END) / COUNT(*), 2) AS HeartDisease_Risk_Percentage
FROM heart_failure_staging
GROUP BY RestingECG
ORDER BY HeartDisease_Risk_Percentage DESC;
-- resting ecg correlation w heart disease --


SELECT *
FROM (
    SELECT 
        Age, 
        Cholesterol, 
        RANK() OVER (
            PARTITION BY 
                CASE 
                    WHEN Age BETWEEN 28 AND 35 THEN '28-35'
                    WHEN Age BETWEEN 36 AND 50 THEN '36-50'
                    WHEN Age BETWEEN 51 AND 64 THEN '51-64'
                    ELSE '65+' 
                END
            ORDER BY Cholesterol DESC
        ) AS Cholesterol_Rank
    FROM heart_failure_staging
) ranked
WHERE Cholesterol_Rank <= 5; 
-- rank of cholesterol based on age groups 2-5 --


WITH HighRiskPatients AS (
    SELECT 
        HeartDisease,
        CASE WHEN Cholesterol > 200 THEN 1 ELSE 0 END AS HighCholesterol,
        CASE WHEN RestingBP > 130 THEN 1 ELSE 0 END AS HighBloodPressure,
        CASE WHEN ExerciseAngina = 'Y' THEN 1 ELSE 0 END AS ExerciseAngina,
        CASE WHEN FastingBS = 1 THEN 1 ELSE 0 END AS HighBloodSugar,
        CASE WHEN ST_Slope IN ('Flat', 'Down') THEN 1 ELSE 0 END AS AbnormalSTSlope
    FROM heart_failure_staging
    WHERE HeartDisease = 1
)

SELECT 
    'High Cholesterol' AS RiskFactor, 
    COUNT(*) AS Frequency
FROM HighRiskPatients
WHERE HighCholesterol = 1
UNION ALL
SELECT 
    'High Blood Pressure' AS RiskFactor, 
    COUNT(*) AS Frequency
FROM HighRiskPatients
WHERE HighBloodPressure = 1
UNION ALL
SELECT 
    'Exercise Angina' AS RiskFactor, 
    COUNT(*) AS Frequency
FROM HighRiskPatients
WHERE ExerciseAngina = 1
UNION ALL
SELECT 
    'High Blood Sugar' AS RiskFactor, 
    COUNT(*) AS Frequency
FROM HighRiskPatients
WHERE HighBloodSugar = 1
UNION ALL
SELECT 
    'Abnormal ST Slope' AS RiskFactor, 
    COUNT(*) AS Frequency
FROM HighRiskPatients
WHERE AbnormalSTSlope = 1
ORDER BY Frequency DESC
LIMIT 5;
-- risk factors for heart disease based on columns --

  
CREATE INDEX idx_heart_disease ON heart_failure_staging (HeartDisease);
CREATE INDEX idx_age ON heart_failure_staging (Age);
CREATE INDEX idx_cholesterol ON heart_failure_staging (Cholesterol);



