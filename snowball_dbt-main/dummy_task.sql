CREATE OR REPLACE TASK my_trial_db.cicd_test.dummy_task
WAREHOUSE = COMPUTE_WH
AFTER my_trial_db.cicd_test.monthly_revenue_task
AS
EXECUTE dbt project DBT_SNOWBALL
ARGS = 'build --select 03_analysis.dummy --target dev';
