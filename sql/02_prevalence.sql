-- 02_prevalence.sql
-- Question: which chronic conditions are most common?
-- Method: CTE of distinct patient-condition pairs, divided by all patients
-- Note: prevalence = patients with condition / all 1,163 patients (including deceased)
-- Note: short-term illnesses (sinusitis, bronchitis, sprains) and pregnancy are excluded

-- chronic: one row per patient per chronic condition (DISTINCT avoids double counting)
-- total: number of all patients, used as the denominator

SELECT description, COUNT(DISTINCT patient) AS patients
FROM conditions
WHERE description NOT LIKE '%(finding)%'
  AND description NOT LIKE '%(situation)%'
GROUP BY description
ORDER BY patients DESC
LIMIT 40;

SELECT description, COUNT(DISTINCT patient) AS patients
FROM conditions
WHERE description ILIKE ANY (ARRAY[
  '%asthma%','%copd%','%chronic obstructive%','%kidney disease%',
  '%alzheimer%','%dementia%','%cancer%','%carcinoma%','%depress%',
  '%epilepsy%','%arthritis%','%bronchitis (disorder)%'])
GROUP BY description
ORDER BY patients DESC;

WITH chronic AS (
  SELECT DISTINCT patient, description
  FROM conditions
  WHERE description IN (
    'Hypertension', 'Diabetes', 'Prediabetes', 'Hyperlipidemia',
    'Hypertriglyceridemia (disorder)', 'Metabolic syndrome X (disorder)',
    'Coronary Heart Disease', 'Chronic congestive heart failure (disorder)',
    'Atrial Fibrillation', 'Stroke', 'Osteoporosis (disorder)',
    'Osteoarthritis of knee', 'Seizure disorder', 'Chronic pain',
    'Chronic intractable migraine without aura', 'Chronic sinusitis (disorder)'
  )
),
total AS (
  SELECT COUNT(*) AS n FROM patients
)
SELECT c.description,
       COUNT(*) AS patients,
       ROUND(100.0 * COUNT(*) / t.n, 1) AS prevalence_pct
FROM chronic c
CROSS JOIN total t
GROUP BY c.description, t.n
ORDER BY patients DESC;
