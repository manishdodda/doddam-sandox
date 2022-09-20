@Library('library-demo') _

pipeline {
    agent any
    environment { 
        unix_src_path = "unix_scripts/"
        unix_deploy_path = "/tmp/"
        unix_server = "${env.BRANCH_NAME}_fmr_unix"
        main_fmr_unix = "euz1nldw04"
    }
    parameters {
        choice choices: ['No', 'Yes'], description: 'Mention if You want to Deploy into Unix Environment', name: 'Deploy_to_Unix'
        choice choices: ['No', 'Yes'], description: 'Mention if You want to Deploy into Snowflake Environment', name: 'Deploy_to_Snowflake'
    }

    stages{
        stage ("Deploy to Unix") {
            when {
                expression { params.Deploy_to_Unix == "Yes" }
            }
            steps{
                script{
                    unix_deploy(src: unix_src_path, dest: unix_deploy_path, server: "${env.BRANCH_NAME}_fmr_unix"})
                }
            }
        }
    }
}
