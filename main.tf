resource "hostinger_vps_ssh_key" "ssh_key" {
  name = "main-ssh-key"
  key  = file("ssh_key.pub")
}

resource "hostinger_vps_post_install_script" "setup" {
  name    = "setup-script"
  content = file("post_install.sh")
}

resource "hostinger_vps" "portainer_vps" {
  plan                   = "hostingercom-vps-kvm1-usd-1m"
  data_center_id         = 13
  template_id            = 1002
  hostname               = "portainer.elladan.com.br"
  password               = var.hostinger_vps_password
  ssh_key_ids            = [hostinger_vps_ssh_key.ssh_key.id]
  post_install_script_id = hostinger_vps_post_install_script.setup.id
}

output "vps_ip" {
  value = hostinger_vps.portainer_vps.ipv4_address
}

