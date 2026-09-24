variable "customer_gateway_id" {
  default     = null
  description = "The ID of the customer gateway this VPN connection terminates at."
}

variable "type" {
  default     = "ipsec.1"
  description = "VPN connection type. AWS currently only accepts 'ipsec.1'."
}

variable "transit_gateway_id" {
  default     = null
  description = "The ID of the Transit Gateway to attach this VPN connection to. Mutually exclusive with vpn_gateway_id — exactly one is required."
}

variable "vpn_gateway_id" {
  default     = null
  description = "The ID of the (classic) virtual private gateway to attach this VPN connection to. Mutually exclusive with transit_gateway_id — exactly one is required."

  validation {
    condition     = (var.transit_gateway_id != null) != (var.vpn_gateway_id != null)
    error_message = "Exactly one of transit_gateway_id or vpn_gateway_id is required."
  }
}

variable "static_routes_only" {
  default     = null
  description = "Whether this connection uses static routes only, instead of BGP. If null, AWS's own default (false, BGP) applies."
}

variable "static_routes" {
  default     = []
  description = "Destination CIDR blocks to route over this VPN connection. Only meaningful when static_routes_only is true — a BGP connection learns routes dynamically instead."
}

variable "enable_acceleration" {
  default     = null
  description = "Whether to use AWS Global Accelerator for this connection's tunnel endpoints. If null, AWS's own default (false) applies."
}

variable "local_ipv4_network_cidr" {
  default     = null
  description = "The CIDR on the AWS side of the tunnel that can send traffic over it. If null, AWS's own default (0.0.0.0/0) applies."
}

variable "remote_ipv4_network_cidr" {
  default     = null
  description = "The CIDR on the customer-gateway side of the tunnel that can send traffic over it. If null, AWS's own default (0.0.0.0/0) applies."
}

variable "local_ipv6_network_cidr" {
  default     = null
  description = "The IPv6 CIDR on the AWS side of the tunnel that can send traffic over it. Only used when tunnel_inside_ip_version is 'ipv6'."
}

variable "remote_ipv6_network_cidr" {
  default     = null
  description = "The IPv6 CIDR on the customer-gateway side of the tunnel that can send traffic over it. Only used when tunnel_inside_ip_version is 'ipv6'."
}

variable "tunnel_inside_ip_version" {
  default     = null
  description = "IP version for the tunnels' inside addresses ('ipv4' or 'ipv6'). If null, AWS's own default (ipv4) applies."
}

variable "outside_ip_address_type" {
  default     = null
  description = "IP address type for the tunnels' outside addresses ('PublicIpv4' or 'PrivateIpv4', the latter only for a transport Transit Gateway attachment). If null, AWS's own default (PublicIpv4) applies."
}

variable "tunnel1_options" {
  default     = {}
  description = "Per-tunnel configuration for tunnel 1. Every field is optional and defaults to AWS's own value when left unset — set only what needs to differ from that default (a specific inside CIDR, a fixed pre-shared key, restricted IKE/encryption negotiation for a compliance requirement, and so on)."
  type = object({
    inside_cidr                     = optional(string)
    inside_ipv6_cidr                = optional(string)
    preshared_key                   = optional(string)
    dpd_timeout_action              = optional(string)
    dpd_timeout_seconds             = optional(number)
    enable_tunnel_lifecycle_control = optional(bool)
    ike_versions                    = optional(list(string))
    phase1_dh_group_numbers         = optional(list(number))
    phase1_encryption_algorithms    = optional(list(string))
    phase1_integrity_algorithms     = optional(list(string))
    phase1_lifetime_seconds         = optional(number)
    phase2_dh_group_numbers         = optional(list(number))
    phase2_encryption_algorithms    = optional(list(string))
    phase2_integrity_algorithms     = optional(list(string))
    phase2_lifetime_seconds         = optional(number)
    rekey_fuzz_percentage           = optional(number)
    rekey_margin_time_seconds       = optional(number)
    replay_window_size              = optional(number)
    startup_action                  = optional(string)
  })
}

variable "tunnel2_options" {
  default     = {}
  description = "Per-tunnel configuration for tunnel 2. Same shape as tunnel1_options — AWS's two tunnels are configured identically in structure, for redundancy across two separate endpoints."
  type = object({
    inside_cidr                     = optional(string)
    inside_ipv6_cidr                = optional(string)
    preshared_key                   = optional(string)
    dpd_timeout_action              = optional(string)
    dpd_timeout_seconds             = optional(number)
    enable_tunnel_lifecycle_control = optional(bool)
    ike_versions                    = optional(list(string))
    phase1_dh_group_numbers         = optional(list(number))
    phase1_encryption_algorithms    = optional(list(string))
    phase1_integrity_algorithms     = optional(list(string))
    phase1_lifetime_seconds         = optional(number)
    phase2_dh_group_numbers         = optional(list(number))
    phase2_encryption_algorithms    = optional(list(string))
    phase2_integrity_algorithms     = optional(list(string))
    phase2_lifetime_seconds         = optional(number)
    rekey_fuzz_percentage           = optional(number)
    rekey_margin_time_seconds       = optional(number)
    replay_window_size              = optional(number)
    startup_action                  = optional(string)
  })
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the VPN connection."
}
