mock_provider "aws" {
}

run "rejects_neither_gateway_variant" {
  command = plan

  variables {
    customer_gateway_id = "cgw-12345"
  }

  expect_failures = [var.vpn_gateway_id]
}

run "rejects_both_gateway_variants" {
  command = plan

  variables {
    customer_gateway_id = "cgw-12345"
    transit_gateway_id  = "tgw-12345"
    vpn_gateway_id      = "vgw-12345"
  }

  expect_failures = [var.vpn_gateway_id]
}

run "transit_gateway_attachment_passes_through" {
  command = plan

  variables {
    customer_gateway_id = "cgw-12345"
    transit_gateway_id  = "tgw-12345"
  }

  assert {
    condition     = aws_vpn_connection.resource.customer_gateway_id == "cgw-12345"
    error_message = "customer_gateway_id should pass through unchanged."
  }

  assert {
    condition     = aws_vpn_connection.resource.transit_gateway_id == "tgw-12345"
    error_message = "transit_gateway_id should pass through unchanged."
  }

  assert {
    condition     = aws_vpn_connection.resource.type == "ipsec.1"
    error_message = "type should default to 'ipsec.1'."
  }
}

run "classic_vpn_gateway_passes_through" {
  command = plan

  variables {
    customer_gateway_id = "cgw-12345"
    vpn_gateway_id      = "vgw-12345"
    static_routes_only  = true
  }

  assert {
    condition     = aws_vpn_connection.resource.vpn_gateway_id == "vgw-12345"
    error_message = "vpn_gateway_id should pass through unchanged."
  }

  assert {
    condition     = aws_vpn_connection.resource.static_routes_only == true
    error_message = "static_routes_only should pass through unchanged."
  }
}

run "tunnel_options_pass_through" {
  command = plan

  variables {
    customer_gateway_id = "cgw-12345"
    transit_gateway_id  = "tgw-12345"
    tunnel1_options = {
      inside_cidr             = "169.254.10.0/30"
      preshared_key           = "example.psk.1"
      ike_versions            = ["ikev2"]
      phase1_dh_group_numbers = [14]
    }
    tunnel2_options = {
      inside_cidr   = "169.254.11.0/30"
      preshared_key = "example.psk.2"
    }
  }

  assert {
    condition     = aws_vpn_connection.resource.tunnel1_inside_cidr == "169.254.10.0/30"
    error_message = "tunnel1_options.inside_cidr should pass through unchanged."
  }

  assert {
    condition     = aws_vpn_connection.resource.tunnel1_preshared_key == "example.psk.1"
    error_message = "tunnel1_options.preshared_key should pass through unchanged."
  }

  assert {
    condition     = tolist(aws_vpn_connection.resource.tunnel1_ike_versions)[0] == "ikev2"
    error_message = "tunnel1_options.ike_versions should pass through unchanged."
  }

  assert {
    condition     = aws_vpn_connection.resource.tunnel2_inside_cidr == "169.254.11.0/30"
    error_message = "tunnel2_options.inside_cidr should pass through unchanged."
  }
}

run "static_routes_create_one_route_resource_each" {
  command = plan

  variables {
    customer_gateway_id = "cgw-12345"
    vpn_gateway_id      = "vgw-12345"
    static_routes_only  = true
    static_routes       = ["10.0.0.0/16", "10.1.0.0/16"]
  }

  assert {
    condition     = length(aws_vpn_connection_route.resource) == 2
    error_message = "Two static_routes entries should create exactly two aws_vpn_connection_route resources."
  }
}

run "tags_pass_through" {
  command = plan

  variables {
    customer_gateway_id = "cgw-12345"
    transit_gateway_id  = "tgw-12345"
    tags = {
      Name = "example-vpn"
    }
  }

  assert {
    condition     = aws_vpn_connection.resource.tags.Name == "example-vpn"
    error_message = "tags should pass through unchanged."
  }
}

run "readme_transit_gateway_example" {
  command = plan

  variables {
    customer_gateway_id = "cgw-12345"
    transit_gateway_id  = "tgw-12345"
  }
}

run "readme_static_routes_example" {
  command = plan

  variables {
    customer_gateway_id = "cgw-12345"
    vpn_gateway_id      = "vgw-12345"
    static_routes_only  = true
    static_routes       = ["10.0.0.0/16"]
  }
}
