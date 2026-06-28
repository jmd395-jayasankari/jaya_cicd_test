CREATE OR REPLACE TASK my_trial_db.cicd_test.monthly_revenue_task
WAREHOUSE = COMPUTE_WH
SCHEDULE = 'USING CRON 0 0 1 1 * UTC'
AS
EXECUTE dbt project DBT_SNOWBALL
-- ARGS = 'run --select Snowball_dbt.03_analysis.monthly_revenue --target dev --full-refresh';

-- ARGS = 'build --select 03_analysis --target dev';
ARGS = 'run --target dev --full-refresh';