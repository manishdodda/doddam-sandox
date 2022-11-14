@Library('library-demo') _

pipeline {
    agent any
    environment {
        //pgdb_credid = "${env.BRANCH_NAME}_snowflake_credid"
        pgdb_credid = "dev_pgdb"
        pgdb_url = "${getProperty("${env.BRANCH_NAME}_pfzalgn_pgdb_url")}"
        pgdb_changeLogFile = "changelog.pg.xml"
    }
    parameters {
        choice choices: ['No', 'Yes'], description: 'Mention if You want to Deploy into PostgreSQL Environment', name: 'Deploy_to_PostgreSQL'
    }
    stages{
        stage("Testing Pfizer Align PostgreSQL Deployment"){
            steps{
                script{
                    postgresql_deploy(url: pgdb_url, cred: pgdb_credid, changelog: pgdb_changeLogFile)
                }
            }
        }
    }
}
