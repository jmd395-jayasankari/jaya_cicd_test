CREATE OR REPLACE TASK my_trial_db.cicd_test."03_analysis_execution"
WAREHOUSE = COMPUTE_WH
AS
EXECUTE dbt project DBT_SNOWBALL
ARGS = 'build --select models/03_analysis --target dev';