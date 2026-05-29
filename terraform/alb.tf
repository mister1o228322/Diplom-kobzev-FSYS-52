# Target Group
resource "yandex_alb_target_group" "web" {
  name = "web-target-group"

  target {
    subnet_id = yandex_vpc_subnet.private-a.id
    ip_address = yandex_compute_instance.web-a.network_interface[0].ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.private-b.id
    ip_address = yandex_compute_instance.web-b.network_interface[0].ip_address
  }
}

# Backend Group
resource "yandex_alb_backend_group" "web" {
  name = "web-backend-group"

  http_backend {
    name = "web-backend"
    weight = 1
    port = 80
    target_group_ids = [yandex_alb_target_group.web.id]
    healthcheck {
      timeout = "10s"
      interval = "2s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

# HTTP Router
resource "yandex_alb_http_router" "web" {
  name = "web-router"
}

# Virtual Host and Route
resource "yandex_alb_virtual_host" "web" {
  name = "web-host"
  http_router_id = yandex_alb_http_router.web.id

  route {
    name = "main-route"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
        timeout = "60s"
      }
    }
  }
}

# Load Balancer
resource "yandex_alb_load_balancer" "web" {
  name = "web-load-balancer"
  network_id = yandex_vpc_network.diploma.id

  allocation_policy {
    location {
      zone_id = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public.id
    }
  }

  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web.id
      }
    }
  }
}

output "lb_ip" {
  value = yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}
