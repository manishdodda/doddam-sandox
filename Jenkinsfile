@Library('library-demo@feature/doddam') _

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
