#!/bin/bash

# NOTE: this only fetches libs for use in unit tests here.
# Charms that depend on this library should fetch these libs themselves.

echo "WARNING: Charm interface libs are excluded from ASO python package."
charmcraft fetch-lib charms.nginx_ingress_integrator.v0.ingress
charmcraft fetch-lib charms.data_platform_libs.v0.database_requires
charmcraft fetch-lib charms.sunbeam_keystone_operator.v0.identity_service
charmcraft fetch-lib charms.sunbeam_keystone_operator.v0.cloud_credentials
charmcraft fetch-lib charms.sunbeam_rabbitmq_operator.v0.amqp
charmcraft fetch-lib charms.sunbeam_ovn_central_operator.v0.ovsdb
charmcraft fetch-lib charms.observability_libs.v0.kubernetes_service_patch
charmcraft fetch-lib charms.traefik_k8s.v0.ingress
echo "Copying libs to to unit_test dir"
rsync --recursive --delete lib/ unit_tests/lib/
