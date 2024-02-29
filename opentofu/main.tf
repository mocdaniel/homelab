terraform {
  required_providers {
    civo = {
      source = "civo/civo"
      version = "1.0.39"
    }
  }
}

provider "civo" {
  region = "FRA1"
}
