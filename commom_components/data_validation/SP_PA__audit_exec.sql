CREATE OR REPLACE PROCEDURE COMETL_CONTROL_TEST_DB.COMETL_CONTROL_EMEA.SP_PA__AUDIT_EXEC_DTLS("P_AUDIT_ID" FLOAT, "P_SUBJECT_AREA_NAME" VARCHAR(200), "P_REF_ID" VARCHAR(200), "P_SUB_PROCESS_NM" VARCHAR(200), "P_PROCESS_TYPE" VARCHAR(200), "P_EXECUTION_STATUS" VARCHAR(4), "P_SRC_RECORD_COUNT" FLOAT, "P_TGT_RECORD_COUNT" FLOAT, "P_ERROR_DESC" VARCHAR(200), "P_CREATED_BY" VARCHAR(200))
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS ' 
try 
{
    snowflake.execute({ sqlText: "Begin Transaction;"});
	
    var v_return_value="";
    
    var V_CONTROL_SCHEMA_NAME = "COMETL_CONTROL_EMEA";
	
-------Fetching param value from parameter table	
    
	var V_SQ = `SELECT PARAM_VALUE FROM `+V_CONTROL_SCHEMA_NAME+`.PA__PARAMETER_TABLE WHERE PARAM_NAME = ''CONTROL''`;

    var V_ST = snowflake.createStatement( {sqlText: V_SQ} ).execute();

    V_ST.next();

    var V_DATABASE_SCHEMA_NAME = V_ST.getColumnValue(1);
    
    v_return_value += "\\n P_AUDIT_ID: " + P_AUDIT_ID;
    
    v_return_value += "\\n P_SUBJECT_AREA_NAME: " + P_SUBJECT_AREA_NAME;
    
    v_return_value += "\\n P_REF_ID: " + "''"+ P_REF_ID+"''";
    
    v_return_value += "\\n P_SUB_PROCESS_NM: " + P_SUB_PROCESS_NM;
    
    v_return_value += "\\n P_PROCESS_TYPE: " + P_PROCESS_TYPE;
    
    v_return_value += "\\n P_EXECUTION_STATUS: " + P_EXECUTION_STATUS;
    
    v_return_value += "\\n P_SRC_RECORD_COUNT: " + P_SRC_RECORD_COUNT;
    
    v_return_value += "\\n P_TGT_RECORD_COUNT: " + P_TGT_RECORD_COUNT;
    
    v_return_value += "\\n P_ERROR_DESC: " + P_ERROR_DESC;
    
    v_return_value += "\\n P_CREATED_BY: " + P_CREATED_BY;
	
-------Fetching Active audit entry
	
	var V_FETCH_BATCH_SQ = `SELECT BATCH_ID,APPLICATION_ID FROM `+V_DATABASE_SCHEMA_NAME+`.PA__AUDIT_DTLS WHERE AUDIT_ID = `+ P_AUDIT_ID +` AND UPPER(SUBJECT_AREA_NAME) = UPPER(''`+P_SUBJECT_AREA_NAME+`'') AND EXECUTION_STATUS = ''R''`;

	var V_FETCH_BATCH_ST = snowflake.createStatement( {sqlText: V_FETCH_BATCH_SQ} ).execute();

	if(V_FETCH_BATCH_ST.next())
	{
	
--------If active audit entry found	
	
		var V_BATCH_ID = V_FETCH_BATCH_ST.getColumnValue(1);
		
		v_return_value += "\\n V_BATCH_ID: " + V_BATCH_ID;
		
		var V_APPLICATION_ID = V_FETCH_BATCH_ST.getColumnValue(2);
		
		v_return_value += "\\n V_APPLICATION_ID: " + V_APPLICATION_ID;
	}
	else
	{
	
-----If active audit entry not found 	
	
		v_return_value += "\\n NO AUDIT IS OPEN FOR THE INTERFACE. OPEN A NEW AUDIT. \\n";
		
		throw v_return_value;
	}
	
-----------Marking different Execution status description in V_STAT_DESC	
	
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
        if(P_REF_ID == undefined)
        {
		
-----------Fetching audit_id,APPLICATION_ID,BATCH_ID for active EXECUTION_STATUS and null REF_ID
		
            var V_SELECT_AUDITEXEC_SQ = `SELECT AUDIT_ID,APPLICATION_ID,BATCH_ID FROM `+V_DATABASE_SCHEMA_NAME+`.PA__AUDIT_EXEC_DTLS WHERE  UPPER(PROCESS_TYPE)= UPPER(''`+ P_PROCESS_TYPE +`'') AND  UPPER(SUB_PROCESS_NM)= UPPER(''`+ P_SUB_PROCESS_NM +`'') AND REF_ID is null AND  EXECUTION_STATUS=''R''`;
		
        }
        else
        {
		
-----------Fetching audit_id,APPLICATION_ID,BATCH_ID for active EXECUTION_STATUS and not null REF_ID
		
            var V_SELECT_AUDITEXEC_SQ = `SELECT AUDIT_ID,APPLICATION_ID,BATCH_ID FROM `+V_DATABASE_SCHEMA_NAME+`.PA__AUDIT_EXEC_DTLS WHERE  UPPER(PROCESS_TYPE)= UPPER(''`+ P_PROCESS_TYPE +`'') AND  UPPER(SUB_PROCESS_NM)= UPPER(''`+ P_SUB_PROCESS_NM +`'') AND UPPER(REF_ID)=UPPER(''`+P_REF_ID+`'') AND  EXECUTION_STATUS=''R''`;
		
        }
		v_return_value += "\\n V_SELECT_AUDITEXEC_SQ \\n" + V_SELECT_AUDITEXEC_SQ;
		
		var V_SELECT_AUDITEXEC_ST = snowflake.createStatement( {sqlText: V_SELECT_AUDITEXEC_SQ} ).execute();
		
		if(V_SELECT_AUDITEXEC_ST.next())
		{
			var V_AUDIT_ID = V_SELECT_AUDITEXEC_ST.getColumnValue(1);

			var V_AUDIT_EXEC_APPLICATION_ID = V_SELECT_AUDITEXEC_ST.getColumnValue(2);

			var V_AUDIT_EXEC_BATCH_ID = V_SELECT_AUDITEXEC_ST.getColumnValue(3);

---------Fetching execution status from AUDIT_DTLS

			var V_SELECT_AUDIT_SQ = `SELECT EXECUTION_STATUS FROM `+V_DATABASE_SCHEMA_NAME+`.PA__AUDIT_DTLS WHERE  AUDIT_ID = `+ V_AUDIT_ID +` AND  APPLICATION_ID =`+ V_AUDIT_EXEC_APPLICATION_ID +`   AND  UPPER(SUBJECT_AREA_NAME) = UPPER(''`+P_SUBJECT_AREA_NAME+`'') AND BATCH_ID =`+ V_AUDIT_EXEC_BATCH_ID +``;
			
			var V_SELECT_AUDIT_ST = snowflake.createStatement( {sqlText: V_SELECT_AUDIT_SQ} ).execute();
			
			if (V_SELECT_AUDIT_ST.next())
			{
				var V_EXECUTION_STATUS = V_SELECT_AUDIT_ST.getColumnValue(1);
				
				if(V_EXECUTION_STATUS == ''R'')
				{
					v_return_value += "\\n AUDIT IS IN RUNNING STATE. CAN NOT OVERRIDE \\n";
					
					throw v_return_value;
				}
				else if(V_EXECUTION_STATUS == ''F'') 
				{
					if(P_REF_ID== undefined)
					{
					
-------------updating  audit entry for failed status and null ref_id
					
                        var V_UPD_ARCH_RESTRT_DML = `UPDATE `+V_DATABASE_SCHEMA_NAME+`.PA__AUDIT_EXEC_DTLS SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(),EXECUTION_TIME_SECS = datediff(SECOND, EXECUTION_START_TIME, CURRENT_TIMESTAMP()), SRC_RECORD_COUNT = `+P_SRC_RECORD_COUNT+`
						,EXECUTION_STATUS = ''F'',EXECUTION_STATUS_DESC = ''FAILED'', ERROR_DESC = ''MANUAL FAILED OVERRIDE'' ,LAST_UPDATE_DATE = CURRENT_TIMESTAMP() WHERE UPPER(PROCESS_TYPE) = UPPER(''`+ P_PROCESS_TYPE +`'') AND  UPPER(SUB_PROCESS_NM) = UPPER(''`+ P_SUB_PROCESS_NM +`'') AND REF_ID IS NULL  AND EXECUTION_STATUS = ''R''`;
		
					}
					else
					{
						
-------------updating audit entry for failed status and not  null ref_id
						
						var V_UPD_ARCH_RESTRT_DML = `UPDATE `+V_DATABASE_SCHEMA_NAME+`.PA__AUDIT_EXEC_DTLS SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(),EXECUTION_TIME_SECS = datediff(SECOND, EXECUTION_START_TIME, CURRENT_TIMESTAMP()), SRC_RECORD_COUNT = `+P_SRC_RECORD_COUNT+`
						,EXECUTION_STATUS = ''F'',EXECUTION_STATUS_DESC = ''FAILED'', ERROR_DESC = ''MANUAL FAILED OVERRIDE'' ,LAST_UPDATE_DATE = CURRENT_TIMESTAMP() WHERE UPPER(PROCESS_TYPE) = UPPER(''`+ P_PROCESS_TYPE +`'') AND  UPPER(SUB_PROCESS_NM) = UPPER(''`+ P_SUB_PROCESS_NM +`'') AND UPPER(REF_ID) = UPPER(''`+P_REF_ID+`'') AND EXECUTION_STATUS = ''R''`;
		
					}
					
					var V_UPD_ARCH_RESTRT_DML_ST = snowflake.createStatement( {sqlText: V_UPD_ARCH_RESTRT_DML} ).execute();
					
--------------inserting entry into  AUDIT_EXEC_DTLS
					
					var V_INS_AUDIT_DML =`INSERT INTO `+V_DATABASE_SCHEMA_NAME+`.PA__AUDIT_EXEC_DTLS(AUDIT_ID,APPLICATION_ID,BATCH_ID,REF_ID,SUB_PROCESS_NM,PROCESS_TYPE,EXECUTION_START_TIME,EXECUTION_STATUS,EXECUTION_STATUS_DESC,CREATED_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_BY) 
						VALUES (`+P_AUDIT_ID+`,` + V_APPLICATION_ID +`,` + V_BATCH_ID +`,DECODE(''`+P_REF_ID+`'',''undefined'',NULL,''`+P_REF_ID+`''),''`+ P_SUB_PROCESS_NM +`'',''`+ P_PROCESS_TYPE +`'',CURRENT_TIMESTAMP(), ''`+P_EXECUTION_STATUS +`'', ''`+ V_STAT_DESC + `'' ,CURRENT_TIMESTAMP(),''`+P_CREATED_BY+`'', CURRENT_TIMESTAMP(),''`+P_CREATED_BY+`'' )`;
					
					v_return_value += " \\n V_INS_AUDIT_DML: " + V_INS_AUDIT_DML;
					
					var V_INS_AUDIT_DML_ST = snowflake.createStatement( {sqlText: V_INS_AUDIT_DML} ).execute();
				}
				else
				{
					//nothing to execute 
				}
			}
		  
			
		}
		else
		{
		
-------inserting into AUDIT_EXEC_DTLS for the very first entry
		
			var V_INS_AUDIT_DML =`INSERT INTO `+V_DATABASE_SCHEMA_NAME+`.PA__AUDIT_EXEC_DTLS(AUDIT_ID,APPLICATION_ID,BATCH_ID,REF_ID,SUB_PROCESS_NM,PROCESS_TYPE,EXECUTION_START_TIME,EXECUTION_STATUS,EXECUTION_STATUS_DESC,CREATED_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_BY) 
			 VALUES (`+P_AUDIT_ID+`,` + V_APPLICATION_ID +`,` + V_BATCH_ID +`,DECODE(''`+P_REF_ID+`'',''undefined'',NULL,''`+P_REF_ID+`''),''`+ P_SUB_PROCESS_NM +`'',''`+ P_PROCESS_TYPE +`'',CURRENT_TIMESTAMP(), ''`+P_EXECUTION_STATUS +`'', ''`+ V_STAT_DESC + `'' ,CURRENT_TIMESTAMP(),''`+P_CREATED_BY+`'', CURRENT_TIMESTAMP(),''`+P_CREATED_BY+`'' )`;
			
			v_return_value += "\\n V_INS_AUDIT_DML: " + V_INS_AUDIT_DML;
			
			var V_INS_AUDIT_DML_ST = snowflake.createStatement( {sqlText: V_INS_AUDIT_DML} ).execute();
		}
	}
	else if ( P_EXECUTION_STATUS == ''F'' )
	{
		var output_return_value=P_ERROR_DESC.replace(/''/g,"''''");
		if(P_REF_ID== undefined)
		{
		
------Marking entry as F for failed status coming from parameter where ref_id null
		
			var V_UPD_ARCH_DML = `UPDATE `+V_DATABASE_SCHEMA_NAME+`.PA__AUDIT_EXEC_DTLS SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(),EXECUTION_TIME_SECS = datediff(SECOND, EXECUTION_START_TIME, CURRENT_TIMESTAMP())
			,EXECUTION_STATUS = ''`+P_EXECUTION_STATUS+`'',EXECUTION_STATUS_DESC=''`+V_STAT_DESC+`'', ERROR_DESC = DECODE(''` + output_return_value +`'',''undefined'',NULL,''` + output_return_value +`'') ,LAST_UPDATE_DATE = CURRENT_TIMESTAMP(), SRC_RECORD_COUNT = `+P_SRC_RECORD_COUNT+` 
			WHERE UPPER(PROCESS_TYPE) = UPPER(''`+ P_PROCESS_TYPE +`'') AND  UPPER(SUB_PROCESS_NM) = UPPER(''`+ P_SUB_PROCESS_NM +`'')  AND BATCH_ID = `+ V_BATCH_ID +` AND AUDIT_ID = `+P_AUDIT_ID+`AND EXECUTION_STATUS = ''R''
			AND REF_ID is null`;
		}
		else
		{
		
------Marking entry as F for failed status coming from parameter where ref_id  not null
		
			var V_UPD_ARCH_DML = `UPDATE `+V_DATABASE_SCHEMA_NAME+`.PA__AUDIT_EXEC_DTLS SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(),EXECUTION_TIME_SECS = datediff(SECOND, EXECUTION_START_TIME, CURRENT_TIMESTAMP())
			,EXECUTION_STATUS = ''`+P_EXECUTION_STATUS+`'',EXECUTION_STATUS_DESC=''`+V_STAT_DESC+`'', ERROR_DESC = DECODE(''` + output_return_value +`'',''undefined'',NULL,''` + output_return_value +`'') ,LAST_UPDATE_DATE = CURRENT_TIMESTAMP(), SRC_RECORD_COUNT = `+P_SRC_RECORD_COUNT+`
			WHERE UPPER(PROCESS_TYPE) = UPPER(''`+ P_PROCESS_TYPE +`'') AND  UPPER(SUB_PROCESS_NM) = UPPER(''`+ P_SUB_PROCESS_NM +`'')  AND BATCH_ID = `+ V_BATCH_ID +` AND AUDIT_ID = `+P_AUDIT_ID+`AND EXECUTION_STATUS = ''R''
			AND UPPER(REF_ID) = UPPER(''`+P_REF_ID+`'')`;
		
		}
		
			
		v_return_value += "\\n V_UPD_ARCH_DML: " + V_UPD_ARCH_DML;
		
		var V_UPD_ARCH_DML_ST = snowflake.createStatement( {sqlText: V_UPD_ARCH_DML} ).execute();
	
	}
	else if ( P_EXECUTION_STATUS == ''C'' )
	{
		var output_return_value=P_ERROR_DESC.replace(/''/g,"''''");
		if(P_REF_ID==undefined)
		{
		
-----Marking entry as C for Complete status coming from parameterwhere ref_id is null
		
			var V_UPD_ARCH_DML = `UPDATE `+V_DATABASE_SCHEMA_NAME+`.PA__AUDIT_EXEC_DTLS SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(),EXECUTION_TIME_SECS = datediff(SECOND, EXECUTION_START_TIME, CURRENT_TIMESTAMP()),SRC_RECORD_COUNT = `+P_SRC_RECORD_COUNT+`,TGT_RECORD_COUNT = `+P_TGT_RECORD_COUNT+`
			  ,EXECUTION_STATUS = ''`+P_EXECUTION_STATUS+`'',EXECUTION_STATUS_DESC = ''`+V_STAT_DESC+`'', ERROR_DESC = DECODE(''` + output_return_value +`'',''undefined'',NULL,''` + output_return_value +`'') ,LAST_UPDATE_DATE = CURRENT_TIMESTAMP(),DIFF_RECORD_COUNT =  `+P_TGT_RECORD_COUNT+` - `+P_SRC_RECORD_COUNT+` 
			  WHERE UPPER(PROCESS_TYPE) = UPPER(''`+ P_PROCESS_TYPE +`'') AND  UPPER(SUB_PROCESS_NM) = UPPER(''`+ P_SUB_PROCESS_NM +`'')  AND BATCH_ID = `+ V_BATCH_ID +` AND AUDIT_ID = `+P_AUDIT_ID+`AND EXECUTION_STATUS = ''R''
			  AND REF_ID is null`;
		}
		else
		{
		
-----Marking entry as C for Complete status coming from parameterwhere ref_id is not null
		
			var V_UPD_ARCH_DML = `UPDATE `+V_DATABASE_SCHEMA_NAME+`.PA__AUDIT_EXEC_DTLS SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(),EXECUTION_TIME_SECS = datediff(SECOND, EXECUTION_START_TIME, CURRENT_TIMESTAMP()),SRC_RECORD_COUNT = `+P_SRC_RECORD_COUNT+`,TGT_RECORD_COUNT = `+P_TGT_RECORD_COUNT+`
			  ,EXECUTION_STATUS = ''`+P_EXECUTION_STATUS+`'',EXECUTION_STATUS_DESC = ''`+V_STAT_DESC+`'', ERROR_DESC = DECODE(''` + output_return_value +`'',''undefined'',NULL,''` + output_return_value +`'') ,LAST_UPDATE_DATE = CURRENT_TIMESTAMP(),DIFF_RECORD_COUNT =  `+P_TGT_RECORD_COUNT+` - `+P_SRC_RECORD_COUNT+` 
			  WHERE UPPER(PROCESS_TYPE) = UPPER(''`+ P_PROCESS_TYPE +`'') AND  UPPER(SUB_PROCESS_NM) = UPPER(''`+ P_SUB_PROCESS_NM +`'')  AND BATCH_ID = `+ V_BATCH_ID +` AND AUDIT_ID = `+P_AUDIT_ID+`AND EXECUTION_STATUS = ''R''
			  AND UPPER(REF_ID) = UPPER(''`+P_REF_ID+`'')`;
		}
		
	  
		v_return_value += "\\n V_UPD_ARCH_DML: " + V_UPD_ARCH_DML;
	   
		var V_UPD_ARCH_DML_ST = snowflake.createStatement( {sqlText: V_UPD_ARCH_DML} ).execute();

	}
	else{
		//nothing to execute
	}
	
	snowflake.execute({ sqlText: "COMMIT;"}); 
	
	return "SUCCEEDED, Details: " +v_return_value;
	var check_flg=0;
}
catch (err)  
{
	snowflake.execute({ sqlText: "ROLLBACK;"});
	
	var check_flg=1;
	v_return_value = v_return_value+  "\\n  FAILED: Code: " + err.code + "\\n  State: " + err.state;
    
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