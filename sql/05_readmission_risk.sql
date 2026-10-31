-- 05_readmission_risk.sql
-- Question: who is most at risk of 30-day readmission?
-- Method: LEAD() flags index stays followed by a readmission (>1 and <=30 days),
--         then rates are compared by age group, gender, and chronic condition count.

### Readmission risk (index stays, n = 1,728)
| Factor | Group | Stays | Readmits | Rate |
|---|---|---|---|---|
| Age | 40-64 | 888 | 217 | 24.4% |
| Age | 65+ | 528 | 94 | 17.8% |
| Age | Under 40 | 312 | 0 | 0.0% |
| Gender | Male | 728 | 153 | 21.0% |
| Gender | Female | 1,000 | 158 | 15.8% |
| Chronic conditions | 0 | 316 | 51 | 16.1% |
| Chronic conditions | 1-2 | 1,115 | 236 | 21.2% |
| Chronic conditions | 3+ | 297 | 24 | 8.1% |

- Readmissions are concentrated in ages 40-64 (24.4%). None occurred
  under age 40.
- Men had a higher readmission rate than women (21.0% vs 15.8%).
- Patients with 3+ chronic conditions had the lowest rate (8.1%),
  which is unexpected and opposite to real-world patterns. This is
  likely an artefact of how Synthea simulates diagnoses and stays.
- Limitations: stays are counted per admission, not per patient, so
  the same patient can appear more than once. Rates are not adjusted
  for other factors. Data is synthetic.