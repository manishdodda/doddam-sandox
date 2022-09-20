@Library('library-demo') _

pipeline {
    agent any
    environment {
        snowflake = "${env.BRANCH_NAME}_snowflake"
    }

    stages{
        stage ("Testing") {
            steps{
                script{
                    unix_deploy(snowflake)
                }
            }
        }
    }
}
