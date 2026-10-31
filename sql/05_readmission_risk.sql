-- 05_readmission_risk.sql
-- Question: who is most at risk of 30-day readmission?
-- Method: LEAD() flags index stays followed by a readmission (>1 and <=30 days),
--         then rates are compared by age group, gender, and chronic condition count.

WITH stays AS (
  SELECT patient, id, start_ts, stop_ts,
         LEAD(start_ts) OVER (PARTITION BY patient ORDER BY start_ts) AS next_start
  FROM encounters
  WHERE encounterclass = 'inpatient'
),
flagged AS (
  SELECT *,
         CASE WHEN next_start - stop_ts > INTERVAL '1 day'
               AND next_start - stop_ts <= INTERVAL '30 days'
              THEN 1 ELSE 0 END AS readmitted
  FROM stays
),
chronic AS (
  SELECT patient, description, MIN(start_date) AS dx_date
  FROM conditions
  WHERE description IN (
    'Hypertension', 'Diabetes', 'Prediabetes', 'Hyperlipidemia',
    'Coronary Heart Disease', 'Chronic congestive heart failure (disorder)',
    'Atrial Fibrillation', 'Stroke', 'Osteoporosis (disorder)',
    'Osteoarthritis of knee', 'Seizure disorder', 'Chronic pain'
  )
  GROUP BY patient, description
),
enriched AS (
  SELECT f.id, f.readmitted, p.gender,
    DATE_PART('year', AGE(f.start_ts::date, p.birthdate))::int AS age,
    (SELECT COUNT(*) FROM chronic c
      WHERE c.patient = f.patient AND c.dx_date <= f.stop_ts::date) AS n_chronic
  FROM flagged f
  JOIN patients p ON p.id = f.patient
),
bucketed AS (
  SELECT readmitted, gender,
    CASE WHEN age < 18 THEN '0-17' WHEN age < 40 THEN '18-39'
         WHEN age < 65 THEN '40-64' ELSE '65+' END AS age_group,
    CASE WHEN n_chronic = 0 THEN '0'
         WHEN n_chronic <= 2 THEN '1-2' ELSE '3+' END AS chronic_group
  FROM enriched
)
SELECT 'age_group' AS factor, age_group AS grp, COUNT(*) AS stays,
       SUM(readmitted) AS readmits,
       ROUND(100.0 * SUM(readmitted) / COUNT(*), 1) AS rate_pct
FROM bucketed GROUP BY age_group
UNION ALL
SELECT 'gender', gender, COUNT(*), SUM(readmitted),
       ROUND(100.0 * SUM(readmitted) / COUNT(*), 1)
FROM bucketed GROUP BY gender
UNION ALL
SELECT 'chronic_conditions', chronic_group, COUNT(*), SUM(readmitted),
       ROUND(100.0 * SUM(readmitted) / COUNT(*), 1)
FROM bucketed GROUP BY chronic_group
ORDER BY factor, grp;
