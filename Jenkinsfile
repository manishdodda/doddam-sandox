@Library('sfdi-devops-tools-infra') _

pipeline {
    agent any
    parameters {
        choice choices: ['No', 'Yes'], description: 'If you want to send alerts', name: 'Email_Alert'
        string defaultValue: 'None', description: 'Provide the comma separated Email addresses.', name: 'Notify_to'
    }
    stages{
        stage ("Deploy to Snowflake Database - COMETL_PA"){
                steps{
                    script{
                        println "Deploying"
                        }
                }
        }

    }
    post {
        failure {
            notification_email(Email_Alert: Email_Alert, Notify_to: Notify_to) 
        }
        success {
            notification_email(Email_Alert: Email_Alert, Notify_to: Notify_to)
        }
    }
}
