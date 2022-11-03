# Terraform manifest for deployment of Sunbeam

terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.4.1"
    }
  }
}

provider "juju" {}

# model:sunbeam
# juju add-model sunbeam
resource "juju_model" "sunbeam" {
  name = "sunbeam"

  cloud {
    name   = "microk8s"
    region = "localhost"
  }
}

module "placement-mysql" {
  source  = "./modules/mysql"
  model   = juju_model.sunbeam.name
  name    = "placement-mysql"
  channel = var.mysql_channel
}

module "glance-mysql" {
  source  = "./modules/mysql"
  model   = juju_model.sunbeam.name
  name    = "glance-mysql"
  channel = var.mysql_channel
}

module "keystone-mysql" {
  source  = "./modules/mysql"
  model   = juju_model.sunbeam.name
  name    = "keystone-mysql"
  channel = var.mysql_channel
}

module "nova-mysql" {
  source  = "./modules/mysql"
  model   = juju_model.sunbeam.name
  name    = "nova-mysql"
  channel = var.mysql_channel
}

module "neutron-mysql" {
  source  = "./modules/mysql"
  model   = juju_model.sunbeam.name
  name    = "neutron-mysql"
  channel = var.mysql_channel
}

module "rabbitmq" {
  source  = "./modules/rabbitmq"
  model   = juju_model.sunbeam.name
  scale   = 3
  channel = var.rabbitmq_channel
}

module "glance" {
  source           = "./modules/openstack-api"
  charm            = "glance-k8s"
  name             = "glance"
  model            = juju_model.sunbeam.name
  channel          = var.openstack_channel
  rabbitmq         = module.rabbitmq.name
  mysql            = module.glance-mysql.name
  keystone         = module.keystone.name
  ingress-internal = juju_application.traefik-internal.name
  ingress-public   = juju_application.traefik-public.name
}

module "keystone" {
  source           = "./modules/openstack-api"
  charm            = "keystone-k8s"
  name             = "keystone"
  model            = juju_model.sunbeam.name
  channel          = var.openstack_channel
  mysql            = module.keystone-mysql.name
  ingress-internal = juju_application.traefik-internal.name
  ingress-public   = juju_application.traefik-public.name
}

module "nova" {
  source           = "./modules/openstack-api"
  charm            = "nova-k8s"
  name             = "nova"
  model            = juju_model.sunbeam.name
  channel          = var.openstack_channel
  rabbitmq         = module.rabbitmq.name
  mysql            = module.nova-mysql.name
  keystone         = module.keystone.name
  ingress-internal = juju_application.traefik-internal.name
  ingress-public   = juju_application.traefik-public.name
  scale            = 3

}

# TODO: specific module for nova?
# juju integrate nova:api-database nova-mysql
resource "juju_integration" "nova-api-to-mysql" {
  model = juju_model.sunbeam.name

  application {
    name     = module.nova.name
    endpoint = "api-database"
  }

  application {
    name     = module.nova-mysql.name
    endpoint = "database"
  }
}

# juju integrate nova:cell-database nova-mysql
resource "juju_integration" "nova-cell-to-mysql" {
  model = juju_model.sunbeam.name

  application {
    name     = module.nova.name
    endpoint = "cell-database"
  }

  application {
    name     = module.nova-mysql.name
    endpoint = "database"
  }
}

module "neutron" {
  source           = "./modules/openstack-api"
  charm            = "neutron-k8s"
  name             = "neutron"
  model            = juju_model.sunbeam.name
  channel          = var.openstack_channel
  rabbitmq         = module.rabbitmq.name
  mysql            = module.neutron-mysql.name
  keystone         = module.keystone.name
  ingress-internal = juju_application.traefik-internal.name
  ingress-public   = juju_application.traefik-public.name
  scale            = 3

}

module "placement" {
  source           = "./modules/openstack-api"
  charm            = "placement-k8s"
  name             = "placement"
  model            = juju_model.sunbeam.name
  channel          = var.openstack_channel
  mysql            = module.neutron-mysql.name
  keystone         = module.keystone.name
  ingress-internal = juju_application.traefik-internal.name
  ingress-public   = juju_application.traefik-public.name
  scale            = 3
}

# application:traefik
# juju deploy --channel latest/edge --trust traefik-k8s traefik-internal
resource "juju_application" "traefik-internal" {
  name  = "traefik-internal"
  trust = true
  model = juju_model.sunbeam.name

  charm {
    name    = "traefik-k8s"
    channel = "1.0/stable"
  }

  units = 3
}


# application:traefik
# juju deploy --channel latest/edge --trust traefik-k8s traefik-public
resource "juju_application" "traefik-public" {
  name  = "traefik-public"
  trust = true
  model = juju_model.sunbeam.name

  charm {
    name    = "traefik-k8s"
    channel = "1.0/stable"
  }

  units = 3
}


# application:Vault
# juju deploy --channel latest/stable --trust icey-vault-k8s vault
resource "juju_application" "vault" {
  name  = "vault"
  trust = true
  model = juju_model.sunbeam.name

  charm {
    name    = "icey-vault-k8s"
    channel = "latest/stable"
  }
}

module "ovn" {
  source      = "./modules/ovn"
  model       = juju_model.sunbeam.name
  channel     = var.ovn_channel
  scale       = 3
  relay       = true
  relay_scale = 6
  vault       = juju_application.vault.name
}



# juju integrate ovn-central neutron
resource "juju_integration" "ovn-central-to-neutron" {
  model = juju_model.sunbeam.name

  application {
    name     = module.ovn.name
    endpoint = "ovsdb-cms"
  }

  application {
    name     = module.neutron.name
    endpoint = "ovsdb-cms"
  }
}


# juju integrate neutron vault
resource "juju_integration" "neutron-to-vault" {
  model = juju_model.sunbeam.name

  application {
    name     = module.neutron.name
    endpoint = "certificates"
  }

  application {
    name     = juju_application.vault.name
    endpoint = "insecure-certificates"
  }
}

# juju integrate nova placement
resource "juju_integration" "nova-to-placement" {
  model = juju_model.sunbeam.name

  application {
    name     = module.nova.name
    endpoint = "placement"
  }

  application {
    name     = module.placement.name
    endpoint = "placement"
  }
}