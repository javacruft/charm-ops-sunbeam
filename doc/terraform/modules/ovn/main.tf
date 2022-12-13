# Terraform module for deployment of OVN

terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.4.1"
    }
  }
}

resource "juju_application" "ovn-central" {
  name  = "ovn-central"
  trust = true
  model = var.model

  charm {
    name    = "ovn-central-k8s"
    channel = var.channel
    series  = "jammy"
  }

  units = var.scale
}

resource "juju_application" "ovn-relay" {
  count = var.relay != "" ? 1 : 0
  name  = "ovn-relay"
  trust = true
  model = var.model

  charm {
    name    = "ovn-relay-k8s"
    channel = var.channel
    series  = "jammy"
  }

  units = var.relay_scale
}


resource "juju_integration" "ovn-central-to-ovn-relay" {
  count = var.relay != "" ? 1 : 0
  model = var.model

  application {
    name     = juju_application.ovn-central.name
    endpoint = "ovsdb-cms"
  }

  application {
    name     = juju_application.ovn-relay[0].name
    endpoint = "ovsdb-cms"
  }
}

resource "juju_integration" "ovn-central-to-vault" {
  model = var.model

  application {
    name     = juju_application.ovn-central.name
    endpoint = "certificates"
  }

  application {
    name     = var.vault
    endpoint = "insecure-certificates"
  }
}

resource "juju_integration" "ovn-relay-to-vault" {
  count = var.relay != "" ? 1 : 0
  model = var.model

  application {
    name     = juju_application.ovn-relay[0].name
    endpoint = "certificates"
  }

  application {
    name     = var.vault
    endpoint = "insecure-certificates"
  }
}

