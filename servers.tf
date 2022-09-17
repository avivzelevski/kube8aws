#Bastion
# resource "aws_instance" "bastion" {
#   ami           = var.ami_id
#   instance_type = "t3.micro"
#   subnet_id = module.vpc.public_subnets[0]
#   associate_public_ip_address = "true"
#   security_groups = [aws_security_group.allow_ssh.id]
#   key_name          =   aws_key_pair.k8_ssh.key_name
#   ##https://github.com/hashicorp/terraform/issues/30134
#   user_data = <<-EOF
#                 #!bin/bash
#                 echo "PubkeyAcceptedKeyTypes=+ssh-rsa" >> /etc/ssh/sshd_config.d/10-insecure-rsa-keysig.conf
#                 systemctl reload sshd
#                 echo "${tls_private_key.ssh.private_key_pem}" >> /home/ubuntu/.ssh/id_rsa
#                 chown ubuntu /home/ubuntu/.ssh/id_rsa
#                 chgrp ubuntu /home/ubuntu/.ssh/id_rsa
#                 chmod 600   /home/ubuntu/.ssh/id_rsa
#                 echo "starting ansible install"
#                 apt-add-repository ppa:ansible/ansible -y
#                 apt update
#                 apt install ansible -y
#                 EOF

#   tags = {
#     Name = "Bastion"
#   }
# }

#Master
resource "aws_instance" "master" {
 # count         = var.master_node_count
  ami           = var.ami_id
  instance_type = var.master_instance_type
  #subnet_id = "${element(module.vpc.public_subnets, count.index)}"
  subnet_id = module.vpc.public_subnets[0]
  key_name          =   aws_key_pair.k8_ssh.key_name
  security_groups = [aws_security_group.k8_nondes.id, aws_security_group.k8_master.id, aws_security_group.allow_ssh.id]
  associate_public_ip_address = "true"
  ##https://github.com/hashicorp/terraform/issues/30134
  user_data = <<-EOF
                #!bin/bash
                echo "PubkeyAcceptedKeyTypes=+ssh-rsa" >> /etc/ssh/sshd_config.d/10-insecure-rsa-keysig.conf
                systemctl reload sshd
                echo "${tls_private_key.ssh.private_key_pem}" >> /home/ubuntu/.ssh/id_rsa
                chown ubuntu /home/ubuntu/.ssh/id_rsa
                chgrp ubuntu /home/ubuntu/.ssh/id_rsa
                chmod 600   /home/ubuntu/.ssh/id_rsa
                echo "starting ansible install"
                apt-add-repository ppa:ansible/ansible -y
                apt update
                apt install ansible -y
                EOF
  #  tags = {
  #   #Name = format("Master-%02d", count.index + 1)
  #   Name = Master
  # }
}

#Worker
resource "aws_instance" "worker" {
 # count         = var.worker_node_count
  ami           = var.ami_id
  instance_type = var.worker_instance_type
  #subnet_id = "${element(module.vpc.public_subnets, count.index)}"
  subnet_id = module.vpc.public_subnets[0]
  key_name          =   aws_key_pair.k8_ssh.key_name
  security_groups = [aws_security_group.k8_nondes.id, aws_security_group.k8_worker.id]

  # tags = {
  #   #Name = format("Worker-%02d", count.index + 1)
  #   Name = Worker
  # }
}