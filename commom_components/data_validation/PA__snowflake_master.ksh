#!/bin/bash
. $SCRIPT_PATH/PA__config.cfg

P_CONNECTION=$1
P_SCHEMA_NAME=$2
P_MODULE_NAME=$3
P_PROC_NAME=$4
P_IN_PARAMETERS=$5

# P_IN_PARAMETERS needs input parameters which includes "interface_name','table_name','integration layer','database name'" e.g.- 'ODS_PUB','PA_POSTN','STAGING','COMETL_PA_EMEA_PUB_TEST_DB'" #

#decryption
V_SNOWSQL_PATH=$SNOWSQL_PATH
V_DKEY=$DKEY
paswd=$(grep -A 6 $P_CONNECTION $V_SNOWSQL_PATH | grep 'password' | cut -d '=' -f2-)
decrypted_password=$(echo $paswd |openssl enc -d -aes-256-cbc -a -pass pass:$V_DKEY)
export SNOWSQL_PWD=$decrypted_password

V_LOG_NAME=$LOG_PATH/SP_Exec_"$P_MODULE_NAME"_"$P_PROC_NAME"_"$P_IN_PARAMETERS"_"$DT".log
V_LOG_FILE=`sed -e "s/'//g; s/,/_/g" <<<$V_LOG_NAME`

V_CONNECTION=`echo "$P_CONNECTION"`
V_DB_SCHEMA_NM=`echo "$db_name.$P_SCHEMA_NAME"`

V_EXECUTABLE_STTM=`echo "call $V_DB_SCHEMA_NM.$P_PROC_NAME($P_IN_PARAMETERS)"`

echo "Procedure Call Statement to be executed is: $V_EXECUTABLE_STTM" > $V_LOG_FILE
echo "Procedure Execution Started" >> $V_LOG_FILE

snowsql -c $V_CONNECTION -o exit_on_error=true -o output_file=$V_LOG_FILE -q "$V_EXECUTABLE_STTM"
v_EXIT_CODE=$?
echo $v_EXIT_CODE
:
if [[ $v_EXIT_CODE -ne 0 ]];
        then
                echo "Procedure Failed, exit status is $v_EXIT_CODE. Please check the log file $V_LOG_FILE for more details."
                echo "Procedure $V_DB_SCHEMA_NM.$P_PROC_NAME in $ENV environment got failed for input parameters $P_IN_PARAMETERS. Please check the attached log for more details" | sh $SCRIPT_PATH/failure_mail.sh $P_MODULE_NAME $P_PROC_NAME $P_IN_PARAMETERS "$TEAM_MAIL_LIST" $V_LOG_FILE
                exit 1
        else
                echo "$V_DB_SCHEMA_NM.$P_PROC_NAME procedure was executed successfully." >> $V_LOG_FILE
