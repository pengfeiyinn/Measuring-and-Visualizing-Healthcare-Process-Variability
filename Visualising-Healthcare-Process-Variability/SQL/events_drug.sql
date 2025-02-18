CREATE TEMP TABLE selected_patients AS 
SELECT DISTINCT
        p.subject_id,
		a.hadm_id
		--a.admittime,
        --a.admission_type,
	    --EXTRACT(YEAR FROM a.admittime) - p.anchor_year + p.anchor_age AS age
    FROM
        mimiciv_hosp.patients p
    JOIN
        mimiciv_hosp.admissions a ON p.subject_id = a.subject_id
    JOIN
        mimiciv_hosp.procedures_icd pr ON a.hadm_id = pr.hadm_id
    WHERE
        EXTRACT(YEAR FROM a.admittime) - p.anchor_year + p.anchor_age  > 18
        AND pr.icd_code IN ('3610','3611','3612','3613','3614','3615','3616','3617','3618','3619','3620')
        AND pr.seq_num = 1
        AND a.admission_type NOT LIKE '%URGENT%' AND a.admission_type NOT LIKE '%EMER%';
-- Query from the temporary table
CREATE TEMP TABLE selected_drugevents AS 
SELECT 
    sp.subject_id,
    pres.drug,
	pres.starttime AS charttime
FROM
    selected_patients sp
JOIN
    mimiciv_hosp.prescriptions pres ON sp.subject_id = pres.subject_id AND sp.hadm_id = pres.hadm_id
;
CREATE TEMP TABLE DrugFrequencyCounts AS 
SELECT 
    drug,
    COUNT(*) AS frequency
FROM 
    selected_drugevents
GROUP BY 
    drug;

-- Determine the frequency threshold for the top 10% most frequent events
CREATE TEMP TABLE Top10PercentDrugCutoff AS
SELECT 
    MIN(frequency) AS cutoff
FROM 
    (SELECT 
        frequency
     FROM 
        DrugFrequencyCounts
     ORDER BY 
        frequency DESC
     LIMIT (SELECT CEIL(COUNT(*) * 0.10) FROM DrugFrequencyCounts)) as top10;

-- Select the actual lab event records for those labels in the top 10%
SELECT 
    sde.subject_id AS PatientID,
    sde.drug AS Events,
    sde.charttime AS StartTime
FROM 
    selected_drugevents sde
JOIN 
    DrugFrequencyCounts dfc ON sde.drug = dfc.drug
WHERE 
    dfc.frequency >= (SELECT cutoff FROM Top10PercentDrugCutoff)
ORDER BY 
    sde.subject_id, sde.charttime;