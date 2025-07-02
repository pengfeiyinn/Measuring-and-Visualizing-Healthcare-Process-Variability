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
        AND pr.icd_code IN ('3610','3611','3612','3613','3614','3615','3616','3617','3619')
        AND pr.seq_num = 1
        AND a.admission_type NOT LIKE '%URGENT%' AND a.admission_type NOT LIKE '%EMER%';

CREATE TEMP TABLE selected_serviceevents AS 
SELECT 
	sp.subject_id,
	s.curr_service,
	s.transfertime
FROM
    selected_patients sp
JOIN
    mimiciv_hosp.services s ON sp.subject_id = s.subject_id AND sp.hadm_id = s.hadm_id
;

CREATE TEMP TABLE FrequencyCounts AS 
SELECT 
    curr_service,
    COUNT(*) AS frequency
FROM 
    selected_serviceevents
GROUP BY 
    curr_service;


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


SELECT 
    sse.subject_id AS PatientID,
    sse.curr_service AS Events,
    sse.transfertime AS StartTime
FROM 
    selected_serviceevents sse
JOIN 
    FrequencyCounts fc ON sse.curr_service = fc.curr_service
WHERE 
    fc.frequency >= (SELECT cutoff FROM Top10PercentCutoff)
ORDER BY 
    sse.subject_id, sse.transfertime;
