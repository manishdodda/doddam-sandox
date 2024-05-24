CREATE OR REPLACE PROCEDURE COMETL_CONTROL_TEST_DB.COMETL_CONTROL_EMEA.SP_PA_BATCH_RUN_DTLS("P_APPLICATION_NAME" VARCHAR(200), "P_SUBJECT_AREA_NAME" VARCHAR(200), "P_STEP" VARCHAR(200))
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
STRICT
EXECUTE AS OWNER
AS '
try 
{
	
    /* snowflake.execute({ sqlText: "Begin Transaction;"});*/
	
	var return_value="";
    
    var V_CONTROL_SCHEMA_NAME = "COMETL_CONTROL_EMEA";
    
-------Selecting Param value from parameter table
	
    	var V_SQ = `SELECT PARAM_VALUE FROM `+V_CONTROL_SCHEMA_NAME+`.PA_PARAMETER_TABLE WHERE PARAM_NAME = ''CONTROL'' AND APPLICATION_ID = (SELECT APPLICATION_ID FROM `+V_CONTROL_SCHEMA_NAME+`.PA_APPLICATION_DTLS WHERE UPPER(APPLICATION_NAME) = UPPER(''`+ P_APPLICATION_NAME +`''))`;
    
    	var V_ST = snowflake.createStatement( {sqlText: V_SQ} ).execute();
    
    	V_ST.next();
    
    	var V_DATABASE_SCHEMA_NAME = V_ST.getColumnValue(1);

-------If bach needs to created 
	
	if (P_STEP == ''BATCH_GEN'')
	{
		return_value +="\\n P_STEP: " + P_STEP ;
	
--------Selecting max batch value from batch table
	
		var V_SQ1 = `SELECT BATCH_ID, LOAD_STATUS FROM `+V_DATABASE_SCHEMA_NAME+`.PA_BATCH_RUN_DTLS WHERE APPLICATION_ID = (SELECT APPLICATION_ID FROM `+V_DATABASE_SCHEMA_NAME+`.PA_APPLICATION_DTLS WHERE UPPER(APPLICATION_NAME) = UPPER(''`+ P_APPLICATION_NAME +`'')) AND BATCH_ID = (SELECT MAX (BATCH_ID) FROM `+V_DATABASE_SCHEMA_NAME+`.PA_BATCH_RUN_DTLS WHERE UPPER(SUBJECT_AREA_NAME) = UPPER(''`+ P_SUBJECT_AREA_NAME +`''))`;
		
		var V_ST1 = snowflake.createStatement( {sqlText: V_SQ1} ).execute();
		
		if(V_ST1.next())
		{
			var MAX_BATCH_ID_VALUE =V_ST1.getColumnValue(1);
			
			var PREV_LOAD_STATUS =V_ST1.getColumnValue(2);
			
			return_value += "\\n BATCH_ID_VALUE: " + MAX_BATCH_ID_VALUE;
			
			return_value += "\\n PREV_LOAD_STATUS: " + PREV_LOAD_STATUS;
			
--------Incrementing batch_id with batch_id+1
			
			var V_BATCH_ID = MAX_BATCH_ID_VALUE+1;
		}
		else
		{
			
			var V_BATCH_ID=1;
		}
		
--------For restartibility purpose, marking the batch as F
		
		var V_SQ2 = `UPDATE `+V_DATABASE_SCHEMA_NAME+`.PA_BATCH_RUN_DTLS SET LOAD_END_TIME = CURRENT_TIMESTAMP(),LOAD_TIME_TAKEN_SECS = datediff(SECOND, LOAD_START_TIME, CURRENT_TIMESTAMP()), LOAD_STATUS=''F'' WHERE UPPER(SUBJECT_AREA_NAME)=UPPER(''`+ P_SUBJECT_AREA_NAME +`'') AND APPLICATION_ID = (SELECT APPLICATION_ID FROM `+V_DATABASE_SCHEMA_NAME+`.PA_APPLICATION_DTLS WHERE UPPER(APPLICATION_NAME)=UPPER(''`+ P_APPLICATION_NAME +`'')) AND LOAD_STATUS=''R''`;
		
		return_value += "\\n UPD_BATCH_DTLS_SQL: "+ V_SQ2;
		
		var V_ST2 = snowflake.createStatement( {sqlText: V_SQ2} ).execute();
		
-------Feching respective application id from application table 
		
		var V_APPLICATION_ID_SQ = `SELECT APPLICATION_ID FROM `+V_DATABASE_SCHEMA_NAME+`.PA_APPLICATION_DTLS WHERE UPPER(APPLICATION_NAME)= UPPER(''`+ P_APPLICATION_NAME +`'')`;
		
		var V_APPLICATION_ID_ST = snowflake.createStatement( {sqlText: V_APPLICATION_ID_SQ} ).execute();
		
		if(V_APPLICATION_ID_ST.next())
		{
			var V_APPLICATION_ID =V_APPLICATION_ID_ST.getColumnValue(1);
			
			return_value += "\\n APPLICATION_ID: " + V_APPLICATION_ID;
		}
		if(V_APPLICATION_ID)
		{

----------Inserting new batch entry 
	
			var V_SQ3 = `INSERT INTO `+V_DATABASE_SCHEMA_NAME+`.PA_BATCH_RUN_DTLS (BATCH_ID,APPLICATION_ID,SUBJECT_AREA_NAME,EXECUTION_DATE,LOAD_START_TIME,LOAD_STATUS) VALUES (`+V_BATCH_ID+`,`+ V_APPLICATION_ID +`,''`+ P_SUBJECT_AREA_NAME +`'',CURRENT_DATE(),CURRENT_TIMESTAMP(),''R'')`;
			 
			return_value += "\\n V_INS_BATCH_DTLS: " + V_SQ3;
			
			var V_ST3 = snowflake.createStatement( {sqlText: V_SQ3} ).execute();

// To create the sequence internally when ever the batch is inserted as in "R" state.
            
             var V_SQ6 = `CALL "SP_PA_SEQUENCE_GEN" (''`+P_APPLICATION_NAME+`'',''OPEN_SEQ'')`;
             
             var V_ST6 = snowflake.createStatement( {sqlText: V_SQ6} ).execute();
             
             V_ST6.next();
             
             return_value += ''\\n SEQUENCE_STATUS: ''+V_ST6.getColumnValue(1);

//
             			
		}
		else
		{
			return_value += ''\\n  GIVEN APPLICATION_NAME IS INVALID \\n'';
			
			throw return_value;
		}	
	}
	
-------If batch needs to be closed

	if (P_STEP == ''BATCH_CLS'')
	{
		var V_SQ4 = `SELECT BATCH_ID FROM `+V_DATABASE_SCHEMA_NAME+`.PA_BATCH_RUN_DTLS WHERE UPPER(SUBJECT_AREA_NAME) = UPPER(''`+ P_SUBJECT_AREA_NAME +`'') AND LOAD_STATUS = ''R''`;
		
		var V_ST4 = snowflake.createStatement( {sqlText: V_SQ4} ).execute();
		if(V_ST4.next())
		{
			V_CURR_BATCH = V_ST4.getColumnValue(1);

// To drop the sequence internally when ever the batch is closed as in "C" state.
            
            var V_SQ7 = `CALL "SP_PA_SEQUENCE_GEN" (''`+P_APPLICATION_NAME+`'',''CLOSE_SEQ'')`;
            
            var V_ST7 = snowflake.createStatement( {sqlText: V_SQ7} ).execute();
            
            V_ST7.next();
            
            return_value += ''\\n SEQUENCE_STATUS: ''+V_ST7.getColumnValue(1);

//

------------Marking batch as Complete C
            
			var V_SQ5 = `UPDATE `+V_DATABASE_SCHEMA_NAME+`.PA_BATCH_RUN_DTLS SET LOAD_END_TIME = CURRENT_TIMESTAMP() ,LOAD_TIME_TAKEN_SECS = datediff (SECOND,LOAD_START_TIME, CURRENT_TIMESTAMP()), LOAD_STATUS = ''C'' WHERE UPPER(SUBJECT_AREA_NAME) = UPPER(''`+ P_SUBJECT_AREA_NAME +`'') AND LOAD_STATUS = ''R''AND BATCH_ID = `+ V_CURR_BATCH +``;
			
            return_value += "\\n V_UPD_BATCH_DTLS2: " + V_SQ5;
            
			var V_ST5 = snowflake.createStatement( {sqlText: V_SQ5} ).execute();
            
           
		}
		else
		{
			return_value+=" NO BATCH IS OPEN FOR THIS INTERFACE. HENCE THE BATCH CAN NOT BE CLOSED ";
			
			throw return_value;
		}
	}
	
	/* snowflake.execute({ sqlText: "COMMIT;"});  */
	
	return "SUCCEEDED, Details: " +return_value;
	
	var check_flg=0;
}
catch (err)  
{
	/* snowflake.execute({ sqlText: "ROLLBACK;"});*/
	
	var check_flg=1;
	
	return_value +=  "\\n  Failed: Code: " + err.code + "\\n  State: " + err.state;
	
	return_value += "\\n  Message: " + err.message;
	
	return_value += "\\nStack Trace:\\n" + err.stackTraceTxt;
  
}
if(check_flg==0)
{
	return "Succeeded" + return_value;
	
}
else
{
	throw "FAILED, Details:" + return_value;
}
';