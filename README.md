# terraform-aws-vpn-connection

Terraform module for a Site-to-Site VPN connection — two redundant
IPsec tunnels between AWS and a
[`terraform-aws-customer-gateway`](https://github.com/kn47ytv9mv/terraform-aws-customer-gateway),
attached to a Transit Gateway or a classic virtual private gateway.

## Cost

Site-to-Site VPN bills per connection-hour for as long as the
connection exists, plus standard data transfer rates for traffic that
crosses it. Both tunnels are included in that one charge — a
connection's second tunnel is redundancy, not a separate line item.
See AWS's [Site-to-Site VPN pricing](https://aws.amazon.com/vpn/pricing/)
page for current rates.

## Design

Requires exactly one of `transit_gateway_id` or `vpn_gateway_id` —
matching this family's Transit-Gateway-first design
([`terraform-aws-transit-gateway`](https://github.com/kn47ytv9mv/terraform-aws-transit-gateway)),
`transit_gateway_id` is the typical choice; `vpn_gateway_id` remains
for a classic per-VPC virtual private gateway setup.

Like `terraform-aws-direct-connect-gateway-association`'s trio, this
module needs no live, responding remote endpoint to create
successfully — the AWS side of a Site-to-Site VPN connection exists
independent of whether the customer gateway device ever answers, so it
is fully testable against real AWS without any on-premises hardware.
Static routes (`static_routes`, only meaningful when
`static_routes_only` is `true`) are bundled into this module rather
than split out, the same reasoning as this family's other
homogeneous-tuple route lists — nothing outside this module ever
references one specific route by its own ID.

`tunnel1_options`/`tunnel2_options` mirror AWS's two tunnels'
configuration exactly — every field optional, defaulting to AWS's own
value when left unset. Not modeled: per-tunnel CloudWatch logging
(`tunnel{1,2}_log_options`), a deliberately separate, less commonly
needed concern this module does not manage.

## Usage

Transit-Gateway-attached, BGP routing:

```hcl
module "vpn" {
  source = "kn47ytv9mv/vpn-connection/aws"

  customer_gateway_id = module.customer_gateway.id
  transit_gateway_id  = module.transit_gateway.id
}
```

Or directly from this repository, a classic virtual private gateway
with static routes:

```hcl
module "vpn" {
  source = "github.com/kn47ytv9mv/terraform-aws-vpn-connection"

  customer_gateway_id = module.customer_gateway.id
  vpn_gateway_id      = aws_vpn_gateway.example.id
  static_routes_only  = true
  static_routes       = ["10.0.0.0/16"]

  tunnel1_options = {
    preshared_key = var.tunnel1_preshared_key
  }
  tunnel2_options = {
    preshared_key = var.tunnel2_preshared_key
  }
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.9 |
| aws | ~> 6.61 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| customer_gateway_id | The ID of the customer gateway this VPN connection terminates at. | `null` | no |
| type | VPN connection type. AWS currently only accepts 'ipsec.1'. | `"ipsec.1"` | no |
| transit_gateway_id | The ID of the Transit Gateway to attach this VPN connection to. Mutually exclusive with vpn_gateway_id — exactly one is required. | `null` | no |
| vpn_gateway_id | The ID of the (classic) virtual private gateway to attach this VPN connection to. Mutually exclusive with transit_gateway_id — exactly one is required. | `null` | no |
| static_routes_only | Whether this connection uses static routes only, instead of BGP. If null, AWS's own default (false, BGP) applies. | `null` | no |
| static_routes | Destination CIDR blocks to route over this VPN connection. Only meaningful when static_routes_only is true — a BGP connection learns routes dynamically instead. | `[]` | no |
| enable_acceleration | Whether to use AWS Global Accelerator for this connection's tunnel endpoints. If null, AWS's own default (false) applies. | `null` | no |
| local_ipv4_network_cidr | The CIDR on the AWS side of the tunnel that can send traffic over it. If null, AWS's own default (0.0.0.0/0) applies. | `null` | no |
| remote_ipv4_network_cidr | The CIDR on the customer-gateway side of the tunnel that can send traffic over it. If null, AWS's own default (0.0.0.0/0) applies. | `null` | no |
| local_ipv6_network_cidr | The IPv6 CIDR on the AWS side of the tunnel that can send traffic over it. Only used when tunnel_inside_ip_version is 'ipv6'. | `null` | no |
| remote_ipv6_network_cidr | The IPv6 CIDR on the customer-gateway side of the tunnel that can send traffic over it. Only used when tunnel_inside_ip_version is 'ipv6'. | `null` | no |
| tunnel_inside_ip_version | IP version for the tunnels' inside addresses ('ipv4' or 'ipv6'). If null, AWS's own default (ipv4) applies. | `null` | no |
| outside_ip_address_type | IP address type for the tunnels' outside addresses ('PublicIpv4' or 'PrivateIpv4', the latter only for a transport Transit Gateway attachment). If null, AWS's own default (PublicIpv4) applies. | `null` | no |
| tunnel1_options | Per-tunnel configuration for tunnel 1. Every field is optional and defaults to AWS's own value when left unset — set only what needs to differ from that default (a specific inside CIDR, a fixed pre-shared key, restricted IKE/encryption negotiation for a compliance requirement, and so on). | `{}` | no |
| tunnel2_options | Per-tunnel configuration for tunnel 2. Same shape as tunnel1_options — AWS's two tunnels are configured identically in structure, for redundancy across two separate endpoints. | `{}` | no |
| tags | A map of tags to assign to the VPN connection. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The ID of the VPN connection. |
| arn | The ARN of the VPN connection. |
| transit_gateway_attachment_id | The ID of the underlying Transit Gateway attachment, when transit_gateway_id is set. Null otherwise. |
| customer_gateway_configuration | The connection's full configuration document, in the customer gateway vendor's native XML format — hand this to whoever configures the physical or virtual device at the other end. |
| tunnel1_address | The outside IP address of tunnel 1. |
| tunnel2_address | The outside IP address of tunnel 2. |

## License

MIT — see [LICENSE.md](LICENSE.md).
