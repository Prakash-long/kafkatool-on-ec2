pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo "✅ Code checked out successfully!"
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform-infra/ec2') {
                    sh '''
                        terraform init -input=false
                        terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Configure Kafka with Ansible') {
            steps {
                dir('ansible') {
                    sh '''
                        ansible-playbook -i inventory.ini kafka-setup.yml
                    '''
                }
            }
        }
    }
}
