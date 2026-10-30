#Synthea Clinical Analytics Project

## Objective
Analyse synthetic patient records to measure chronic disease prevalence,
30-day readmissions, and comorbidity patterns using PostgreSQL.

## Project Questions
* Which chronic conditions are most common, and in which age and gender groups?
* What is the 30-day readmission rate, and who is most at risk?
* Which conditions occur together most often?

## Data
- Source: Synthea sample dataset (CSV, Nov 2021), https://synthea.mitre.org/downloads
- Synthetic data only. No real patients.
- Tables used: patients (1,163), encounters (61,459), conditions (76,188)
- Data files are not in this repo. Download from the link above into /data.

## Tools
PostgreSQL, DBeaver, GitHub

## Data quality checks
| Check | Result |
|---|---|
| Encounters with no matching patient | 0 |
| Conditions with no matching patient | 0 |
| Encounters ending before they start | 0 |
| Conditions ending before they start | 0 |
| Patients missing birthdate or gender | 0 |
| Deceased patients | 163 |

Encounter types: wellness 24,038; ambulatory 20,124; outpatient 10,837;
urgent care 2,564; emergency 2,168; inpatient 1,728.

Finding: the conditions table mixes diseases with social findings
(e.g. "Full-time employment (finding)", "Stress (finding)").
Prevalence analysis is limited to diagnoses, not findings.
Readmissions use inpatient encounters.

## Findings
(To be added as the analysis is completed)

---