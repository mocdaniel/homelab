locals {
    entries = tomap({
      portainer    = "185.11.255.12"
      ghostfolio   = "185.11.255.65"
      traefik      = "185.11.255.65"
      prometheus   = "185.11.255.65"
      alertmanager = "185.11.255.65"
      umami        = "185.11.255.65"
      wud          = "185.11.255.65"
    })
}
resource "civo_dns_domain_name" "bodkys_house" {
  name = "bodkys.house"
}

resource "civo_dns_domain_record" "records" {
    for_each = local.entries

    domain_id  = civo_dns_domain_name.bodkys_house.id
    type       = "A"
    name       = each.key
    value      = each.value
    ttl        = 600
    depends_on = [civo_dns_domain_name.bodkys_house]
}
