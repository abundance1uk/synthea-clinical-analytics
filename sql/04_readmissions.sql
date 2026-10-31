WITH stays AS (
  SELECT patient, id, start_ts, stop_ts,
         LAG(stop_ts) OVER (PARTITION BY patient ORDER BY start_ts) AS prev_stop
  FROM encounters
  WHERE encounterclass = 'inpatient'
),
flagged AS (
  SELECT *,
         CASE WHEN prev_stop IS NOT NULL
               AND start_ts - prev_stop <= INTERVAL '30 days'
              THEN 1 ELSE 0 END AS is_readmit
  FROM stays
)
SELECT COUNT(*) AS inpatient_stays,
       SUM(is_readmit) AS readmissions,
       ROUND(100.0 * SUM(is_readmit) / COUNT(*), 1) AS readmit_rate_pct
FROM flagged;

WITH stays AS (
  SELECT patient, start_ts, stop_ts,
         LAG(stop_ts) OVER (PARTITION BY patient ORDER BY start_ts) AS prev_stop
  FROM encounters
  WHERE encounterclass = 'inpatient'
)
SELECT COUNT(DISTINCT patient) AS patients_with_inpatient,
       COUNT(prev_stop) AS repeat_stays,
       MIN(start_ts - prev_stop) AS shortest_gap,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY start_ts - prev_stop) AS median_gap
FROM stays;

SELECT COUNT(*) AS inpatient_stays,
       COUNT(*) FILTER (WHERE EXISTS (
         SELECT 1 FROM encounters e2
         WHERE e2.patient = e1.patient
           AND e2.encounterclass IN ('emergency', 'inpatient')
           AND e2.id <> e1.id
           AND e2.start_ts > e1.stop_ts
           AND e2.start_ts <= e1.stop_ts + INTERVAL '30 days'
       )) AS returned_within_30d
FROM encounters e1
WHERE e1.encounterclass = 'inpatient';

SELECT COUNT(*) AS total, COUNT(start_ts) AS has_start, COUNT(stop_ts) AS has_stop
FROM encounters;

CREATE TABLE encounters_raw (
  id TEXT, start_txt TEXT, stop_txt TEXT, patient TEXT,
  organization TEXT, provider TEXT, payer TEXT, encounterclass TEXT,
  code TEXT, description TEXT, base_encounter_cost TEXT,
  total_claim_cost TEXT, payer_coverage TEXT,
  reasoncode TEXT, reasondescription TEXT
);

UPDATE encounters e
SET start_ts = r.start_txt::timestamptz,
    stop_ts  = r.stop_txt::timestamptz
FROM encounters_raw r
WHERE e.id = r.id;

SELECT start_txt, stop_txt
FROM encounters_raw
LIMIT 5;

SELECT COUNT(*) AS total, COUNT(stop_txt) AS has_stop_txt
FROM encounters_raw;

UPDATE encounters e
SET stop_ts = r.stop_txt::timestamptz
FROM encounters_raw r
WHERE e.id = r.id
  AND r.stop_txt IS NOT NULL
  AND r.stop_txt <> '';

SELECT COUNT(*) AS total, COUNT(start_ts) AS has_start, COUNT(stop_ts) AS has_stop
FROM encounters;

drop TABLE encounters_raw;

WITH stays AS (
  SELECT patient, id, start_ts, stop_ts,
         LAG(stop_ts) OVER (PARTITION BY patient ORDER BY start_ts) AS prev_stop
  FROM encounters
  WHERE encounterclass = 'inpatient'
),
flagged AS (
  SELECT *,
         CASE WHEN prev_stop IS NOT NULL
               AND start_ts - prev_stop <= INTERVAL '30 days'
              THEN 1 ELSE 0 END AS is_readmit
  FROM stays
)
SELECT COUNT(*) AS inpatient_stays,
       SUM(is_readmit) AS readmissions,
       ROUND(100.0 * SUM(is_readmit) / COUNT(*), 1) AS readmit_rate_pct
FROM flagged;

SELECT COUNT(*) AS inpatient_stays,
       COUNT(*) FILTER (WHERE EXISTS (
         SELECT 1 FROM encounters e2
         WHERE e2.patient = e1.patient
           AND e2.encounterclass IN ('emergency', 'inpatient')
           AND e2.id <> e1.id
           AND e2.start_ts > e1.stop_ts
           AND e2.start_ts <= e1.stop_ts + INTERVAL '30 days'
       )) AS returned_within_30d
FROM encounters e1
WHERE e1.encounterclass = 'inpatient';

WITH stays AS (
  SELECT patient, start_ts, stop_ts,
         LAG(stop_ts) OVER (PARTITION BY patient ORDER BY start_ts) AS prev_stop
  FROM encounters
  WHERE encounterclass = 'inpatient'
)
SELECT
  COUNT(*) FILTER (WHERE start_ts - prev_stop < INTERVAL '0') AS overlapping,
  COUNT(*) FILTER (WHERE start_ts - prev_stop BETWEEN INTERVAL '0' AND INTERVAL '1 day') AS within_1_day,
  COUNT(*) FILTER (WHERE start_ts - prev_stop <= INTERVAL '30 days') AS within_30_days
FROM stays
WHERE prev_stop IS NOT NULL;

WITH stays AS (
  SELECT patient, id, start_ts, stop_ts,
         LAG(stop_ts) OVER (PARTITION BY patient ORDER BY start_ts) AS prev_stop
  FROM encounters
  WHERE encounterclass = 'inpatient'
),
flagged AS (
  SELECT *,
         CASE WHEN prev_stop IS NOT NULL
               AND start_ts - prev_stop > INTERVAL '1 day'
               AND start_ts - prev_stop <= INTERVAL '30 days'
              THEN 1 ELSE 0 END AS is_readmit
  FROM stays
)
SELECT COUNT(*) AS inpatient_stays,
       SUM(is_readmit) AS readmissions,
       ROUND(100.0 * SUM(is_readmit) / COUNT(*), 1) AS readmit_rate_pct
FROM flagged;