locals {
  container_name          = "tailscale-${var.service_name}"
  network_name            = "tailscale-${var.service_name}"
  container_network_alias = "${var.service_name}-container"
}

resource "docker_image" "tailscale" {
  name = "tailscale/tailscale:latest"
}

resource "docker_network" "tailscale" {
  name = local.network_name
}

resource "docker_volume" "tailscale" {
  name = local.container_name
}

resource "docker_container" "tailscale" {
  name       = local.container_name
  hostname   = local.container_name
  image      = docker_image.tailscale.image_id
  restart    = "unless-stopped"
  env        = ["TS_AUTHKEY=${var.authkey}"]
  entrypoint = ["/bin/sh"]
  command = [
    "-c",
    join(
      "\n",
      [
        "tailscaled --tun=userspace-networking &",
        "sleep 5",
        "tailscale up --authkey=\"$TS_AUTHKEY\"",
      ],
      [for port_type, ports in var.ports : "tailscale serve --${port_type}=${ports.tailscale} --service=\"svc:${var.service_name}\" http://${local.container_network_alias}:${ports.service}"],
      ["wait"]
    )
  ]
  networks_advanced {
    name = docker_network.tailscale.name
  }
  mounts {
    type   = "volume"
    source = docker_volume.tailscale.name
    target = "/var/lib/tailscale"
  }
  healthcheck {
    test         = ["CMD", "tailscale", "status"]
    interval     = "30s"
    timeout      = "10s"
    retries      = 3
    start_period = "15s"
  }
}

