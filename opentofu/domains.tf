resource "namecheap_domain_records" "bodkys-house" {
  domain = "bodkys.house"
  email_type = "NONE"

  record {
    hostname = "portainer"
    type = "A"
    address = "185.11.255.12"
  }
}
