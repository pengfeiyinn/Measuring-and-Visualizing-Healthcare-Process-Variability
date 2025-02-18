SELECT  
        p.subject_id,
		a.hadm_id,
		--p.anchor_age,
        --p.anchor_year,
		EXTRACT(YEAR FROM a.admittime) - p.anchor_year + p.anchor_age AS age,
		p.gender,
        a.insurance,
		a.language,
		a.race,
		a.marital_status,
		charlson.myocardial_infarct,
		charlson.congestive_heart_failure,
		charlson.peripheral_vascular_disease,
		charlson.cerebrovascular_disease,
		charlson.dementia,
		charlson.chronic_pulmonary_disease,
		charlson.rheumatic_disease,
		charlson.peptic_ulcer_disease,
		charlson.mild_liver_disease,
		charlson.diabetes_without_cc,
		charlson.diabetes_with_cc,
		charlson.paraplegia,
		charlson.renal_disease,
		charlson.malignant_cancer,
		charlson.severe_liver_disease,
		charlson.metastatic_solid_tumor,
		charlson.aids,
		charlson.charlson_comorbidity_index AS CCI,
		a.hospital_expire_flag AS in_hospital_mortality,
		CASE
		    WHEN p.dod IS NOT NULL AND EXTRACT(DAY FROM (p.dod - a.dischtime)) < 30 THEN 1
			ELSE 0
		END AS died_within_30_days,
		EXTRACT(EPOCH FROM (a.dischtime - a.admittime)) / 3600 AS length_of_stay
    FROM
        mimiciv_hosp.patients p
    JOIN
        mimiciv_hosp.admissions a ON p.subject_id = a.subject_id
    JOIN
        mimiciv_hosp.procedures_icd pr ON a.hadm_id = pr.hadm_id
	JOIN 
	    mimiciv_derived.charlson charlson ON a.hadm_id = charlson.hadm_id
    WHERE
        EXTRACT(YEAR FROM a.admittime) - p.anchor_year + p.anchor_age  > 18
        AND pr.icd_code IN ('3610','3611','3612','3613','3614','3615','3616','3617','3618','3619','3620')
        AND pr.seq_num = 1
        AND a.admission_type NOT LIKE '%URGENT%' AND a.admission_type NOT LIKE '%EMER%'
ORDER BY subject_id;