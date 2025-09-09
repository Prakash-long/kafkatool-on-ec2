variable "region" {
  default = "us-east-1"
}

variable "ami" {
  default = "ami-0557a15b87f6559cf"  # Ubuntu 22.04 LTS
}

variable "instance_type" {
  default = "t2.medium"
}

variable "kafka_instance_count" {
  default = 3
}

variable "my_ip" {
  default = "103.70.200.82/32"  # <-- Your current public IP
}

variable "key_pub_path" {
  default = "/mnt/c/Users/Prakash/Downloads/kafka-key.pub"
}
