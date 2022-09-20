@Library('library-demo') _

pipeline {
    agent any
    environment {
        snowflake = "${env.BRANCH_NAME}_snowflake"
        unix_deploy_path = "/tmp/"
    }
    parameters {
        choice choices: ['Yes', 'No'], description: 'Mention if You want to Deploy into Unix Environment', name: 'Deploy to Unix'
    }

    stages{
        stage ("Testing") {
            when {
                expression {

                }
            }
            steps{
                script{
                    unix_deploy(unix_deploy_path)
                }
            }
        }
    }
}
