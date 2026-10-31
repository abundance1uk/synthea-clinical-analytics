# Synthea Clinical Analytics Project

Analysis of synthetic patient records in PostgreSQL: chronic disease
prevalence, 30-day readmissions and comorbidity patterns.

## Summary of key findings
- Cardiometabolic disease dominates: prediabetes (29.3%) and
  hypertension (25.1%) are the most common chronic conditions.
- Prevalence rises with age. Patients aged 65+ have the highest rates
  of hypertension (41.3% in men), hyperlipidemia (about 41%) and
  diabetes (16.0% in men).
- 311 of 1,728 inpatient stays (18.0%) led to a 30-day readmission,
  after excluding 256 overlapping or same-day stays. Without that
  correction the rate would have been 32.8%.
- Readmissions peak at ages 40-64 (24.4%) and are higher in men
  (21.0%) than women (15.8%).
- Diabetes, hypertriglyceridemia and metabolic syndrome almost always
  co-occur, reflecting how Synthea simulates them.

## Questions
1. Which chronic conditions are most common, and in which age and
   gender groups?
2. What is the 30-day readmission rate, and who is most at risk?
3. Which conditions occur together most often?

## Data
- Source: Synthea sample dataset (CSV, Nov 2021),
  https://synthea.mitre.org/downloads
- Synthetic data only. No real patients.
- Tables used: patients (1,163), encounters (61,459), conditions (76,188)
- Data files are not in this repo. Download from the link above into /data.

## Tools
PostgreSQL, DBeaver, Git and GitHub

## Data quality checks
| Check | Result |
|---|---|
| Encounters with no matching patient | 0 |
| Conditions with no matching patient | 0 |
| Encounters ending before they start | 0 |
| Conditions ending before they start | 0 |
| Encounters with missing start or stop time | 0 |
| Patients missing birthdate or gender | 0 |
| Deceased patients | 163 |

Encounter types: wellness 24,038; ambulatory 20,124; outpatient 10,837;
urgent care 2,564; emergency 2,168; inpatient 1,728.

- The conditions table mixes diseases with social findings
  (e.g. "Full-time employment (finding)", "Stress (finding)").
  Prevalence analysis is limited to diagnoses, not findings.
- An import problem initially left encounter end times empty. This was
  found when readmissions returned zero, and fixed by re-importing the
  dates as text and converting them. The missing-time check above was
  added afterwards.

## Analysis 1: Chronic disease prevalence
### Overall (n = 1,163 patients)
| Condition | Patients | Prevalence |
|---|---|---|
| Prediabetes | 341 | 29.3% |
| Hypertension | 292 | 25.1% |
| Chronic sinusitis | 216 | 18.6% |
| Hyperlipidemia | 138 | 11.9% |
| Diabetes | 73 | 6.3% |

- Prevalence = distinct patients with the condition / all patients.
- 6.3% of patients have diabetes but 29.3% have prediabetes. This is
  a large group who could be targeted for prevention.
- Conditions with very few cases (e.g. asthma, depression) were left
  out because the sample was too small.

### By age group and gender (living patients, n = 1,000)
Ages calculated at 1 Nov 2021. Selected conditions shown.

| Condition | Highest-prevalence group | Prevalence |
|---|---|---|
| Hypertension | Males 65+ | 41.3% |
| Diabetes | Males 65+ | 16.0% |
| Prediabetes | Females 65+ | 56.8% |
| Hyperlipidemia | Males 65+ | 41.3% |
| Coronary heart disease | Males 65+ | 13.3% |
| Osteoporosis | Females 65+ | 30.9% |
| Stroke | Males 65+ | 17.3% |

- Most conditions rise with age. Diabetes goes from about 1-2% in
  under-40s to 7-16% in those 40 and over.
- Hyperlipidemia appears only from age 40, and jumps from about 10%
  (40-64) to about 41% (65+).
- In the 65+ group, osteoporosis is 30.9% in females vs 12.0% in
  males, while coronary heart disease (13.3% vs 6.2%) and stroke
  (17.3% vs 7.4%) are higher in males.
