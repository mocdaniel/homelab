terraform {
  required_providers {
    namecheap = {
      source = "namecheap/namecheap"
      version = "2.1.1"
    }
  }
}

provider "namecheap" {
}
