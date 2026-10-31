-- 06_comorbidity.sql
-- Question: which chronic conditions occur together most often?
-- Method: self-join of distinct patient-condition pairs, ranked with RANK()

WITH chronic AS (
  SELECT DISTINCT patient, description
  FROM conditions
  WHERE description IN (
    'Hypertension', 'Diabetes', 'Prediabetes', 'Hyperlipidemia',
    'Hypertriglyceridemia (disorder)', 'Metabolic syndrome X (disorder)',
    'Coronary Heart Disease', 'Chronic congestive heart failure (disorder)',
    'Atrial Fibrillation', 'Stroke', 'Osteoporosis (disorder)',
    'Osteoarthritis of knee', 'Seizure disorder', 'Chronic pain'
  )
),
pairs AS (
  SELECT a.description AS condition_a,
         b.description AS condition_b,
         COUNT(*) AS together
  FROM chronic a
  JOIN chronic b
    ON a.patient = b.patient
   AND a.description < b.description
  GROUP BY a.description, b.description
),
totals AS (
  SELECT description, COUNT(*) AS n
  FROM chronic
  GROUP BY description
)
SELECT p.condition_a, p.condition_b, p.together,
       ROUND(100.0 * p.together / ta.n, 1) AS pct_of_a,
       ROUND(100.0 * p.together / tb.n, 1) AS pct_of_b,
       RANK() OVER (ORDER BY p.together DESC) AS pair_rank
FROM pairs p
JOIN totals ta ON ta.description = p.condition_a
JOIN totals tb ON tb.description = p.condition_b
ORDER BY pair_rank
LIMIT 15;