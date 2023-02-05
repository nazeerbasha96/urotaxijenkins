pipeline {
    agent {
        label "jenkinsslave2"
    }
    environment {

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
                    terraform -chdir=config/terraform init
                    terraform -chdir=config/terraform apply --auto-approve
                    terraform -chdir=config/terraform output --raw "appserver_private_ip" > hosts
                    terraform -chdir=config/terraform output --raw "db_endpoint" > dbHosts
                '''
            }
            post {
                failure {
                    sh '''
                        terraform -chdir=config/terraform destroy --auto-approve
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
        stage('package') {
            steps {
                sh 'mvn --batch-mode clean package -DskipTests=true'
            }
        }
        stage('deploy') {
            steps {
                sh 'sudo chmod u+x src/main/config/sh/getDBHost.sh'
                script {
                    env.DB_HOST = sh(returnStdout: true, script: "config/sh/getDBHost.sh").trim()
                    echo "env.DB_HOST is '${DB_HOST}'"
                }                
                ansiblePlaybook(playbook: 'src/main/config/ansible/urotaxi-playbook.yml', credentialsId: 'AWS_KEY', inventory: 'hosts')                
            }
        }
        
    }
}

