terraform {
  required_providers {
    docker = {
      source  = "registry.opentofu.org/kreuzwerker/docker"
      version = "4.0.0"
    }
  }
}

provider "docker" { host = "unix:///var/run/user/1000/podman/podman.sock" }

resource "docker_image" "calibre" {
  name = "lscr.io/linuxserver/calibre-web:latest"
}

variable "TS_AUTHKEY" {
  type      = string
  sensitive = true
}

variable "CALIBRE_MOUNT_CONFIG" {
  type = string
}

variable "CALIBRE_MOUNT_LIBRARY" {
  type = string
}

module "tailscalify" {
  source       = "../.."
  service_name = "calibre"
  authkey      = var.TS_AUTHKEY
  ports = {
    http  = { service = 8083, tailscale = 80 } // kobo sync requires http support
    https = { service = 8083, tailscale = 443 }
  }
}

resource "docker_container" "calibre" {
  name       = "calibre"
  hostname   = "calibre"
  image      = docker_image.calibre.image_id
  depends_on = [module.tailscalify.container_name]
  restart    = "unless-stopped"
  networks_advanced {
    name    = module.tailscalify.network_name
    aliases = [module.tailscalify.container_network_alias]
  }
  ports {
    internal = 8083
    external = 8083
  }
  mounts {
    type   = "bind"
    source = var.CALIBRE_MOUNT_CONFIG
    target = "/config"
  }
  mounts {
    type   = "bind"
    source = var.CALIBRE_MOUNT_LIBRARY
    target = "/books"
  }
}
