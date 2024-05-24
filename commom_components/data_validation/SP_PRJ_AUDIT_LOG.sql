CREATE OR REPLACE PROCEDURE DB.SCH.SP_PRJ_AUDIT_LOG("P_INTERFACE_NM" VARCHAR(200), "P_TASK_NAME" VARCHAR(200), "P_SUB_AREA_NM" VARCHAR(200), "P_TASK_TYPE" VARCHAR(200), "P_EXECUTION_STATUS" VARCHAR(200), "P_EXCEP_ERR" VARCHAR(200))
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS ' 
try 
{
    snowflake.execute({ sqlText: "Begin Transaction;"});
	
    var v_return_value="";
    
    var V_CONTROL_SCHEMA_NAME = "SCH";
	
    var V_SQ = `SELECT PARAM_VALUE FROM `+V_CONTROL_SCHEMA_NAME+`.PARAMETER_TABLE WHERE PARAM_NAME = ''CONTROL''`;

    var V_ST = snowflake.createStatement( {sqlText: V_SQ} ).execute();

    V_ST.next();

    var V_DATABASE_SCHEMA_NAME = V_ST.getColumnValue(1);
	
    v_return_value += "\\n P_SUB_AREA_NM: " + P_SUB_AREA_NM;
	
    v_return_value += "\\n P_INTERFACE_NM: " + P_INTERFACE_NM;
	
    v_return_value += "\\n P_TASK_NAME: " + P_TASK_NAME;
	
    v_return_value += "\\n P_TASK_TYPE: " + P_TASK_TYPE;
	
    v_return_value += "\\n P_EXECUTION_STATUS: " + P_EXECUTION_STATUS;
	
    v_return_value += "\\n P_EXCEP_ERR: " + P_EXCEP_ERR;
		 
	var V_FETCH_BATCH_SQ = `SELECT BATCH_ID,APPLICATION_ID FROM `+V_DATABASE_SCHEMA_NAME+`.PRJ_BATCH_RUN_DTLS WHERE UPPER(SUBJECT_AREA_NAME) = UPPER(''`+ P_SUB_AREA_NM +`'') AND LOAD_STATUS = ''R''`;
	
	var V_FETCH_BATCH_ST = snowflake.createStatement( {sqlText: V_FETCH_BATCH_SQ} ).execute();
	
	if(V_FETCH_BATCH_ST.next())
	{
		V_BATCH_ID = V_FETCH_BATCH_ST.getColumnValue(1);
		
		v_return_value += "\\n V_BATCH_ID: " + V_BATCH_ID;
		
		var V_APPLICATION_ID = V_FETCH_BATCH_ST.getColumnValue(2);
	}
	else
	{
		v_return_value += " NO BATCH IS OPEN FOR THE INTERFACE. OPEN A NEW BATCH ";
	
		throw v_return_value;
	}
	
	var V_STAT_DESC="";
	
	if ( P_EXECUTION_STATUS == ''R'' )
	{ 
		V_STAT_DESC = "RUNNING";
	}
	else if ( P_EXECUTION_STATUS == ''F'' ) 
	{
		V_STAT_DESC = "FAILED";
	}
	else if ( P_EXECUTION_STATUS == ''C'' )
	{
		V_STAT_DESC = "COMPLETE";
	}
	else 
	{
		V_STAT_DESC="";
	}
	
	v_return_value += "\\n V_STAT_DESC: " + V_STAT_DESC;
	
	
	if ( P_EXECUTION_STATUS == ''R'' )
	{
	 
		var V_UPD_ARCH_RESTRT_DML = `UPDATE `+V_DATABASE_SCHEMA_NAME+`.PRJ_AUDIT_DTLS SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(),EXECUTION_TIME_SECS = datediff(SECOND, EXECUTION_START_TIME, CURRENT_TIMESTAMP()),EXECUTION_STATUS = ''F'', EXECUTION_STATUS_DESC = ''FAILED'', ERROR_DESC = ''MANUAL FAILURE OVERRIDE'' , LAST_UPDATE_DATE = CURRENT_TIMESTAMP()	WHERE UPPER(SUBJECT_AREA_NAME) = UPPER(''` + P_SUB_AREA_NM +`'') AND UPPER(TASK_NAME) = UPPER(''`+ P_TASK_NAME +`'') AND EXECUTION_STATUS = ''R''`;
	
		var V_UPD_ARCH_RESTRT_DML_ST = snowflake.createStatement( {sqlText: V_UPD_ARCH_RESTRT_DML} ).execute();

		var V_FETCH_APPLICATION_NAME_SQ = `SELECT APPLICATION_NAME FROM `+V_DATABASE_SCHEMA_NAME+`.PRJ_APPLICATION_DTLS WHERE APPLICATION_ID = `+V_APPLICATION_ID+``;
		
		var V_FETCH_APPLICATION_NAME_ST = snowflake.createStatement( {sqlText: V_FETCH_APPLICATION_NAME_SQ} ).execute();
	
		if(V_FETCH_APPLICATION_NAME_ST.next())
		{
			V_APPLICATION_NAME = V_FETCH_APPLICATION_NAME_ST.getColumnValue(1);
		}
		var V_SEQ = 0;
		
		var V_SEQ_SQ = `SELECT SEQ_AUDIT_`+ V_APPLICATION_NAME +`.NEXTVAL`;
		
		var V_SEQ_ST = snowflake.createStatement( {sqlText: V_SEQ_SQ} ).execute();
		
		if(V_SEQ_ST.next())
		{
			V_SEQ=V_SEQ_ST.getColumnValue(1);
		}

		var V_INS_AUDIT_DML = `INSERT INTO `+V_DATABASE_SCHEMA_NAME+`.PRJ_AUDIT_DTLS(AUDIT_ID,APPLICATION_ID, BATCH_ID, SUBJECT_AREA_NAME, INTERFACE_NAME, TASK_NAME, TASK_TYPE, EXECUTION_START_TIME, EXECUTION_END_TIME, EXECUTION_TIME_SECS, EXECUTION_STATUS, EXECUTION_STATUS_DESC, ERROR_DESC, CREATED_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_BY)
			VALUES (`+V_SEQ+`,` + V_APPLICATION_ID +`,` + V_BATCH_ID +`,''` + P_SUB_AREA_NM +`'',''`+ P_INTERFACE_NM +`'',''`+ P_TASK_NAME +`'',''`+ P_TASK_TYPE +`'',CURRENT_TIMESTAMP(),NULL,NULL, ''`+P_EXECUTION_STATUS +`'', ''`+ V_STAT_DESC + `'' ,NULL,CURRENT_TIMESTAMP(),''ETL_USER'', CURRENT_TIMESTAMP(),''ETL_USER'' )`;
	
		v_return_value += "\\n V_INS_AUDIT_DML: " + V_INS_AUDIT_DML;
	
		var V_INS_AUDIT_DML_ST = snowflake.createStatement( {sqlText: V_INS_AUDIT_DML} ).execute();
		
	}
	if ( P_EXECUTION_STATUS != ''R'' )
	{
		var output_return_value=P_EXCEP_ERR.replace(/''/g,"''''");

   
		var V_UPD_ARCH_DML = `UPDATE `+V_DATABASE_SCHEMA_NAME+`.PRJ_AUDIT_DTLS SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(),EXECUTION_TIME_SECS = datediff(SECOND, EXECUTION_START_TIME, CURRENT_TIMESTAMP()),EXECUTION_STATUS = ''` + P_EXECUTION_STATUS +`'', EXECUTION_STATUS_DESC = ''` +V_STAT_DESC +`'', ERROR_DESC = DECODE(''` + output_return_value +`'',''undefined'',NULL,''` + output_return_value +`'') , LAST_UPDATE_DATE = CURRENT_TIMESTAMP()	WHERE UPPER(SUBJECT_AREA_NAME) = UPPER(''` + P_SUB_AREA_NM +`'') AND UPPER(TASK_NAME) = UPPER(''`+ P_TASK_NAME +`'') AND BATCH_ID = ` + V_BATCH_ID +` AND EXECUTION_STATUS = ''R''`;
		
		v_return_value += "\\n V_UPD_ARCH_DML: " + V_UPD_ARCH_DML;
		
		var V_UPD_ARCH_DML_ST = snowflake.createStatement( {sqlText: V_UPD_ARCH_DML} ).execute();

	}

	
	snowflake.execute({ sqlText: "COMMIT;"}); 
	
	return "SUCCEEDED, Details: " +v_return_value;
	
	var check_flg=0;
	
	
}
catch (err)  
{
	snowflake.execute({ sqlText: "ROLLBACK;"});

	var check_flg=1;

	v_return_value = v_return_value+  "\\n  Failed: Code: " + err.code + "\\n  State: " + err.state;
	
    v_return_value = v_return_value+ "\\n  Message: " + err.message;
	
    v_return_value = v_return_value+ "\\nStack Trace:\\n" + err.stackTraceTxt;
  
}
if(check_flg==0)
{
	return "Succeeded" + v_return_value;
	
}
else
{
	throw "FAILED, Details:" + v_return_value;
}
';