@Library('library-demo') _

pipeline {
    agent any
    environment {
        unix_server = "EUZ1NLDW04"
        unix_src_path = "unix_scripts"
        unix_deploy_path = "/tmp"
        unix_service_account = "srvamr-sfaops@amer"
    }
    stages{
        stage("Testing Unix Deployment"){
            steps{
                script{
                    unix_deploy(src: unix_src_path, 
                                dest: unix_deploy_path, 
                                server: unix_server
                                service_account: unix_service_account)
                }
            }
        }
    }
}
