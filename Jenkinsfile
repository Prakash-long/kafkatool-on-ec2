pipeline {
    agent any

    environment {
        TF_VAR_key_name = "test3"
    }

    parameters {
        booleanParam(name: 'DESTROY', defaultValue: false, description: 'Check this to destroy infra')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Prakash-long/kafkatool-on-ec2.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init -input=false'
            }
        }

        stage('Terraform Apply') {
            when { expression { return params.DESTROY == false } }
            steps {
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Terraform Destroy') {
            when { expression { return params.DESTROY == true } }
            steps {
                sh 'terraform destroy -auto-approve'
            }
        }

        stage('Generate Ansible Inventory') {
            when { expression { return params.DESTROY == false } }
            steps {
                script {
                    def kafka_ips = sh(script: "terraform output -json kafka_public_ips | jq -r '.[]'", returnStdout: true).trim().split('\n')
                    writeFile file: 'ansible/inventory.ini', text: '[kafka]\n' + kafka_ips.collect { "${it} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/test3.pem" }.join('\n')
                    sh 'cat ansible/inventory.ini'
                }
            }
        }

        stage('Run Ansible Playbook') {
            when { expression { return params.DESTROY == false } }
            steps {
                dir('ansible') {
                    sh 'ansible-playbook -i inventory.ini deploy-kafka.yml'
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished"
        }
    }
}
