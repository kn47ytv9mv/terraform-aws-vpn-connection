resource "aws_vpn_connection" "resource" {
  customer_gateway_id = var.customer_gateway_id
  type                = var.type
  transit_gateway_id  = var.transit_gateway_id
  vpn_gateway_id      = var.vpn_gateway_id
  static_routes_only  = var.static_routes_only

  enable_acceleration = var.enable_acceleration

  local_ipv4_network_cidr  = var.local_ipv4_network_cidr
  remote_ipv4_network_cidr = var.remote_ipv4_network_cidr
  local_ipv6_network_cidr  = var.local_ipv6_network_cidr
  remote_ipv6_network_cidr = var.remote_ipv6_network_cidr

  tunnel_inside_ip_version = var.tunnel_inside_ip_version
  outside_ip_address_type  = var.outside_ip_address_type

  tunnel1_inside_cidr                     = var.tunnel1_options.inside_cidr
  tunnel1_inside_ipv6_cidr                = var.tunnel1_options.inside_ipv6_cidr
  tunnel1_preshared_key                   = var.tunnel1_options.preshared_key
  tunnel1_dpd_timeout_action              = var.tunnel1_options.dpd_timeout_action
  tunnel1_dpd_timeout_seconds             = var.tunnel1_options.dpd_timeout_seconds
  tunnel1_enable_tunnel_lifecycle_control = var.tunnel1_options.enable_tunnel_lifecycle_control
  tunnel1_ike_versions                    = var.tunnel1_options.ike_versions
  tunnel1_phase1_dh_group_numbers         = var.tunnel1_options.phase1_dh_group_numbers
  tunnel1_phase1_encryption_algorithms    = var.tunnel1_options.phase1_encryption_algorithms
  tunnel1_phase1_integrity_algorithms     = var.tunnel1_options.phase1_integrity_algorithms
  tunnel1_phase1_lifetime_seconds         = var.tunnel1_options.phase1_lifetime_seconds
  tunnel1_phase2_dh_group_numbers         = var.tunnel1_options.phase2_dh_group_numbers
  tunnel1_phase2_encryption_algorithms    = var.tunnel1_options.phase2_encryption_algorithms
  tunnel1_phase2_integrity_algorithms     = var.tunnel1_options.phase2_integrity_algorithms
  tunnel1_phase2_lifetime_seconds         = var.tunnel1_options.phase2_lifetime_seconds
  tunnel1_rekey_fuzz_percentage           = var.tunnel1_options.rekey_fuzz_percentage
  tunnel1_rekey_margin_time_seconds       = var.tunnel1_options.rekey_margin_time_seconds
  tunnel1_replay_window_size              = var.tunnel1_options.replay_window_size
  tunnel1_startup_action                  = var.tunnel1_options.startup_action

  tunnel2_inside_cidr                     = var.tunnel2_options.inside_cidr
  tunnel2_inside_ipv6_cidr                = var.tunnel2_options.inside_ipv6_cidr
  tunnel2_preshared_key                   = var.tunnel2_options.preshared_key
  tunnel2_dpd_timeout_action              = var.tunnel2_options.dpd_timeout_action
  tunnel2_dpd_timeout_seconds             = var.tunnel2_options.dpd_timeout_seconds
  tunnel2_enable_tunnel_lifecycle_control = var.tunnel2_options.enable_tunnel_lifecycle_control
  tunnel2_ike_versions                    = var.tunnel2_options.ike_versions
  tunnel2_phase1_dh_group_numbers         = var.tunnel2_options.phase1_dh_group_numbers
  tunnel2_phase1_encryption_algorithms    = var.tunnel2_options.phase1_encryption_algorithms
  tunnel2_phase1_integrity_algorithms     = var.tunnel2_options.phase1_integrity_algorithms
  tunnel2_phase1_lifetime_seconds         = var.tunnel2_options.phase1_lifetime_seconds
  tunnel2_phase2_dh_group_numbers         = var.tunnel2_options.phase2_dh_group_numbers
  tunnel2_phase2_encryption_algorithms    = var.tunnel2_options.phase2_encryption_algorithms
  tunnel2_phase2_integrity_algorithms     = var.tunnel2_options.phase2_integrity_algorithms
  tunnel2_phase2_lifetime_seconds         = var.tunnel2_options.phase2_lifetime_seconds
  tunnel2_rekey_fuzz_percentage           = var.tunnel2_options.rekey_fuzz_percentage
  tunnel2_rekey_margin_time_seconds       = var.tunnel2_options.rekey_margin_time_seconds
  tunnel2_replay_window_size              = var.tunnel2_options.replay_window_size
  tunnel2_startup_action                  = var.tunnel2_options.startup_action

  tags = var.tags
}

resource "aws_vpn_connection_route" "resource" {
  for_each = toset(var.static_routes)

  vpn_connection_id      = aws_vpn_connection.resource.id
  destination_cidr_block = each.key
}

output "id" {
  description = "The ID of the VPN connection."
  value       = aws_vpn_connection.resource.id
}

output "arn" {
  description = "The ARN of the VPN connection."
  value       = aws_vpn_connection.resource.arn
}

output "transit_gateway_attachment_id" {
  description = "The ID of the underlying Transit Gateway attachment, when transit_gateway_id is set. Null otherwise."
  value       = aws_vpn_connection.resource.transit_gateway_attachment_id
}

output "customer_gateway_configuration" {
  description = "The connection's full configuration document, in the customer gateway vendor's native XML format — hand this to whoever configures the physical or virtual device at the other end."
  value       = aws_vpn_connection.resource.customer_gateway_configuration
  sensitive   = true
}

output "tunnel1_address" {
  description = "The outside IP address of tunnel 1."
  value       = aws_vpn_connection.resource.tunnel1_address
}

output "tunnel2_address" {
  description = "The outside IP address of tunnel 2."
  value       = aws_vpn_connection.resource.tunnel2_address
}
