CREATE OR REPLACE TASK my_trial_db.cicd_test."03_analysis_execution"
WAREHOUSE = COMPUTE_WH
SCHEDULE = 'USING CRON 0 0 1 1 * UTC'
AS
EXECUTE dbt project DBT_SNOWBALL
-- ARGS = 'run --target dev --full-refresh';
ARGS = 'build --select 03_analysis --target dev';