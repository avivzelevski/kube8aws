
resource "local_file" "ansible_inventory" {
    content = templatefile("${path.root}/templates/inventry.tftpl",
        {
            master-dns = aws_instance.master.*.private_dns,
            master-ip  = aws_instance.master.*.private_ip,
            master-id  = aws_instance.master.*.id,
            worker-dns = aws_instance.worker.*.private_dns,
            worker-ip  = aws_instance.worker.*.private_ip,
            worker-id  = aws_instance.worker.*.id
        }    
    )
    filename = "${path.root}/inventory"
}

# wating for master server user data init.
# TODO: Need to switch to signaling based solution instead of waiting. 
resource "time_sleep" "wait_for_master_init" {
  depends_on = [aws_instance.master]

  create_duration = "120s"

  triggers = {
    "always_run" = timestamp()
  }
}


resource "null_resource" "provisioner" {
  depends_on    = [
    local_file.ansible_inventory,
    time_sleep.wait_for_master_init,
    aws_instance.master
    ]

  triggers = {
    "always_run" = timestamp()
  }

  provisioner "file" {
    source  = "inventory"
    destination = "/home/ubuntu/inventory"

    connection {
      type          = "ssh"
      host          = aws_instance.master.public_ip
      user          = var.ssh_user
      private_key   = tls_private_key.ssh.private_key_pem
      agent         = false
      insecure      = true
    }
  }
}

resource "local_file" "ansible_vars_file" {
    content = <<-DOC

        DOC
    filename = "ansible/ansible_vars_file.yml"
}

resource "null_resource" "copy_ansible_playbooks" {
  depends_on    = [
    null_resource.provisioner,
    time_sleep.wait_for_master_init,
    aws_instance.master,
    local_file.ansible_vars_file
    ]

  triggers = {
    "always_run" = timestamp()
  }

  provisioner "file" {
      source = "${path.root}/ansible"
      destination = "/home/ubuntu/ansible/"

      connection {
        type        = "ssh"
        host        = aws_instance.master.public_ip
        user        = var.ssh_user
        private_key = tls_private_key.ssh.private_key_pem
        insecure    = true
        agent         = false
      }
    
  }
}

resource "null_resource" "run_ansible" {
  depends_on = [
    null_resource.provisioner,
    null_resource.copy_ansible_playbooks,
    aws_instance.master,
    aws_instance.worker,
    module.vpc,
    aws_instance.master,
    time_sleep.wait_for_master_init
  ]

  triggers = {
    always_run = timestamp()
  }

  connection {
    type        = "ssh"
    host        = aws_instance.master.public_ip
    user        = var.ssh_user
    private_key = tls_private_key.ssh.private_key_pem
  # private_key = aws_key_pair.k8_ssh.key_name
    insecure    = true
    agent         = false
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'starting ansible playbooks...'",
      "sleep 60 && ansible-playbook -i inventory ansible/play.yml ",
    ] 
  }
}