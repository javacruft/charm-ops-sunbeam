output "name" {
  description = "Name of the deployed OVN central"
  value       = juju_application.ovn-central.name
}