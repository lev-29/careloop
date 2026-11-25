[# careloop
From raw bookings to a risk model and an AI-assisted follow-up review
](https://github.com/lev-29/careloop

# CareLoop Clinics — No-Show Guard

From raw bookings to a risk model and an AI-assisted follow-up review across CareLoop Clinics' eight outpatient clinics in six Indian cities. This end-to-end workflow cleans raw booking data, diagnoses when and where missed appointments occur, scores early no-show risk, and structures post-call follow-up notes to help front-desk and call-centre teams fill open doctor slots before the day ends.

## Summary

1. **Data Ingestion & Cleaning (Part 1):** Cleaned raw booking and clinic data into a standardized, non-null table (`appointments_clean.csv`), logged malformed/rejected records (`rejected_rows.json`), enriched clinic records (`clinics_enriched.csv`), and generated SQL load statements (`load_data.sql`).
2. **SQL Analytics (Part 2):** Queried cleaned booking and clinic tables in `02_queries.sql` to pinpoint no-show patterns across clinics, cities, channels, and lead times, documenting duplicate-key constraint behavior.
3. **No-Show Risk Modeling (Part 3):** Trained and evaluated early-warning risk models (`03_model.ipynb`) using pre-appointment booking attributes and exported test-set risk scores (`test_risk_scores.csv`) for proactive outreach.
4. **AI Follow-Up Note Structuring (Part 4):** Extracted structured root causes, confidence scores, summaries, and recommended actions from call-centre follow-up notes (`04_genai.ipynb` and `notes_analysed.csv`) using schema-validated LLM outputs and cross-tabulated reasons against reminder delivery.

## Recommendation

To recover missed outpatient slots ahead of time, CareLoop should trigger targeted pre-visit outreach for bookings flagged above `[THRESHOLD]` by `[CHOSEN_MODEL]` (test ROC-AUC `[AUC_SCORE]`)—starting with `[NUMBER_1]` high-risk bookings in the test set or `[NUMBER_2]` appointments with lead times over `[NUMBER_3]` days—and pair reminder verification with call-centre follow-up workflows addressing the top extracted root causes across `[NUMBER_4]` analysed notes (`[NUMBER_5]` total cleaned bookings). Combining early probability scoring with structured post-call reasons lets staff prioritize high-risk slots while fixing operational bottlenecks behind missed visits.

## Model & Threshold

* **Chosen Model:** `[CHOSEN_MODEL, e.g., Logistic Regression / Random Forest]`
* **Why Chosen:** `[Explain briefly, e.g., strong ROC-AUC performance with interpretable feature behavior and reliable probability calibration for ranking early-stage appointment risk]`
* **Test ROC-AUC:** `[AUC_SCORE, e.g., 0.50, 0.35]`
* **Decision Threshold:** `[THRESHOLD, e.g., 0.35]` (chosen to balance catching high-risk no-shows against front-desk/call-centre outreach capacity)

## Limitations

* **Sample Scope of Follow-Up Notes:** The analysed call-centre notes represent a small subset (`notes_analysed.csv`) rather than every missed appointment across all eight clinics.
* **Observational Data:** Historical booking records show associations rather than proven causal effects, and unrecorded factors (such as sudden illness or local transit disruptions) are not captured.
* **Operational Capacity Trade-offs:** Optimal risk thresholds depend on daily call-centre and front-desk staffing capacity, which may shift across clinics and peak hours.

## Repository Structure

* `data/` — Original three raw source files
* `01_ingest_clean.ipynb` — Ingestion, cleaning, validation, clinic enrichment, and export (Tasks 1.1–1.6)
* `rejected_rows.json` — Rejected raw rows logged during ingestion
* `appointments_clean.csv` — Cleaned booking table
* `clinics_enriched.csv` — Enriched clinic reference table
* `load_data.sql` — SQL load script for cleaned tables
* `02_queries.sql` — Analytical SQL queries and duplicate-key error comment
* `03_model.ipynb` — Model training, evaluation, and threshold selection
* `test_risk_scores.csv` — Test-set no-show risk scores
* `04_genai.ipynb` — Structured follow-up note extraction and analysis (API key removed)
* `notes_analysed.csv` — Structured outputs from call-centre follow-up notes)
