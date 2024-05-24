create or replace TABLE k_database_name.k_schema_name.k_project_name_AUDIT_DTLS (
	AUDIT_ID NUMBER(38,0),
	APPLICATION_ID NUMBER(38,0),
	BATCH_ID NUMBER(38,0),
	SUBJECT_AREA_NAME VARCHAR(200),
	INTERFACE_NAME VARCHAR(200),
	TASK_NAME VARCHAR(200),
	TASK_TYPE VARCHAR(200),
	EXECUTION_START_TIME TIMESTAMP_NTZ(9),
	EXECUTION_END_TIME TIMESTAMP_NTZ(9),
	EXECUTION_TIME_SECS NUMBER(38,0),
	EXECUTION_STATUS VARCHAR(4),
	EXECUTION_STATUS_DESC VARCHAR(200),
	ERROR_DESC VARCHAR(16777216),
	CREATED_DATE TIMESTAMP_NTZ(9),
	CREATED_BY VARCHAR(200),
	LAST_UPDATE_DATE TIMESTAMP_NTZ(9),
	LAST_UPDATE_BY VARCHAR(200)
);






create or replace TABLE k_database_name.k_schema_name.k_project_name_DATA_VLDTN_ADT_DTLS (
	BATCH_ID NUMBER(38,0),
	RULE_ID NUMBER(38,0),
	SUB_AREA_NM VARCHAR(100),
	INTERFACE_NM VARCHAR(100),
	OBJECT_LAYER VARCHAR(100),
	SP_NM VARCHAR(100),
	SP_INPUT_PARM VARCHAR(1000),
	RECORD_COUNT NUMBER(38,0),
	RULE_EXEC_STATUS VARCHAR(30),
	RULE_EXEC_DESC VARCHAR(1000),
	OPRATION_TYPE VARCHAR(30),
	RULE_EXEC_START_TIME DATE,
	RULE_EXEC_END_DATE DATE,
	LAST_MODIFIED_DATE DATE,
	LAST_MODIFIED_BY VARCHAR(30)
);






create or replace TABLE k_database_name.k_schema_name.k_project_name_DATA_VLDTN_RULE (
	RULE_ID NUMBER(38,0),
	SUB_AREA_NM VARCHAR(100),
	INTERFACE_NM VARCHAR(100),
	OBJECT_LAYER VARCHAR(100),
	SRC_TABLE_SCHEMA VARCHAR(100),
	SRC_TABLENM VARCHAR(100),
	VALIDATION_COLUMN_NM VARCHAR(1000),
	RULE_SQL VARCHAR(1000),
	RULE_DESC VARCHAR(1000),
	RULE_TYPE VARCHAR(100),
	ERROR_MSG VARCHAR(1000),
	IS_ACTIVE VARCHAR(10),
	EFFECTIVE_DATE DATE,
	END_DATE DATE,
	CREATE_DATE DATE,
	CREATED_BY VARCHAR(30),
	LAST_MODIFIED_DATE DATE,
	LAST_MODIFIED_BY VARCHAR(30),
	RUN_ID_FIELD VARCHAR(100),
	UNIQUE_KEY VARCHAR(100),
	FAIL_FLAG VARCHAR(1) DEFAULT 'Y'
);







create or replace TABLE k_database_name.k_schema_name.k_project_name_ERROR_DTLS (
	BATCH_ID NUMBER(38,0),
	RULE_ID NUMBER(38,0),
	RULE_TYPE VARCHAR(100),
	SUB_AREA_NM VARCHAR(100),
	INTERFACE_NM VARCHAR(100),
	OBJECT_LAYER VARCHAR(100),
	SRC_UNIQUE_KEY VARCHAR(100),
	SRC_TABLE_SCHEMA VARCHAR(100),
	SRC_TABLENM VARCHAR(100),
	ERROR_MSG VARCHAR(1000),
	CREATE_DATE DATE,
	CREATED_BY VARCHAR(30)
);


create or replace TABLE k_database_name.k_schema_name.k_project_name_BATCH_RUN_DTLS (
	BATCH_ID NUMBER(38,0),
	APPLICATION_ID NUMBER(38,0),
	SUBJECT_AREA_NAME VARCHAR(200),
	EXECUTION_DATE DATE,
	LOAD_START_TIME TIMESTAMP_NTZ(9),
	LOAD_END_TIME TIMESTAMP_NTZ(9),
	LOAD_TIME_TAKEN_SECS NUMBER(38,0),
	LOAD_STATUS VARCHAR(200)
);




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



create or replace TABLE k_database_name.k_schema_name.k_proj_name_APPLICATION_DTLS (
	APPLICATION_ID NUMBER(38,0) autoincrement start 1 increment 1 order,
	APPLICATION_NAME VARCHAR(200),
	APPLICATION_DESC VARCHAR(200),
	IS_ACTIVE VARCHAR(4),
	CREATED_DATE DATE,
	CREATED_BY VARCHAR(200),
	LAST_MODIFIED_DATE DATE,
	LAST_MODIFIED_BY VARCHAR(200)
)