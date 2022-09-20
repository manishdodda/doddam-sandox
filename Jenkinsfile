@Library('library-demo') _

pipeline {
    agent any
    stages{
        stage ("Testing") {
            steps{
                script{
                    String Name = 'Manish Gandhi Dodda' 
                    unix_deploy(Name)
                }
            }
        }
    }
}
