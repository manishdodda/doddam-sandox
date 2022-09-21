@Library('library-demo') _

pipeline {
    agent any
    environment { 
        unix_src_path = "unix_scripts"
        unix_deploy_path = "/tmp"
        //dev_fmr_unix = "euz1nldw04"
        var1 = "${getProperty("${env.BRANCH_NAME}_fmr_unix")}"
    }
    parameters {
        choice choices: ['No', 'Yes'], description: 'Mention if You want to Deploy into Unix Environment', name: 'Deploy_to_Unix'
        choice choices: ['No', 'Yes'], description: 'Mention if You want to Deploy into Snowflake Environment', name: 'Deploy_to_Snowflake'
    }

    stages{
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
                            snowflake_deploy(temp: var1)
                        }
                    }
                }
            }
        }
    }
}
