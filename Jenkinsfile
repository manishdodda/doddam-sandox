@Library('sfdi-devops-tools-infra') _

pipeline {
    agent any
    environment {
        snowflake_changeLogFile_COMETL_PA__db = "snowflake/COMETL_PA/changelog.sf.xml"
        snowflake_COMETL_PA__db_url = "${getProperty("dev_pfzalgn_snowflake_COMETL_PA_db_url")}"
        snowflake_credid = "dev_pfzalgn_snowflake_credid"
        unix_permission = "775"
    }
    parameters {
        choice choices: ['No', 'Yes'], description: 'Mention if You want to Dry Run', name: 'dry_run'
        choice choices: ['No', 'Yes'], description: 'Mention if You want to Deploy into Snowflake Environment', name: 'Deploy_to_Snowflake_COMETL_PA'
    }
    stages{
        stage ("Deploy to Snowflake Datbase - COMETL_PA"){
            when {
                 expression { params.Deploy_to_Snowflake_COMETL_PA == "Yes" }
            }
                steps{
                    script{
                        println "Testing Dryrun"
                        snowflake_deploy(url: snowflake_COMETL_PA__db_url, cred: snowflake_credid, changelog: snowflake_changeLogFile_COMETL_PA__db, dry_run: dry_run )
                        }
                }
        }
    }
}