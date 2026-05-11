# terraform-docker-tailscalify

Simple module to serve anything as a tailscale service.

## Usage

```hcl
module "tailscalify" {
  source       = "joanofxyz/tailscalify/docker"
  version      = "0.1.2"
  service_name = "<service_name>"
  authkey      = var.TS_AUTHKEY
  ports        = {
    http = { service = 8083, tailscale = 80 }
    https = { service = 8083, tailscale = 443 }
  }
}
```
