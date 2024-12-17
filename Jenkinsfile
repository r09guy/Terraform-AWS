pipeline {
    agent any
    stages {
        stage('AWS-Terraform Credentials') {
            steps {
                withAWS(credentials: 'aws-terraform', region: 'eu-west-1') {
                    script {
                        
                        // Run Terraform commands using AWS credentials
                        sh '''
                            terraform init
                            terraform apply -auto-approve
                        '''
                    }
                }
            }
        }
    }
}