resource "namecheap_domain_records" "bodkys-house" {
  domain = "bodkys.house"
  email_type = "NONE"

  record {
    hostname = "portainer"
    type = "A"
    address = "185.11.255.12"
  }

  record {
    hostname = "ghostfolio"
    type = "A"
    address = "185.11.255.65"
  }

  record {
    hostname = "actual"
    type = "A"
    address = "185.11.255.65"
  }

  record {
    hostname = "traefik"
    type = "A"
    address = "185.11.255.65"
  }

  record {
    hostname = "heimdall"
    type = "A"
    address = "185.11.255.65"
  }

  record {
    hostname = "prometheus"
    type = "A"
    address = "185.11.255.65"
  }
}
