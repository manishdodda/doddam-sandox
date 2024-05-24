CREATE OR REPLACE PROCEDURE COMETL_CONTROL_TEST_DB.COMETL_CONTROL_EMEA.SP_DATA_VALDTN_INS("P_SUB_AREA_NM" VARCHAR(16777216), "P_INTERFACE_NM" VARCHAR(16777216), "P_OBJECT_LAYER" VARCHAR(16777216), "P_DATABASE_NM" VARCHAR(16777216))
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
STRICT
EXECUTE AS CALLER
AS '
 try 
	{
		snowflake.execute({ sqlText: "Begin Transaction;"});
		var v_return_value="";
-----------Initiating audit sp
		
		var V_AUDIT_INS_SQ = `CALL COMETL_CONTROL_TEST_DB.COMETL_CONTROL_EMEA.SP_AUDIT_LOG(''`+P_INTERFACE_NM+`'',''SP_DATA_VALDTN_INS'',''`+P_SUB_AREA_NM+`'',''Procedure'', ''R'',''NA'' )`; 
		
        v_return_value += "\\n V_AUDIT_INS_SQ: " + V_AUDIT_INS_SQ;
        var V_AUDIT_INS_ST = snowflake.createStatement( {sqlText: V_AUDIT_INS_SQ} ).execute();
		
-----------Fetching Batch details
		
		var V_SQ1 = `SELECT BATCH_ID FROM COMETL_CONTROL_TEST_DB.COMETL_CONTROL_EMEA.BATCH_RUN_DTLS WHERE UPPER(SUBJECT_AREA_NAME)=UPPER(''`+ P_SUB_AREA_NM +`'') 
		AND LOAD_STATUS = ''R''`;
		var V_ST1 = snowflake.createStatement( {sqlText: V_SQ1} ).execute();
-----------If open batch found
		if(V_ST1.next())
		{
			var V_BATCH_ID = V_ST1.getColumnValue(1);
			v_return_value += "\\nV_BATCH_ID: " + V_BATCH_ID;
		}
		else
------------If no open batch found
		{
			v_return_value +=''No batch is open for the interface. Open a new batch.''
			throw v_return_value;
		}
		
----------Fetching only those RULES which have IS_ACTIVE as Y
		
		var V_SQ2 = `SELECT DISTINCT SRC_TABLE_SCHEMA, SRC_TABLENM, RUN_ID_FIELD FROM COMETL_CONTROL_TEST_DB.COMETL_CONTROL_EMEA.DATA_VLDTN_RULE WHERE IS_ACTIVE = ''Y''
            AND UPPER(INTERFACE_NM) = UPPER(''` + P_INTERFACE_NM + `'')
            AND UPPER(SUB_AREA_NM) = UPPER(''` + P_SUB_AREA_NM + `'')
            AND UPPER(OBJECT_LAYER)= UPPER(''` + P_OBJECT_LAYER + `'')`;
		v_return_value += "\\n V_SQ2: " + V_SQ2;
		var V_ST2 = snowflake.createStatement( {sqlText: V_SQ2} ).execute();
		if(V_ST2.next())
		{
			var V_SRC_TABLE_SCHEMA = V_ST2.getColumnValue(1);
			v_return_value += "\\n V_SRC_TABLE_SCHEMA: " + V_SRC_TABLE_SCHEMA;
			var V_SRC_TABLENM = V_ST2.getColumnValue(2);
			v_return_value += "\\n V_SRC_TABLENM: " + V_SRC_TABLENM;
			var V_RUN_ID_FIELD = V_ST2.getColumnValue(3);
			v_return_value += "\\n V_RUN_ID_FIELD: " + V_RUN_ID_FIELD;
			
		}
		var V_TABLE_NM = P_DATABASE_NM+`.`+V_SRC_TABLE_SCHEMA+`.`+V_SRC_TABLENM;
		v_return_value += "\\n V_TABLE_NM: " + V_TABLE_NM;

-----------For restartibility Purpose, setting all eror flags to N
		
		if(V_RUN_ID_FIELD==''BATCH_ID'')
		{	
			var V_SQ3 = `UPDATE `+ V_TABLE_NM +` SET ERROR_FLAG = ''N''  WHERE BATCH_ID=`+ V_BATCH_ID+``;
			v_return_value += "\\n V_SQ3: " + V_SQ3;
			var V_ST3 = snowflake.createStatement( {sqlText: V_SQ3} ).execute();	
		}
		
----------Deleting all error entries from error details for particular batch
		
		var V_SQ4 = `DELETE FROM  COMETL_CONTROL_TEST_DB.COMETL_CONTROL_EMEA.ERROR_DTLS WHERE BATCH_ID=`+ V_BATCH_ID +` AND SUB_AREA_NM = ''` + P_SUB_AREA_NM +`''
		AND OBJECT_LAYER =''` + P_OBJECT_LAYER +`'' AND INTERFACE_NM =''` + P_INTERFACE_NM +`''`;
		
		var V_ST4 = snowflake.createStatement( {sqlText: V_SQ4} ).execute();
		
		var V_SQ5 =`SELECT RULE_ID,VALIDATION_COLUMN_NM,RULE_SQL,RULE_DESC,RULE_TYPE,ERROR_MSG,UNIQUE_KEY, SRC_TABLENM
        FROM COMETL_CONTROL_TEST_DB.COMETL_CONTROL_EMEA.DATA_VLDTN_RULE WHERE IS_ACTIVE = ''Y'' AND 
		UPPER(INTERFACE_NM) = UPPER(''` + P_INTERFACE_NM + `'') AND UPPER(SUB_AREA_NM) = UPPER(''` + P_SUB_AREA_NM +`'') 
		AND UPPER(OBJECT_LAYER)= UPPER(''` + P_OBJECT_LAYER +`'')`;
		var V_ST5 = snowflake.createStatement( {sqlText: V_SQ5} ).execute();
		
		while (V_ST5.next()){
		
		var V_RULE_ID = V_ST5.getColumnValue(1);
		var V_VALIDATION_COLUMN_NM = V_ST5.getColumnValue(2);
		var V_WHERE_COND = V_ST5.getColumnValue(3);
		var V_RULE_DESC = V_ST5.getColumnValue(4);
		var V_RULE_TYPE = V_ST5.getColumnValue(5);
		var V_ERROR_MSG = V_ST5.getColumnValue(6);
		var V_UNIQUE_KEY = V_ST5.getColumnValue(7);
		var V_SRC_TABLE_NAME = V_ST5.getColumnValue(8);
		
		var V_SRC_TABLE = P_DATABASE_NM+`.`+V_SRC_TABLE_SCHEMA+`.`+V_SRC_TABLE_NAME;
		
		v_return_value += "\\n V_RULE_ID: " + V_RULE_ID;
		v_return_value += "\\n V_VALIDATION_COLUMN_NM: " + V_VALIDATION_COLUMN_NM;
		v_return_value += "\\n V_WHERE_COND: " + V_WHERE_COND;
		v_return_value += "\\n V_RULE_DESC: " + V_RULE_DESC;
		v_return_value += "\\n V_RULE_TYPE: " + V_RULE_TYPE;
		v_return_value += "\\n V_ERROR_MSG: " + V_ERROR_MSG;
		v_return_value += "\\n V_UNIQUE_KEY: " + V_UNIQUE_KEY;
		v_return_value += "\\n V_SRC_TABLE: " + V_SRC_TABLE;
		
		var V_INPUT_PARAM = P_SUB_AREA_NM + `,`+ P_INTERFACE_NM + `,` + P_OBJECT_LAYER;
		var	V_WHERE_CLAUSE = `(` + V_WHERE_COND +`)`;
		
		v_return_value += "\\n V_INPUT_PARAM: " + V_INPUT_PARAM;
		v_return_value += "\\n V_WHERE_CLAUSE: " + V_WHERE_CLAUSE;

---------Fetching error counts using rule sql in data validation
		
		if(V_RUN_ID_FIELD==''BATCH_ID'')
		{
			var V_SRC_CNT_SQ=`SELECT COUNT(*) FROM `+ V_SRC_TABLE +` WHERE ` + V_WHERE_CLAUSE +` AND BATCH_ID =` + V_BATCH_ID + ``;
			var V_SRC_CNT_ST  = snowflake.createStatement( {sqlText: V_SRC_CNT_SQ} ).execute();
			if(V_SRC_CNT_ST.next())
			{
				var V_SRC_CNT = V_SRC_CNT_ST.getColumnValue(1);
				v_return_value += "\\n V_SRC_CNT: " + V_SRC_CNT;
			}
			
			var V_SQ6 =`INSERT INTO COMETL_CONTROL_TEST_DB.COMETL_CONTROL_EMEA.ERROR_DTLS SELECT
			` + V_BATCH_ID +`,` + V_RULE_ID + `,''` + V_RULE_TYPE + `'', ''` + P_SUB_AREA_NM + `'', ''` + P_INTERFACE_NM + `'', ''` + P_OBJECT_LAYER + `'', ` +  V_UNIQUE_KEY  + `, ''` + V_SRC_TABLE_SCHEMA + `'',''` + V_SRC_TABLE_NAME + `'',''` + V_ERROR_MSG +`'', CURRENT_DATE(),  ''ETL_USER''  FROM `+ V_SRC_TABLE +` WHERE ` + V_WHERE_CLAUSE +` AND BATCH_ID =` + V_BATCH_ID + ``;
			
			v_return_value += "\\n V_SQ6: " + V_SQ6;
			
			var V_ST6 = snowflake.createStatement( {sqlText: V_SQ6} ).execute();
		}
		else
		{
			var V_SRC_CNT_SQ=`SELECT COUNT(*) FROM `+ V_SRC_TABLE +` WHERE ` + V_WHERE_CLAUSE +``;
			var V_SRC_CNT_ST  = snowflake.createStatement( {sqlText: V_SRC_CNT_SQ} ).execute();
			if(V_SRC_CNT_ST.next())
			{
				var V_SRC_CNT = V_SRC_CNT_ST.getColumnValue(1);
				v_return_value += "\\n V_SRC_CNT: " + V_SRC_CNT;
			}
			
			var V_SQ6 =`INSERT INTO COMETL_CONTROL_TEST_DB.COMETL_CONTROL_EMEA.ERROR_DTLS SELECT
			` + V_BATCH_ID +`,` + V_RULE_ID + `,''` + V_RULE_TYPE + `'', ''` + P_SUB_AREA_NM + `'', ''` + P_INTERFACE_NM + `'', ''` + P_OBJECT_LAYER + `'', ` +  V_UNIQUE_KEY  + `, ''` + V_SRC_TABLE_SCHEMA + `'',''` + V_SRC_TABLE_NAME + `'',''` + V_ERROR_MSG +`'', CURRENT_DATE(),  ''ETL_USER''  FROM `+ V_SRC_TABLE +` WHERE ` + V_WHERE_CLAUSE +``;
			
			v_return_value += "\\n V_SQ6: " + V_SQ6;
			
			var V_ST6 = snowflake.createStatement( {sqlText: V_SQ6} ).execute();
		}
		
-------------Fetching counts from error details table
		
		var V_SQ7 =`SELECT COUNT(*) FROM COMETL_CONTROL_TEST_DB.COMETL_CONTROL_EMEA.ERROR_DTLS 
		WHERE BATCH_ID=` + V_BATCH_ID +` AND UPPER(INTERFACE_NM) = UPPER(''` + P_INTERFACE_NM +`'') AND UPPER(SUB_AREA_NM) = UPPER(''` + P_SUB_AREA_NM + `'') AND UPPER(SRC_TABLENM)= UPPER(''` + V_SRC_TABLE_NAME + `'') AND RULE_ID =` + V_RULE_ID +` AND RULE_TYPE =''` + V_RULE_TYPE +`''`;
		var V_ST7  = snowflake.createStatement( {sqlText: V_SQ7} ).execute();
		if(V_ST7.next())
		{
			var V_INS_COUNT = V_ST7.getColumnValue(1);
			v_return_value += "\\n V_INS_COUNT: " + V_INS_COUNT;
			
		}
		
------------Comparing error details count vs counts from data validation having  rule_sql as where clause
		
		if( V_SRC_CNT != V_INS_COUNT )
		{
		v_return_value +="The actual error records count and error table record counts are different.";
		throw v_return_value;
		}
  }
		var V_SQ_VW = `SELECT DISTINCT SRC_TABLENM, SRC_TABLE_SCHEMA
         FROM COMETL_CONTROL_TEST_DB.COMETL_CONTROL_EMEA.ERROR_DTLS WHERE UPPER(INTERFACE_NM) = UPPER(''` + P_INTERFACE_NM + `'') AND UPPER(SUB_AREA_NM) = UPPER(''` + P_SUB_AREA_NM +`'')  AND BATCH_ID =` + V_BATCH_ID +`  AND UPPER(OBJECT_LAYER)= UPPER(''` + P_OBJECT_LAYER +`'')`;
						v_return_value += "\\n V_SQ_VW: " + V_SQ_VW;
			
			var V_ST_VW = snowflake.createStatement( {sqlText: V_SQ_VW} ).execute();
			
			while (V_ST_VW.next()){
				
				var V_NM = V_ST_VW.getColumnValue(1);
				var V_SCH_NM = V_ST_VW.getColumnValue(2);
				
				var V_NAME = P_DATABASE_NM+`.`+V_SCH_NM+`.VW_`+V_NM+`_ERR`;
				var V_SRC_NAME = P_DATABASE_NM+`.`+V_SCH_NM+`.`+V_NM;
				
				v_return_value += "\\n V_NM: " + V_NM;
				v_return_value += "\\n V_SCH_NM: " + V_SCH_NM;
				v_return_value += "\\n V_NAME: " + V_NAME;
				v_return_value += "\\n V_SRC_NAME: " + V_SRC_NAME;
				
				var V_SQ_KEY = `SELECT DISTINCT UNIQUE_KEY FROM COMETL_CONTROL_TEST_DB.COMETL_CONTROL_EMEA.DATA_VLDTN_RULE WHERE UPPER(SRC_TABLENM) = UPPER(''` + V_NM +`'') `;
				var V_ST_KEY = snowflake.createStatement( {sqlText: V_SQ_KEY} ).execute();
					if(V_ST_KEY.next())
						{
						var V_KEY_NM = V_ST_KEY.getColumnValue(1);
						v_return_value += "\\n V_KEY_NM: " + V_KEY_NM;
						}			
-------------Creating Error views				
				if(V_RUN_ID_FIELD==''BATCH_ID'')
				{
				var V_SQ_VW_2 =`CREATE OR REPLACE VIEW ` + V_NAME +` AS
				SELECT distinct B.* , A.RULE_ID, A.RULE_TYPE, A.ERROR_MSG FROM COMETL_CONTROL_TEST_DB.COMETL_CONTROL_EMEA.ERROR_DTLS A
				join `+ V_SRC_NAME +` B on A.SRC_UNIQUE_KEY = B.`+V_KEY_NM+` AND A.BATCH_ID = B.BATCH_ID where UPPER(INTERFACE_NM) = UPPER(''` + P_INTERFACE_NM + `'') AND A.BATCH_ID=` + V_BATCH_ID +`  AND UPPER(SRC_TABLENM) = UPPER(''` + V_NM + `'')
            AND UPPER(SUB_AREA_NM) = UPPER(''` + P_SUB_AREA_NM + `'')`;
				}
				else 
				{
				var V_SQ_VW_2 =`CREATE OR REPLACE VIEW ` + V_NAME +` AS
				SELECT distinct B.* , A.RULE_ID, A.RULE_TYPE, A.ERROR_MSG FROM COMETL_CONTROL_TEST_DB.COMETL_CONTROL_EMEA.ERROR_DTLS A
				join `+ V_SRC_NAME +` B on A.SRC_UNIQUE_KEY = B.`+V_KEY_NM+` where UPPER(INTERFACE_NM) = UPPER(''` + P_INTERFACE_NM + `'')  AND A.BATCH_ID=` + V_BATCH_ID +` 
				AND UPPER(SRC_TABLENM) = UPPER(''` + V_NM + `'') AND UPPER(SUB_AREA_NM) = UPPER(''` + P_SUB_AREA_NM + `'')`;	
				}
				
				v_return_value += "\\n V_SQ_VW_2: " + V_SQ_VW_2;
				
				var V_ST_VW_2 = snowflake.createStatement( {sqlText: V_SQ_VW_2} ).execute(); 
					if(V_ST_VW_2.next())
						{						
						v_return_value += "\\n \\n ERROR VIEW created succesfully for: " + V_NAME;
						}
			
			
			}

			
		snowflake.execute({ sqlText: "COMMIT;"}); 
		
------------Calling audit sp	
	
		var V_AUDIT_UPD_COMP_SQ = `CALL COMETL_CONTROL_TEST_DB.COMETL_CONTROL_EMEA.SP_AUDIT_LOG(''`+P_INTERFACE_NM+`'',''SP_DATA_VALDTN_INS'',''`+P_SUB_AREA_NM+`'',''PROCEDURE'', ''C'',''NA'' )`;
		var V_AUDIT_UPD_COMP_ST = snowflake.createStatement( {sqlText: V_AUDIT_UPD_COMP_SQ} ).execute();
	
		return "SUCCEEDED, Details: " +v_return_value;
		var check_flg=0;
  }
	catch (err)  
	{
      snowflake.execute({ sqlText: "ROLLBACK;"});
	  var check_flg=1;
	  v_return_value +=  "\\n  Failed: Code: " + err.code + "\\n  State: " + err.state;
      v_return_value += "\\n  Message: " + err.message;
      v_return_value += "\\nStack Trace:\\n" + err.stackTraceTxt;
	  var output_return_value=v_return_value.replace(/''/g,"''''");
	  
	  var V_AUDIT_UPD_FAIL_SQ = `CALL COMETL_CONTROL_TEST_DB.COMETL_CONTROL_EMEA.SP_AUDIT_LOG(''`+P_INTERFACE_NM+`'',''SP_DATA_VALDTN_INS'',''`+P_SUB_AREA_NM+`'',''PROCEDURE'', ''F'',''`+output_return_value+`'')`;  
	  var V_AUDIT_UPD_FAIL_ST = snowflake.createStatement( {sqlText: V_AUDIT_UPD_FAIL_SQ} ).execute();
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