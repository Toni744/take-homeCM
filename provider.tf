terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.14.0"
    }
  }
}

provider "helm" {
  # Configuration options
}

provider "aws" {
   region = "us-west-2"
}

provider "grafana" {
  url  = "http://grafana.example.com/"
  auth = var.grafana_auth
}
