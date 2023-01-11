@Library('library-demo') _

pipeline {
    agent any
    parameters {
        choice choices: ['No', 'Yes'], description: 'Mention if You want to Deploy into PostgreSQL Environment', name: 'Deploy_to_PostgreSQL'
        choice choices: ['No', 'Yes'], description: 'If you want to send alerts', name: 'Email_Alert'
        string  defaultValue: 'None', description: 'Provide the comma separated Email addresses.', name: 'Notify_to'
    }
    stages{
        stage("Testing email notifications"){
            steps{
                script{
                    error "Testing notification"
                    sh 'echo "Hello" '
                }
            }
        }
    }
    post {
        failure {
            notification_email(Email_Alert,Notify_to) 
        }
        success {
            notification_email(Email_Alert,Notify_to)
        }
    }
}
