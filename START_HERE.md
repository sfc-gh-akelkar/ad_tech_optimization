## PatientPoint Predictive Maintenance Demo (Start Here)

This repo is a **single end-to-end demo**. Provision it by running the SQL scripts in numeric order.

### 1) Run SQL in Snowsight (in order)
1. `sql/00_setup.sql`
2. `sql/01_generate_sample_data.sql`
3. `sql/10_curated_analytics_views.sql`
4. `sql/12_cortex_search_kb.sql`
5. `sql/11_semantic_views.sql`
6. `sql/20_anomaly_watchlist.sql`
7. `sql/21_semantic_view_anomaly_watchlist.sql`
8. `sql/30_failure_predictions.sql`
9. `sql/31_semantic_views_predictions.sql`
10. `sql/40_work_orders.sql`
11. `sql/41_semantic_view_work_orders.sql`
12. `sql/50_remote_remediation.sql`
13. `sql/51_semantic_view_remote_remediation.sql`
14. `sql/60_executive_kpis.sql`
15. `sql/61_semantic_view_executive_kpis.sql`
16. `sql/70_cortex_agent.sql`

### 2) Rehearse the customer demo
- **Talk track + wow moments**: `DEMO_GUIDE.md`
- **Challenge → Action → Result mapping**: `FOCUS_FRAMEWORK.md`

### 3) Optional UI
- `streamlit/fleet_monitoring.py` (the Intelligence + Agent demo works without Streamlit)


