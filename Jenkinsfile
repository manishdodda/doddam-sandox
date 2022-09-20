@Library('library-demo') _

pipeline {
    agent any
    environment {
        unix_dev = "${env.BRANCH_NAME}"
    }

    stages{
        stage ("Testing") {
            steps{
                script{
                    unix_deploy(unix_dev)
                }
            }
        }
    }
}
