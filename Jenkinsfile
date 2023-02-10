pipeline {
    agent {
        label "any"
    }
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        UROTAXI_DB_USER = 'root'
        UROTAXI_DB_PSW ='welcome1'
        ANSIBLE_HOST_KEY_CHECKING="False"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '3'))
        disableConcurrentBuilds()
        timestamps()
        timeout(time: 1, unit: 'HOURS')
    }
    tools {
        maven '3.8.6'
        terraform '21207'
    }
    stages {
        stage ('checkout') {
            steps {
                git (url:'https://github.com/nazeerbasha96/urotaxijenkins.git')
            }
        }
        stage ('test') {
            steps {
                sh 'mvn --batch-mode clean test'
            }
        }
        stage ('infra') {
            steps {
                sh '''
                    terraform -chdir=config/Terraform/global init
                    terraform -chdir=config/Terraform/global apply --auto-approve
                    terraform -chdir=config/Terraform/global output --raw "appserver_private_ip" > hosts
                    terraform -chdir=config/Terraform/global output --raw "db_endpoint" > dbHosts
                '''
            }
            post {
                failure {
                    sh '''
                        terraform -chdir=config/Terraform/global destroy --auto-approve
                    '''
                }
            }
        }
        stage('prepare') {
            steps {
                sh '''
                    sed -i "s|#dbusername#|$UROTAXI_DB_USER|g" src/main/resources/application.yml
                    sed -i "s|#dbpassword#|$UROTAXI_DB_PSW|g" src/main/resources/application.yml
                    dbHost=$(cat dbHosts)
                    sed -i "s|#dbhost#|$dbHost|g" src/main/resources/application.yml
                '''
            }
        }
        
    }
}

