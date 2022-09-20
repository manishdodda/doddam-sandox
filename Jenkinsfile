@Library('library-demo') _

pipeline {
    agent any
    environment {
        snowflake = "${env.BRANCH_NAME}_snowflake"
        unix_deploy_path = "/tmp/"
    }
    parameters {
        choice choices: ['No', 'Yes'], description: 'Mention if You want to Deploy into Unix Environment', name: 'Deploy_to_Unix'
        choice choices: ['No', 'Yes'], description: 'Mention if You want to Deploy into Snowflake Environment', name: 'Deploy_to_Snowflake'
    }

    stages{
        stage ("Deploy to Unix") {
            when {
                expression { params.Deploy_to_Unix == "Yes" }
            }
            steps{
                script{
                    unix_deploy(unix_deploy_path)
                }
            }
        }
    }
}
