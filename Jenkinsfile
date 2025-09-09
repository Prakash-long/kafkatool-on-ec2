pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        KEY_PATH   = "${HOME}/kafka-key.pem"
        INVENTORY  = "ansible/inventory.ini"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://your-repo-url.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform-infra') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Generate Ansible Inventory') {
            steps {
                script {
                    // Read Terraform output
                    def tfOutput = sh(script: 'terraform -chdir=terraform-infra output -json', returnStdout: true)
                    def tfJson = readJSON text: tfOutput

                    def publicIps = tfJson.kafka_public_ips.value

                    // Create inventory.ini
                    def inventory = "[kafka_nodes]\n"
                    for (ip in publicIps) {
                        inventory += "${ip} ansible_user=ubuntu ansible_ssh_private_key_file=${env.KEY_PATH}\n"
                    }

                    writeFile file: env.INVENTORY, text: inventory
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir('ansible') {
                    sh """
                    ansible-playbook -i ${env.INVENTORY} deploy-kafka.yml --ssh-extra-args "-o StrictHostKeyChecking=no"
                    """
                }
            }
        }

        stage('Verify Kafka Service') {
            steps {
                script {
                    def tfOutput = sh(script: 'terraform -chdir=terraform-infra output -json', returnStdout: true)
                    def tfJson = readJSON text: tfOutput
                    def publicIps = tfJson.kafka_public_ips.value

                    for (ip in publicIps) {
                        sh """
                        ssh -i ${env.KEY_PATH} -o StrictHostKeyChecking=no ubuntu@${ip} \
                        "sudo systemctl status kafka --no-pager"
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Kafka cluster deployed successfully!'
        }
        failure {
            echo 'Something went wrong. Check the logs.'
        }
    }
}
