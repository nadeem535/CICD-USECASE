def imageTag

pipeline {
    agent any

    environment {
        GOOGLE_APPLICATION_CREDENTIALS = credentials('anilgcpcredentials')
    }

    stages {
        stage('Non Prod Infra : Creation') {
            when {
                anyOf {
                    branch 'develop'
                    branch 'test'
                }
            }
            steps {
                script {
                    sh 'gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS'
                    sh 'gcloud config set project excellent-guide-410011'

                    if (env.BRANCH_NAME == 'develop') {
                        dir("ops/ArtifactRegistry/dev") {
                            sh 'terraform --version'
                            sh 'terraform init'
                            sh 'terraform plan -out=output.tfplan'
                            sh 'terraform apply -auto-approve'
                        }
                    } else if (env.BRANCH_NAME == 'test') {
                        dir("ops/ArtifactRegistry/uat") {
                            sh 'terraform --version'
                            sh 'terraform init'
                            sh 'terraform plan -out=output.tfplan'
                            sh 'terraform apply -auto-approve'
                        }
                    }
                }
            }
        }

        stage('Non Prod code build and docker image Creation') {
            when {
                anyOf {
                    branch 'develop'
                    branch 'test'
                }
            }
            steps {
                script {
                    sh 'gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS'
                    sh 'gcloud config set project excellent-guide-410011'

                    if (env.BRANCH_NAME == 'develop') {
                        dir("ops/src/dev") {
                            sh 'echo running dev build docker image'
                            sh 'docker version'
                            sh 'docker rmi -f $(docker images -q)'
                            sh 'docker images'
                            imageTag = "latest-${env.BUILD_NUMBER}" // or use a timestamp or commit hash
                            sh "docker build -t pythondemoimage:${imageTag} ."
                            sh "docker tag pythondemoimage:${imageTag} asia-south1-docker.pkg.dev/excellent-guide-410011/anil-cicd-demo-dev-repo/pythondemoimage:${imageTag}"
                            sh "docker push asia-south1-docker.pkg.dev/excellent-guide-410011/anil-cicd-demo-dev-repo/pythondemoimage:${imageTag}"
                            sh 'gcloud auth configure-docker asia-south1-docker.pkg.dev'
                            sh 'docker images'
                        }
                    } else if (env.BRANCH_NAME == 'test') {
                        dir("ops/src/uat") {
                            sh 'echo running uat build docker image'
                            sh 'docker --version'
                            sh 'docker images'
                            imageTag = "latest-${env.BUILD_NUMBER}" // or use a timestamp or commit hash
                            sh "docker build -t pythondemoimage:${imageTag} ."
                            sh "docker tag pythondemoimage:${imageTag} asia-south1-docker.pkg.dev/excellent-guide-410011/anil-cicd-demo-dev-repo/pythondemoimage:${imageTag}"
                            sh "docker push asia-south1-docker.pkg.dev/excellent-guide-410011/anil-cicd-demo-dev-repo/pythondemoimage:${imageTag}"
                            sh 'gcloud auth configure-docker asia-south1-docker.pkg.dev'
                            sh 'docker images'
                        }
                    }
                }
            }
        }

        stage('Non Prod service Creation and deployment') {
            when {
                anyOf {
                    branch 'develop'
                    branch 'test'
                }
            }
            steps {
                script {
                    sh 'gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS'
                    sh 'gcloud config set project excellent-guide-410011'

                    if (env.BRANCH_NAME == 'develop') {
                        dir("ops/CloudRunService/dev") {
                            sh "sed -i 's|asia-south1-docker.pkg.dev/excellent-guide-410011/anil-cicd-demo-dev-repo/pythondemoimage:\${imageTag}|asia-south1-docker.pkg.dev/excellent-guide-410011/anil-cicd-demo-dev-repo/pythondemoimage:${imageTag}|' main.tf"
                            sh 'terraform --version'
                            sh 'terraform init'
                            sh 'terraform plan -out=output.tfplan'
                            sh 'terraform apply -auto-approve'
                        }
                        dir("ops/Kubernetes/dev") {
                            sh 'terraform --version'
                            sh 'terraform init'
                            sh 'terraform plan -out=output.tfplan'
                            sh 'terraform apply -auto-approve'

                            sh 'gcloud config set project excellent-guide-410011'
                            sh 'kubectl config view'
                            sh 'gcloud container clusters get-credentials anil-demo-gke-cluster --region asia-south1 --project excellent-guide-410011'
                            sh "sed -i 's|asia-south1-docker.pkg.dev/excellent-guide-410011/anil-cicd-demo-dev-repo/pythondemoimage:\${imageTag}|asia-south1-docker.pkg.dev/excellent-guide-410011/anil-cicd-demo-dev-repo/pythondemoimage:${imageTag}|' deployment.yml"
                            sh 'kubectl apply -f deployment.yml'
                            sh 'kubectl apply -f service.yml'
                        }
                    } else if (env.BRANCH_NAME == 'test') {
                        dir("ops/CloudRunService/uat") {
                            sh 'terraform --version'
                            sh 'terraform init'
                            sh 'terraform plan -out=output.tfplan'
                            sh 'terraform apply -auto-approve'
                        }
                    }
                }
            }
        }

        stage('Production Infra : Creation') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sh 'gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS'
                    sh 'gcloud config set project excellent-guide-410011'

                    if (env.BRANCH_NAME == 'main') {
                        dir("ops/ArtifactRegistry/prod") {
                            sh 'terraform --version'
                            sh 'terraform init'
                            sh 'terraform plan -out=output.tfplan'
                            sh 'terraform apply -auto-approve'
                        }
                        dir("ops/src/prod") {
                            sh 'echo running prod build docker image'
                            sh 'docker --version'
                            sh 'docker images'
                            sh 'docker build -t pythondemoimage'
                            sh 'gcloud auth configure-docker asia-south1-docker.pkg.dev'
                            sh 'docker images'
                            sh 'docker tag pythondemoimage asia-south1-docker.pkg.dev/excellent-guide-410011/anil-cicd-demo-prod-repo/pythondemoimage:latest'
                            sh 'docker push asia-south1-docker.pkg.dev/excellent-guide-410011/anil-cicd-demo-prod-repo/pythondemoimage:latest'
                        }
                        dir("ops/CloudRunService/prod") {
                            sh 'terraform --version'
                            sh 'terraform init'
                            sh 'terraform plan -out=output.tfplan'
                            sh 'terraform apply -auto-approve'
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
