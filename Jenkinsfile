@Library('library-demo') _

pipeline {
    agent any
    stages{
        stage ("Testing") {
            steps{
                script{
                    unix_deploy()
                }
            }
        }
    }
}
