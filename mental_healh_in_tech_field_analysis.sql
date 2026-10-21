CREATE DATABASE mental_health_db;
USE mental_health_db;

CREATE TABLE mental_health_table (
    timestamp VARCHAR(50),
    age INT,
    gender VARCHAR(50),
    country VARCHAR(100),
    state VARCHAR(50),
    self_employed VARCHAR(10),
    family_history VARCHAR(10),
    treatment VARCHAR(10),
    work_interfere VARCHAR(50),
    no_employees VARCHAR(50),
    remote_work VARCHAR(10),
    tech_company VARCHAR(10),
    benefits VARCHAR(50),
    care_options VARCHAR(50),
    wellness_program VARCHAR(50),
    seek_help VARCHAR(50),
    anonymity VARCHAR(50),
    leave_accessibility VARCHAR(50),
    mental_health_consequemental_health_tablence VARCHAR(50),
    phys_health_consequence VARCHAR(50),
    coworkers VARCHAR(50),
    supervisor VARCHAR(50),
    mental_health_interview VARCHAR(50),
    phys_health_interview VARCHAR(50),
    mental_vs_physical VARCHAR(50),
    obs_consequence VARCHAR(10),
    comments TEXT
);

RENAME TABLE mental_health_raw TO mental_health_table;

SELECT * FROM mental_health_db.mental_health_table LIMIT 10;

SELECT MAX(age) FROM mental_health_db.mental_health_table; # 329 year-old and 99999999999 is problem

# Data Cleaning
CREATE TABLE mental_health_db.mental_health_clean AS
SELECT 
# Age outlier 
	CASE 
		WHEN age BETWEEN 18 AND 75 THEN age 
        ELSE NULL 
	END AS age,
    
    CASE 
        WHEN LOWER(TRIM(gender)) IN ('male', 'm', 'male-ish', 'maile', 'mal', 'male (cis)', 'make', 'male ', 'man', 'msle', 'mail', 'malr', 'cis man', 'cis male', 'something kinda male?', 'Male (CIS)', 'ostensibly male, unsure what that really means') THEN 'Male'
        WHEN LOWER(TRIM(gender)) IN ('female', 'f', 'woman', 'female ', 'female (cis)', 'femail', 'cis-female/femme', 'cis female', 'femake', 'male leaning androgynous', 'Trans woman', 'Female (trans)') THEN 'Female'
        ELSE 'Other'
    END AS gender_clean, 
    
    country,
    state,
    self_employed,
    family_history,
    treatment,
    
    # Transfer Yes No into 1 0 values
    CASE WHEN treatment = 'Yes' THEN 1 ELSE 0 END AS treatment_binary,
    
    work_interfere,
    
    # Change the format of column "no_employees"
    CASE 
        WHEN no_employees = '25-Jun' THEN '6-25'
        WHEN no_employees = '5-Jan' THEN '1-5'
        ELSE no_employees 
    END AS no_employees_clean,
    
    remote_work,
    tech_company,
    benefits,
    care_options,
    wellness_program,
    seek_help,
    anonymity,
    leave_accessibility,
    mental_health_consequence,
    coworkers,
    supervisor,
    mental_vs_physical
FROM mental_health_db.mental_health_table;

SELECT gender_clean, no_employees_clean, treatment_binary, age 
FROM mental_health_db.mental_health_clean 
LIMIT 15;

SELECT * FROM mental_health_db.mental_health_clean;

# EDA 
-- Does gender index effect on the mental health treatments looking
SELECT 
    gender_clean,
    COUNT(*) AS total_respondents,
    SUM(treatment_binary) AS total_in_treatment,
    ROUND(AVG(treatment_binary) * 100, 2) AS treatment_rate_pct
FROM mental_health_db.mental_health_clean
GROUP BY gender_clean
ORDER BY treatment_rate_pct DESC;

-- Female is higher than Male in mental health treatments.

SELECT 
    benefits,
    COUNT(*) AS total_employees,
    ROUND(AVG(treatment_binary) * 100, 2) AS treatment_rate_pct
FROM mental_health_db.mental_health_clean
GROUP BY benefits
ORDER BY treatment_rate_pct DESC;
    
SELECT 
    no_employees_clean,
    COUNT(*) AS total_employees,
    ROUND(AVG(treatment_binary) * 100, 2) AS treatment_rate_pct
FROM mental_health_db.mental_health_clean
GROUP BY no_employees_clean
ORDER BY treatment_rate_pct DESC;    

WITH country_stats AS (
    SELECT 
        country,
        COUNT(*) AS total_respondents,
        ROUND(AVG(treatment_binary) * 100, 2) AS treatment_rate_pct
    FROM mental_health_db.mental_health_clean
    GROUP BY country
    HAVING COUNT(*) >= 10
)
SELECT 
    country,
    total_respondents,
    treatment_rate_pct,
    DENSE_RANK() OVER (ORDER BY treatment_rate_pct DESC) AS country_rank
FROM country_stats;
-- Finding: The highest country has the number of people in tech needing mental health treatments. 
-- While the treatment rate is 61.9 over 21 respondents, and France is the lowest with 15.38%.alter

