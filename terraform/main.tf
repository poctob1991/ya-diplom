resource "yandex_vpc_address" "vm_addresses" {
  count = 2
  #deletion_protection = true
  name  = "db-${count.index + 1}-static-ip"
  
  external_ipv4_address {
    zone_id = var.yc_zone
  }
}

resource "yandex_compute_instance" "mediawiki" {
  depends_on = [yandex_compute_instance.proxy]
  
  count       = 2
  name        = "mediawiki-${count.index + 1}"
  platform_id = "standard-v2"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd80jhic7e80h9s58v62"
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
    ip_address = "192.168.10.${count.index + 10}"
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file(var.ssh_public_key_path)}"
  }
  
  timeouts {
    create = "20m"  
  }
}

resource "yandex_compute_instance" "db_master" {
  name        = "db-master"
  platform_id = "standard-v2"
  zone        = var.yc_zone

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = "fd80jhic7e80h9s58v62"
      size     = 30
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
    nat_ip_address = yandex_vpc_address.vm_addresses[0].external_ipv4_address[0].address
    ip_address = "192.168.10.12"
    ipv6      = false
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file(var.ssh_public_key_path)}"
  }
   
  timeouts {
    create = "20m"  
  }
}

resource "yandex_compute_instance" "db_replica" {
    depends_on = [yandex_compute_instance.db_master]
  
  name        = "db-replica"
  platform_id = "standard-v2"
  zone        = var.yc_zone

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = "fd80jhic7e80h9s58v62"
      size     = 30
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
    nat_ip_address = yandex_vpc_address.vm_addresses[1].external_ipv4_address[0].address
    ip_address = "192.168.10.13"
    ipv6      = false
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file(var.ssh_public_key_path)}"
  }
   
  timeouts {
    create = "20m" 
  }
}

resource "yandex_compute_instance" "proxy" {
  
  depends_on = [yandex_compute_instance.db_replica]
  
  name        = "proxy"
  platform_id = "standard-v2"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd80jhic7e80h9s58v62"
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
    ip_address = "192.168.10.14"
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file(var.ssh_public_key_path)}"
  }
   
  timeouts {
    create = "20m"  
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "mediawiki-network"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "mediawiki-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    mediawiki_names  = yandex_compute_instance.mediawiki[*].name,
    mediawiki_ip    = yandex_compute_instance.mediawiki[*].network_interface.0.ip_address,
    mediawiki_ips    = yandex_compute_instance.mediawiki[*].network_interface.0.nat_ip_address,
    
    db_1_names = yandex_compute_instance.db_master.name,
    db_1_ip = yandex_compute_instance.db_master.network_interface.0.ip_address,
    db_1_ips = yandex_compute_instance.db_master.network_interface.0.nat_ip_address,
    
    
    db_2_names = yandex_compute_instance.db_replica.name,
    db_2_ip = yandex_compute_instance.db_replica.network_interface.0.ip_address,
    db_2_ips = yandex_compute_instance.db_replica.network_interface.0.nat_ip_address,
    
    proxy_names  = yandex_compute_instance.proxy.name,
    proxy_ip      = yandex_compute_instance.proxy.network_interface.0.ip_address,
    proxy_ips      = yandex_compute_instance.proxy.network_interface.0.nat_ip_address,
    
    ssh_user   = var.vm_user
  })
  filename = "../ansible/inventory.yml"
}
