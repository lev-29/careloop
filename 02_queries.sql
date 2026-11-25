CREATE DATABASE noshowguard;
USE noshowguard;

CREATE TABLE clinics (
  clinic_id VARCHAR(5) PRIMARY KEY,
  clinic_name VARCHAR(40) NOT NULL,
  city VARCHAR(20) NOT NULL,
  tier VARCHAR(10),
  latitude DECIMAL(8,4),
  longitude DECIMAL(8,4),
  temp_c DECIMAL(5,1)
);

CREATE TABLE appointments (
  appointment_id VARCHAR(8) PRIMARY KEY,
  patient_id VARCHAR(8) NOT NULL,
  clinic_id VARCHAR(5) NOT NULL,
  booked_on DATE,
  appt_date DATE,
  age INT,
  gender VARCHAR(1),
  distance_km DECIMAL(5,1),
  fee_inr INT,
  booking_channel VARCHAR(10),
  visit_type VARCHAR(12),
  reminder_sent VARCHAR(3),
  prior_no_shows INT,
  status VARCHAR(10),
  lead_days INT,
  no_show INT,
  FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id)
);

SELECT COUNT(*) FROM clinics;
SELECT COUNT(*) FROM appointments;
SELECT SUM(no_show) FROM appointments;

#INSERT INTO appointments VALUES ('A0001', 'P196', 'C05', '2025-01-22', '2025-01-25', 34, 'F', 12.5, 1500, 'Online', 'Follow-up', 'Yes', 0, 'Completed', 3, 0);
#Error Code: 1062. Duplicate entry 'A0001' for key 'appointments.PRIMARY'

#task 2.2 No-show rate by clinic

SELECT
    c.clinic_name,
    c.city,
    COUNT(*) AS appointments,
    SUM(a.no_show) AS no_shows,
    ROUND(100.0 * SUM(a.no_show) / COUNT(*), 1) AS no_show_pct
FROM appointments AS a
INNER JOIN clinics AS c
    ON a.clinic_id = c.clinic_id
GROUP BY
    c.clinic_id,
    c.clinic_name,
    c.city
HAVING COUNT(*) >= 95
ORDER BY no_show_pct DESC;

#without having

SELECT
    c.clinic_name,
    c.city,
    COUNT(*) AS appointments,
    SUM(a.no_show) AS no_shows,
    ROUND(100.0 * SUM(a.no_show) / COUNT(*), 1) AS no_show_pct
FROM appointments AS a
INNER JOIN clinics AS c
    ON a.clinic_id = c.clinic_id
GROUP BY
    c.clinic_id,
    c.clinic_name,
    c.city
ORDER BY no_show_pct DESC;

#task 2.3 Does booking far ahead matter?

select 
	case 
		when lead_days between 1 and 7 then '1-7'
		when lead_days between 8 and 14 then '8-14'
		when lead_days between 15 and 30 then '15-30'
		when lead_days >= 31 then '31+'
	end as lead_band,
	count(*) as appointments,
    sum(no_show) as no_shows,
    round(100.0 * sum(no_show)/count(*), 2) as no_show_pct
from appointments 
where lead_days >= 1
group by lead_band
order by min(lead_days);


# task 2.4 Month-by-month trend 

with monthly as (
	select
		substr(appt_date, 1, 7) as month,
        count(*) as appointments,
        100.0*sum(no_show)/count(*) as no_show_pct
	from appointments
    group by substr(appt_date, 1, 7)
)
select month, appointments, round(no_show_pct, 2) as no_show_pct,
round(no_show_pct - lag(no_show_pct) over (order by month), 2) as change_p
from monthly
order by month;

# task 2.5 Rank clinics inside each city

WITH clinic_rates AS (
    SELECT
        c.clinic_name AS clinic,
        c.city,
        100.0 * SUM(a.no_show)
            / NULLIF(COUNT(a.appointment_id), 0) AS no_show_pct
    FROM clinics AS c
    LEFT JOIN appointments AS a
        ON c.clinic_id = a.clinic_id
    GROUP BY c.clinic_id, c.clinic_name, c.city
)
SELECT
    clinic,
    city,
    ROUND(no_show_pct, 2) AS no_show_pct,
    RANK() OVER (
        PARTITION BY city
        ORDER BY no_show_pct DESC
    ) AS rank_in_city,
    CASE
        WHEN no_show_pct > (
            SELECT 100.0 * SUM(no_show) / COUNT(*)
            FROM appointments
        ) THEN 'above'
        WHEN no_show_pct < (
            SELECT 100.0 * SUM(no_show) / COUNT(*)
            FROM appointments
        ) THEN 'below'
        WHEN no_show_pct = (
            SELECT 100.0 * SUM(no_show) / COUNT(*)
            FROM appointments
        ) THEN 'equal'
        ELSE NULL
    END AS vs_overall
FROM clinic_rates
ORDER BY city, rank_in_city, clinic;