# Measuring and Visualizing Healthcare Process Variability

## Overview

Understanding factors that contribute to clinical variability in patient care is critical, as unwarranted variability can lead to increased adverse events and prolonged hospital stays. Determining when this variability becomes excessive can be a step in optimizing patient outcomes and healthcare efficiency. This study presents a standardized way to measure and visualize variability in clinical processes and measure its impact on patient-relevant outcomes.

## Dataset

This cohort study uses [MIMIC-IV](https://physionet.org/content/mimiciv/2.2/), a dataset collecting electronic health records of the Beth Israel Deaconess Medical Center in the United States. We focused on adult patients who underwent elective coronary bypass surgery, generating 847 patient observations. Demographics factors such as age, race, insurance type, and the Charlson Comorbidity Index(CCI) were recorded.

## Data Extraction

Before running the notebooks, you need to query data using SQL scripts in the `SQL/` folder:

- `patient.sql`: Extracts the patient cohort, including demographics.
- `events_lab.sql`: Extracts laboratory event data for the cohort.
- `events_drug.sql`: Extracts medication-related event data.
- `events_service.sql`: Extracts hospital-related service events under which a patient is hospitalized.
- `charlson.sql`: Computes Charlson Comorbidity Index(CCI).
- `age.sql`: Extracts patient age from MIMIC-IV data.

## Project Structure

This repository is organized as follows:

- `Visualizing-Healthcare-Process-Variability/`: Main folder:
  - `SQL/`: SQL scripts for data extraction from MIMIC-IV dataset.
  - `No_chopped/`: Code analysis using full patient traces.
  - `chopped_oneday/`: Code analysis using only the first 24 hours of each patient's traces.
  - `chopped_twoday/`: Code analysis using only the first 48 hours of each patient's traces.
  - `chopped_threeday/`: Code analysis using only the first 72 hours of each patient's traces.

