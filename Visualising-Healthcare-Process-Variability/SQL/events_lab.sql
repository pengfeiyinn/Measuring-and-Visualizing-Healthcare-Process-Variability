CREATE TEMP TABLE selected_patients AS 
SELECT 
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
        AND pr.icd_code IN ('3610','3611','3612','3613','3614','3615','3616','3617','3619')
        AND pr.seq_num = 1
        AND a.admission_type NOT LIKE '%URGENT%' AND a.admission_type NOT LIKE '%EMER%';

CREATE TEMP TABLE selected_labevents AS 
SELECT 
	sp.subject_id,
	dl.label,
	l.itemid,
	l.charttime
FROM
    selected_patients sp
JOIN
    mimiciv_hosp.labevents l ON sp.subject_id = l.subject_id AND sp.hadm_id = l.hadm_id
JOIN 
    mimiciv_hosp.d_labitems dl ON l.itemid = dl.itemid;

CREATE TEMP TABLE FrequencyCounts AS 
SELECT 
    label,
    COUNT(*) AS frequency
FROM 
    selected_labevents
GROUP BY 
    label;


CREATE TEMP TABLE Top10PercentCutoff AS
SELECT 
    MIN(frequency) AS cutoff
FROM 
    (SELECT 
        frequency
     FROM 
        FrequencyCounts
     ORDER BY 
        frequency DESC
     LIMIT (SELECT CEIL(COUNT(*) * 0.10) FROM FrequencyCounts)) as top10;

-- Select top 10% lab events
SELECT 
    sle.subject_id AS PatientID,
    sle.label AS Events,
    sle.charttime AS StartTime
FROM 
    selected_labevents sle
JOIN 
    FrequencyCounts fc ON sle.label = fc.label
WHERE 
    fc.frequency >= (SELECT cutoff FROM Top10PercentCutoff)
ORDER BY 
    sle.subject_id, sle.charttime;
