@Library('library-demo') _

pipeline {
    agent any
    parameters {
        choice choices: ['No', 'Yes'], description: 'Mention if You want to Deploy into PostgreSQL Environment', name: 'Deploy_to_PostgreSQL'
    }
    stages{
        stage("Testing email notifications"){
            steps{
                script{
                    sh 'echo "Hello" '
                }
            }
        }
    }
    post {
        failure {
            notification_email() 
        }
        success {
            notification_email()
        }
    }
}
