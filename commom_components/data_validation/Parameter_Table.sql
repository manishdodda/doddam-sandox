create or replace TABLE k_database_name.k_schema_name.k_project_name_PARAMETER_TABLE (
	APPLICATION_ID NUMBER(38,0) autoincrement start 1 increment 1 order,
	SUBJECT_AREA_NAME VARCHAR(200),
	INTERFACE_NAME VARCHAR(200),
	TASK_NAME VARCHAR(200),
	PARAM_NAME VARCHAR(200),
	PARAM_VALUE VARCHAR(200),
	PARAM_DESC VARCHAR(200),
	IS_ACTIVE VARCHAR(4),
	CREATED_DATE DATE,
	CREATED_BY VARCHAR(200),
	LAST_UPDATE_DATE DATE,
	LAST_UPDATED_BY VARCHAR(200),
	COMMENTS VARCHAR(200)
);