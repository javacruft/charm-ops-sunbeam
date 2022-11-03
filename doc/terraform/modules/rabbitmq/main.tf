# Terraform module for deployment of RabbitMQ K8S

terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.4.1"
    }
  }
}

# core rabbitmq k8s operator
resource "juju_application" "rabbitmq" {
  name  = var.name
  trust = true
  model = var.model

  charm {
    name    = "rabbitmq-k8s"
    channel = var.channel
    series  = "jammy"
  }

  units = var.scale
}