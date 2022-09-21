@Library('library-demo') _

pipeline {
    agent any
    environment { 
        unix_src_path = "unix_scripts"
        unix_deploy_path = "/tmp"
        main_fmr_unix = "euz1nldw04"
    }
    parameters {
        choice choices: ['No', 'Yes'], description: 'Mention if You want to Deploy into Unix Environment', name: 'Deploy_to_Unix'
        choice choices: ['No', 'Yes'], description: 'Mention if You want to Deploy into Snowflake Environment', name: 'Deploy_to_Snowflake'
    }

    stages{
        stage ('Get Prerequisites') {
            steps{
                script{
                    def var1 = "Testing"
                }
            }
        }
        stage ("Demo Deployment") {
            parallel {
                stage ("Deploy to Unix"){
                    when {
                        expression { params.Deploy_to_Unix == "Yes" }
                    }
                    steps{
                        script{
                            //String varName = "${env.BRANCH_NAME}_fmr_unix"
                            //println env.test_project
                            unix_deploy(src: unix_src_path, dest: unix_deploy_path, server: "${getProperty("${env.BRANCH_NAME}_fmr_unix")}")
                        }
                    }
                }
                stage ("Deploy to Snowflake"){
                    when {
                        expression { params.Deploy_to_Snowflake == "Yes" }
                    }
                    steps{
                        script{
                            //String varName = "${env.BRANCH_NAME}_fmr_unix"
                            //println env.test_project
                            println var1
                            //snowflake_deploy(var1: ${}
                        }
                    }
                }
            }
        }
    }
}
