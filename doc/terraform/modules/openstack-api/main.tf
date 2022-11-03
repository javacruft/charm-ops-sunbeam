# Terraform module for deployment of OpenStack API services

terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.4.1"
    }
  }
}

resource "juju_application" "service" {
  name  = var.name
  trust = true
  model = var.model

  charm {
    name    = var.charm
    channel = var.channel
    series  = "jammy"
  }

  units = var.scale
}

resource "juju_integration" "service-to-mysql" {
  model = var.model

  application {
    name     = juju_application.service.name
    endpoint = "database"
  }

  application {
    name     = var.mysql
    endpoint = "database"
  }
}

# NOTE: this integration is optional
resource "juju_integration" "service-to-rabbitmq" {
  for_each = var.rabbitmq == "" ? {} : { target = var.rabbitmq }

  model = var.model

  application {
    name     = juju_application.service.name
    endpoint = "amqp"
  }

  application {
    name     = each.value
    endpoint = "amqp"
  }
}

# NOTE: this integration is optional
resource "juju_integration" "keystone-to-service" {
  for_each = var.keystone == "" ? {} : { target = var.keystone }
  model    = var.model

  application {
    name     = each.value
    endpoint = "identity-service"
  }

  application {
    name     = juju_application.service.name
    endpoint = "identity-service"
  }
}

# juju integrate traefik-public glance
resource "juju_integration" "traefik-public-to-service" {
  model = var.model

  application {
    name     = var.ingress-public
    endpoint = "ingress"
  }

  application {
    name     = juju_application.service.name
    endpoint = "ingress-public"
  }
}

# juju integrate traefik-internal glance
resource "juju_integration" "traefik-internal-to-service" {
  model = var.model

  application {
    name     = var.ingress-internal
    endpoint = "ingress"
  }

  application {
    name     = juju_application.service.name
    endpoint = "ingress-internal"
  }
}