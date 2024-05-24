CREATE OR REPLACE PROCEDURE k_database_name.k_schema_name.SP_k_proj_nm_DATA_VALDTN_UPD("P_SUB_AREA_NM" VARCHAR(16777216), "P_INTERFACE_NM" VARCHAR(16777216), "P_OBJECT_LAYER" VARCHAR(16777216), "P_DATABASE_NM" VARCHAR(16777216))
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
STRICT
EXECUTE AS CALLER
AS '
 try 
	{
		snowflake.execute({ sqlText: "Begin Transaction;"});
		var return_value="";
		var SQ_BATCH_ID = `SELECT BATCH_ID FROM k_database_name.k_schema_name.k_project_name_BATCH_RUN_DTLS WHERE UPPER(SUBJECT_AREA_NAME)=UPPER(''`+ P_SUB_AREA_NM +`'') AND LOAD_STATUS=''R''`;
		//return SQ_BATCH_ID;
		var ST_BATCH_ID = snowflake.createStatement( {sqlText: SQ_BATCH_ID} ).execute();
			if(ST_BATCH_ID.next())
			{
				V_BATCH_ID=ST_BATCH_ID.getColumnValue(1);
				return_value += "\\n V_BATCH_ID: " + V_BATCH_ID;
			}
			else
			{
				return_value+=''No batch_id is open for the interface.''
				throw return_value;
			}
		var SQ_TABLE_NM = `select distinct SRC_TABLENM FROM k_database_name.k_schema_name.DATA_VLDTN_RULE WHERE IS_ACTIVE = ''Y'' AND UPPER(INTERFACE_NM) = UPPER(''`+ P_INTERFACE_NM +`'') AND UPPER(SUB_AREA_NM) = UPPER(''`+ P_SUB_AREA_NM +`'') AND UPPER(OBJECT_LAYER)= UPPER(''`+ P_OBJECT_LAYER +`'')`;
		//return SQ_TABLE_NM;
		var ST_TABLE_NM = snowflake.createStatement( {sqlText: SQ_TABLE_NM} ).execute();
			if(ST_TABLE_NM.next())
			{
				V_TABLE_NAME=ST_TABLE_NM.getColumnValue(1);
				return_value += "\\n V_TABLE_NAME: " + V_TABLE_NAME;
			}
			else
			{
				return_value+="\\n V_TABLE_NAME: No Data Found!";
				throw return_value;
			}
		var SQ_SCHEMA_NM = `SELECT distinct SRC_TABLE_SCHEMA, UNIQUE_KEY FROM k_database_name.k_schema_name.DATA_VLDTN_RULE WHERE  UPPER(INTERFACE_NM)=UPPER(''`+ P_INTERFACE_NM +`'') AND UPPER(SRC_TABLENM) = UPPER(''`+ V_TABLE_NAME +`'')`;
		//return SQ_SCHEMA_NM;
		var ST_SCHEMA_NM = snowflake.createStatement( {sqlText: SQ_SCHEMA_NM} ).execute();
			if(ST_SCHEMA_NM.next())
			{
				V_SRC_TABLE_SCHEMA=ST_SCHEMA_NM.getColumnValue(1);
				return_value += "\\n V_SRC_TABLE_SCHEMA: " + V_SRC_TABLE_SCHEMA;
				V_SRC_UNIQUE_KEY=ST_SCHEMA_NM.getColumnValue(2);
				return_value += "\\n V_SRC_UNIQUE_KEY: " + V_SRC_UNIQUE_KEY;
			}
			else
			{
				return_value+="\\n V_SRC_TABLE_SCHEMA: No Data Found!";
				throw return_value;
				return_value+="\\n V_SRC_UNIQUE_KEY: No Data Found!";
				throw return_value;
			}
		V_INPUT_PARAM = P_INTERFACE_NM+`,`+P_INTERFACE_NM+`,`+P_OBJECT_LAYER;
		return_value += "\\n V_INPUT_PARAM: " + V_INPUT_PARAM;
		var V_TABLE_NM = P_DATABASE_NM+`.`+V_SRC_TABLE_SCHEMA+`.`+V_TABLE_NAME;
		return_value += "\\n V_TABLE_NM: " + V_TABLE_NM;
		
		var SQ_ERR_UPD_STATEMENT_Y = `UPDATE `+ V_TABLE_NM +` SET ERROR_FLAG =''Y'' WHERE `+ V_SRC_UNIQUE_KEY +` in (Select distinct SRC_UNIQUE_KEY from k_database_name.k_schema_name.k_project_name_ERROR_DTLS where BATCH_ID =`+ V_BATCH_ID +` AND UPPER(SUB_AREA_NM)= UPPER(''`+ P_SUB_AREA_NM +`'') AND UPPER(INTERFACE_NM)=UPPER(''`+ P_INTERFACE_NM +`'') AND UPPER(OBJECT_LAYER)=UPPER(''`+ P_OBJECT_LAYER +`'') AND UPPER(RULE_TYPE)=UPPER(''ERROR''))`;
		return_value += "\\n SQ_ERR_UPD_STATEMENT_Y: " + SQ_ERR_UPD_STATEMENT_Y;

		//return SQ_ERR_UPD_STATEMENT_Y;
		var V_ERR_UPD_STATEMENT_Y = snowflake.createStatement( {sqlText: SQ_ERR_UPD_STATEMENT_Y} ).execute();
		var SQ_ERR_UPD_STATEMENT_N = `UPDATE `+ V_TABLE_NM +` SET ERROR_FLAG =''N'' WHERE BATCH_ID =`+ V_BATCH_ID +` AND ERROR_FLAG IS NULL`;
		return_value += "\\n SQ_ERR_UPD_STATEMENT_N: " + SQ_ERR_UPD_STATEMENT_N;
		var V_ERR_UPD_STATEMENT_N = snowflake.createStatement( {sqlText: SQ_ERR_UPD_STATEMENT_N} ).execute();
		
		return_value += "\\n Fetch respective flag update counts";
		var SQ_ERROR_REC_CNT_Y = `select count(*) FROM `+ V_TABLE_NM +` WHERE ERROR_FLAG = ''Y'' AND BATCH_ID = `+ V_BATCH_ID +``;
		//return SQ_ERROR_REC_CNT_Y;
		var ST_ERROR_REC_CNT_Y = snowflake.createStatement( {sqlText: SQ_ERROR_REC_CNT_Y} ).execute();
			if(ST_ERROR_REC_CNT_Y.next())
			{
				V_ERROR_REC_CNT_Y=ST_ERROR_REC_CNT_Y.getColumnValue(1);
				return_value += "\\n V_ERROR_REC_CNT_Y: " + V_ERROR_REC_CNT_Y;
			}
		var SQ_ERROR_REC_CNT_N = `select count(*) FROM `+ V_TABLE_NM +` WHERE ERROR_FLAG = ''N'' AND BATCH_ID = `+ V_BATCH_ID +``;
		//return SQ_ERROR_REC_CNT_N;
		var ST_ERROR_REC_CNT_N = snowflake.createStatement( {sqlText: SQ_ERROR_REC_CNT_N} ).execute();
			if(ST_ERROR_REC_CNT_N.next())
			{
				V_ERROR_REC_CNT_N=ST_ERROR_REC_CNT_N.getColumnValue(1);
				return_value += "\\n V_ERROR_REC_CNT_N: " + V_ERROR_REC_CNT_N;
			}
		var SQ_INSRT_AUDIT_LOG_Y = `Insert into k_database_name.k_schema_name.k_project_name_DATA_VLDTN_ADT_DTLS(BATCH_ID,RULE_ID,SUB_AREA_NM,INTERFACE_NM,OBJECT_LAYER,SP_NM,SP_INPUT_PARM,RECORD_COUNT,RULE_EXEC_STATUS,RULE_EXEC_DESC,OPRATION_TYPE,RULE_EXEC_START_TIME,RULE_EXEC_END_DATE,LAST_MODIFIED_DATE,LAST_MODIFIED_BY) values(`+ V_BATCH_ID +`,NULL,''`+ P_INTERFACE_NM +`'',''`+ P_INTERFACE_NM +`'',''`+ P_OBJECT_LAYER +`'',''SP_STG_UPDATE'',''`+ V_INPUT_PARAM +`'',''`+ V_ERROR_REC_CNT_Y +`'',''C'',''Records with errors updated to Y'',''U'',CURRENT_DATE(),CURRENT_DATE(),CURRENT_DATE(),''k_user'')`;
		//return SQ_INSRT_AUDIT_LOG_Y;
		return_value += "\\n SQ_INSRT_AUDIT_LOG_Y: " + SQ_INSRT_AUDIT_LOG_Y;
		var V_INSRT_AUDIT_LOG_Y = snowflake.createStatement( {sqlText: SQ_INSRT_AUDIT_LOG_Y} ).execute();
		
		
		var SQ_INSRT_AUDIT_LOG_N = `Insert into k_database_name.k_schema_name.k_project_name_DATA_VLDTN_ADT_DTLS(BATCH_ID,RULE_ID,SUB_AREA_NM,INTERFACE_NM,OBJECT_LAYER,SP_NM,SP_INPUT_PARM,RECORD_COUNT,RULE_EXEC_STATUS,RULE_EXEC_DESC,OPRATION_TYPE,RULE_EXEC_START_TIME,RULE_EXEC_END_DATE,LAST_MODIFIED_DATE,LAST_MODIFIED_BY) values(`+ V_BATCH_ID +`,NULL,''`+ P_INTERFACE_NM +`'',''`+ P_INTERFACE_NM +`'',''`+ P_OBJECT_LAYER +`'',''SP_STG_UPDATE'',''`+  V_INPUT_PARAM +`'',''`+ V_ERROR_REC_CNT_N +`'',''C'',''Records with no errors updated to N'',''U'',CURRENT_DATE(),CURRENT_DATE(),CURRENT_DATE(),''k_user'')`;
		//return SQ_INSRT_AUDIT_LOG_N;
		return_value += "\\n SQ_INSRT_AUDIT_LOG_N: " + SQ_INSRT_AUDIT_LOG_N;
		var V_INSRT_AUDIT_LOG_N = snowflake.createStatement( {sqlText: SQ_INSRT_AUDIT_LOG_N} ).execute();
		
		
		snowflake.execute({ sqlText: "COMMIT;"}); 
		return "SUCCEEDED, Details: " +return_value;
		var check_flg=0;
	}
 catch (err)  
	{
      snowflake.execute({ sqlText: "ROLLBACK;"});
	  var check_flg=1;
	  return_value +=  "\\n  Failed: Code: " + err.code + "\\n  State: " + err.state;
      return_value += "\\n  Message: " + err.message;
      return_value += "\\nStack Trace:\\n" + err.stackTraceTxt;
	  
	}
	if(check_flg==0)
		{
			return "Succeeded" + return_value;
			//return return_value + "Succeeded";
		}
		else
		{
		throw "FAILED, Details:" + return_value;
		}
';