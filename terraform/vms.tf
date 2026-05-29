# Bastion Host
resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd83vkt13re8v8cdapql"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/kobzev/.ssh/id_rsa.pub")}"
  }
}

# Веб-сервер A
resource "yandex_compute_instance" "web-a" {
  name        = "web-a"
  hostname    = "web-a"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd83vkt13re8v8cdapql"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-a.id
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/kobzev/.ssh/id_rsa.pub")}"
  }
}

# Веб-сервер B
resource "yandex_compute_instance" "web-b" {
  name        = "web-b"
  hostname    = "web-b"
  platform_id = "standard-v2"
  zone        = "ru-central1-b"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd83vkt13re8v8cdapql"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-b.id
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/kobzev/.ssh/id_rsa.pub")}"
  }
}
# Zabbix Server
resource "yandex_compute_instance" "zabbix7" {
  name        = "zabbix7"
  hostname    = "zabbix7"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd83vkt13re8v8cdapql"
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

# Elasticsearch ВМ (приватная, без внешнего IP)
resource "yandex_compute_instance" "elasticsearch" {
  name        = "elasticsearch"
  hostname    = "elasticsearch"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd83vkt13re8v8cdapql"
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-a.id
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/kobzev/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

# Kibana ВМ
resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  hostname    = "kibana"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd83vkt13re8v8cdapql"
      size     = 15
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/kobzev/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}
