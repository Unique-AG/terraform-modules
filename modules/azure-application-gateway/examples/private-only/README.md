# Private-only Application Gateway example

Terraform example for an Application Gateway with no public IP. Validated as a module example only — not deployed to hello-azure-v2 or any Unique tenant environment at the time of writing.

## References

- [Private Application Gateway GA announcement](https://techcommunity.microsoft.com/blog/azureinfrastructureblog/general-availability-of-private-application-gateway-on-azure-application-gate/4508294) (April 2026)
- [Azure docs — private deployment](https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-private-deployment)
- [AGIC annotations — use-private-ip](https://azure.github.io/application-gateway-kubernetes-ingress/annotations/#use-private-ip)

## Prerequisites

Consumer-owned resources (see [DESIGN.md](../../../../DESIGN.md), *Low coupling*). Full platform requirements are in the [Azure docs](https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-private-deployment); the module enforces SKU and IP allocation via `lifecycle.precondition` blocks.

| Requirement | Notes |
|-------------|-------|
| Subscription feature `EnableApplicationGatewayNetworkIsolation` | One-time per subscription; register before first private-only gateway |
| SKU `Standard_v2` or `WAF_v2` | Enforced by module precondition |
| Subnet delegated to `Microsoft.Network/applicationGateways` | Mandatory for all new AppGW v2 since 2025-05-05 |
| NSG / routing / DNS | See Azure docs for inbound, outbound, and internal DNS publishing |
| AGIC ≥ 1.7.x (if using AGIC) | Set `appgw.usePrivateIP: true` in Helm values |

## Configuration

Set `public_frontend_ip_configuration = null` and provide `private_frontend_ip_configuration`:

```hcl
public_frontend_ip_configuration = null

private_frontend_ip_configuration = {
  private_ip_address = "10.0.0.5"
  address_allocation = "Static"   # or "Dynamic" — omit private_ip_address when Dynamic
  subnet_resource_id = azurerm_subnet.appgw.id
}
```

For `address_allocation = "Dynamic"`, `private_ip_address` must be `null`. The assigned IP is not exposed as a Terraform attribute — query Azure after apply.

## AGIC

```yaml
appgw:
  usePrivateIP: true
```

Per-ingress override: `appgw.ingress.kubernetes.io/use-private-ip: "true"`.

## Upgrade from `5.x`

**Public-only callers:** bump the module version; no input changes.

**Dual-stack callers:** rename one field:

```diff
 private_frontend_ip_configuration = {
-  ip_address_resource_id = "10.0.0.5"
+  private_ip_address     = "10.0.0.5"
   address_allocation     = "Static"
   subnet_resource_id     = azurerm_subnet.appgw.id
 }
```

Drop `public_frontend_ip_configuration.ip_address` if present — it was never read by the module.

## Brownfield: public → private-only

Azure does **not** support removing a public frontend in place. Migration is deploy-new + DNS cutover:

1. Provision a new private-only gateway (different `name_prefix`, dedicated subnet).
2. Dual-publish DNS with a low TTL.
3. Re-point AGIC at the new gateway resource ID.
4. Validate from inside the VNet, cut over DNS, decommission the old gateway and its public IP.

## Troubleshooting

| Symptom | Likely cause |
|---------|--------------|
| `ApplicationGatewayFrontendIpCannotHavePublicIpAndSubnet` | Feature not registered, or in-place public→private removal |
| SKU validation error | Non-v2 SKU or feature not registered |
| Subnet delegation error | Missing `Microsoft.Network/applicationGateways` delegation |
| 502/503 from backends | NSG blocking backend traffic or probes |
| Diagnostics not flowing | NSG outbound missing `AzureMonitor` |
| AGIC targets non-existent public frontend | AGIC < 1.7 or `usePrivateIP` not set |

## Known limitations

See the [Azure docs](https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-private-deployment) for the full list. Notable ones:

- [Private Link](https://learn.microsoft.com/en-us/azure/application-gateway/private-link) is unsupported with private-only.
- Let's Encrypt HTTP-01 is impractical without a public listener — this example sets `waf_custom_rules_allowed_https_challenges = false`.
- In-place removal of an existing public frontend is rejected by Azure.
