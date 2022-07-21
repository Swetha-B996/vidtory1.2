pipeline {
  agent any
    tools {
       terraform 'terraform'
    }
    
     stages {
        stage('AWS Credentials & terraform') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
	       		credentialsId: 'aws-cred-encrypted',
	                accessKeyVariable: 'AWS_ACCESS_KEY_ID',
	                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
	                    sh 'terraform init'
	                    sh 'terraform apply -auto-approve'
	                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
}
