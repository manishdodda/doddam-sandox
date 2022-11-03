@Library('library-demo') _

pipeline {
    agent any
    environment {
        unix_server = "EUZ1NLDW04"
        unix_src_path = "unix_scripts"
        unix_deploy_path = "/tmp/result_manish"
        unix_service_account = "srvamr-sfaops@amer"
        file_permissions = "755"
        unix_owner = "sfa-tds"
        unix_group = "sfa-tds-etl-l-g"
    }
    stages{
        stage("Testing Unix Deployment"){
            steps{
                script{
                    unix_deploy(src: unix_src_path, 
                                dest: unix_deploy_path, 
                                server: unix_server,
                                service_account: unix_service_account,
                                permissions: file_permissions,
                                group: unix_group, 
                                owner: unix_owner)
                }
            }
        }
    }
}
