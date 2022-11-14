@Library('library-demo') _

pipeline {
    agent any
    environment {
    }
    stages{
        stage("Testing Pfizer Align PostgreSQL Deployment"){
            steps{
                script{
                    postgresql_deploy()
                }
            }
        }
    }
}
