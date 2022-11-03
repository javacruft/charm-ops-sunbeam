# Terraform module for deployment of MySQL K8S

terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.4.1"
    }
  }
}

# core mysql k8s operator
resource "juju_application" "mysql" {
  name  = var.name
  trust = true
  model = var.model

  charm {
    name    = "mysql-k8s"
    channel = var.channel
  }

  units = var.scale
}