@Library('library-demo')_

pipeline {
    agent any
    stages{
        stage ("Testing") {
            steps{
                src.test_file.call()
            }
        }
    }
}
