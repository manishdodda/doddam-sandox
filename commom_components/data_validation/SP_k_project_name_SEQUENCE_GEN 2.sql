CREATE OR REPLACE PROCEDURE k_database_name.k_schema_name.SP_k_project_name_SEQUENCE_GEN("P_APPLICATION_NM" VARCHAR(200), "P_STEP" VARCHAR(200))
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
STRICT
EXECUTE AS OWNER
AS '
try
{
	snowflake.execute({ sqlText: "Begin Transaction;"});
	
	var return_value = "";
	
	return_value += "\\n P_APPLICATION_NM: " + P_APPLICATION_NM ;
	
	return_value +="P_STEP: " + P_STEP ;
   
	if (P_STEP == ''OPEN_SEQ'')
	{	

--------if seq needs to be created

		var V_SQ1 = `CREATE OR REPLACE SEQUENCE SEQ_AUDIT_`+ P_APPLICATION_NM +` START = 1 INCREMENT = 1`;
		
		var V_ST1 = snowflake.createStatement( {sqlText: V_SQ1} ).execute();
		
		return_value +="\\nSEQUENCE SUCCESSFULLY CREATED";

	}
	
    if (P_STEP == ''CLOSE_SEQ'')
	{

--------if seq needs to be dropped

		var V_SQ2 = `DROP SEQUENCE IF EXISTS SEQ_AUDIT_`+ P_APPLICATION_NM +``;
		
		var V_ST2 = snowflake.createStatement( {sqlText: V_SQ2} ).execute();
		
		 return_value +="\\nSEQUENCE SUCCESSFULLY DROPED";
         
         snowflake.execute({ sqlText: "COMMIT;"}); 

	}
	
    snowflake.execute({ sqlText: "COMMIT;"}); 
    
	return " SUCCEEDED, Details: " +return_value;  
	
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
}
else
{
	throw "FAILED, Details:" + return_value;
}
';