- Prediabetes affects about 48% of men aged 40-64 and over half of
  those 65+, a strong target for prevention programmes.
- This analysis uses living patients only, so percentages differ
  slightly from the overall table.

## Analysis 2: 30-day readmissions
- Definition: an inpatient stay starting more than 1 day and up to
  30 days after the same patient's previous inpatient discharge.
- Data check: of 567 stays starting within 30 days of a previous stay,
  118 overlapped it and 138 began within 1 day. These were treated as
  continuations of one stay (e.g. transfers), not readmissions.
- Result: 311 of 1,728 inpatient stays (18.0%) were readmissions.
- A broader all-cause return measure (emergency or inpatient visit
  within 30 days of discharge) found 463 stays (26.8%).

### Readmission risk (index stays, n = 1,728)
| Factor | Group | Stays | Readmits | Rate |
|---|---|---|---|---|
| Age | Under 40 | 312 | 0 | 0.0% |
| Age | 40-64 | 888 | 217 | 24.4% |
| Age | 65+ | 528 | 94 | 17.8% |
| Gender | Female | 1,000 | 158 | 15.8% |
| Gender | Male | 728 | 153 | 21.0% |
| Chronic conditions | 0 | 316 | 51 | 16.1% |
| Chronic conditions | 1-2 | 1,115 | 236 | 21.2% |
| Chronic conditions | 3+ | 297 | 24 | 8.1% |

- Readmissions are concentrated in ages 40-64. None occurred under 40.
- Men had a higher rate than women (21.0% vs 15.8%).
- Patients with 3+ chronic conditions had the lowest rate (8.1%),
  opposite to real-world patterns. This is likely an artefact of how
  Synthea simulates diagnoses and stays.

## Analysis 3: Comorbidity (n = 1,163 patients)
| Condition A | Condition B | Patients | % of A | % of B |
|---|---|---|---|---|
| Hypertension | Prediabetes | 104 | 35.6 | 30.5 |
| Diabetes | Hypertriglyceridemia | 71 | 97.3 | 100.0 |
| Diabetes | Metabolic syndrome X | 68 | 93.2 | 100.0 |
| Hyperlipidemia | Prediabetes | 68 | 49.3 | 19.9 |
| Diabetes | Prediabetes | 50 | 68.5 | 14.7 |

- Method: self-join of distinct patient-condition pairs, each counted
  once. % of A = share of patients with A who also have B.
- Hypertension and prediabetes is the most frequent pair, but both are
  common, so the overlap is only modestly above chance (35.6% vs 29.3%
  overall prediabetes).
- Diabetes, hypertriglyceridemia and metabolic syndrome almost always
  occur together (93-100%). This reflects how Synthea generates them
  as a bundle, not a real-world rate.
- Hyperlipidemia stands out: 49.3% also have prediabetes, well above
  the overall 29.3%.

## How to reproduce
1. Download the Synthea sample CSV (Nov 2021) from
   https://synthea.mitre.org/downloads and put it in /data.
2. Create a PostgreSQL database named `synthea`.
3. Create the tables patients, encounters and conditions, and import
   patients.csv, encounters.csv and conditions.csv in that order.
4. Run the scripts in /sql in numbered order (01 to 06).

## Limitations
- Synthetic data: results reflect how Synthea simulates disease, not
  real populations.
- Some patterns are unrealistic (e.g. hypertension of about 30% in
  ages 18-39, heart disease in children, 3+ chronic conditions linked
  to lower readmission, near-100% overlap of diabetes and metabolic
  syndrome).
- Small groups give unstable percentages.
- Readmissions are counted per stay, not per patient, and rates are
  not adjusted for other factors.
- Comorbidity covers pairs only, not three-way combinations, and
  does not adjust for age.
- Chronic condition lists were chosen by me from the conditions
  present in the data.

## Skills demonstrated
- SQL: CTEs, joins, self-joins, CASE, subqueries, UNION ALL
- Window functions: LAG, LEAD, RANK
- Data quality checking, and fixing a missing-date import problem
- Defining clinical metrics (prevalence, readmission, comorbidity)
- Documenting findings and limitations; Git and GitHub