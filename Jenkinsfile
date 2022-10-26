@Library('library-demo') _

pipeline {
    agent any
    environment {
        unix_server = "${getProperty("${env.BRANCH_NAME}_fmr_unix")}"
        unix_src_path = "unix_scripts"
        unix_deploy_path = "/tmp"
        snowflake_driver = "net.snowflake.client.jdbc.SnowflakeDriver"
        snowflake_changeLogFile = "changelog_Release1.sf.xml"
        snowflake_url = "${getProperty("${env.BRANCH_NAME}_fmr_snowflake")}"
        snowflake_cred = "${env.BRANCH_NAME}_snowflake"
    }
    stages{
        stage("Testing Unix Deployment"){
            steps{
                script{
                    unix_deploy(src: unix_src_path, 
                                dest: unix_deploy_path, 
                                server: unix_server)
                }
            }
        }
    }
}
