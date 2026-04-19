variable "service_name" {
  description = "name of service to serve through tailscale"
  type        = string
}

variable "authkey" {
  description = "authkey for tailscale access"
  type        = string
  sensitive   = true
}

variable "ports" {
  description = "map of tailscale ports to serve grouped by port type (http,https,tcp,tls-terminated-tcp => {service,tailscale})"
  type = map(object({
    service   = number
    tailscale = number
  }))
  validation {
    condition     = length(var.ports) > 0
    error_message = "must set at least one set of ports"
  }
  validation {
    condition     = alltrue([for k in keys(var.ports) : contains(["http", "https", "tcp", "tls-terminated-tcp"], k)])
    error_message = "port type must be 'http,https,tcp,tls-terminated-tcp'"
  }
}
