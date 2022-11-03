output "name" {
  description = "Name of the deployed operator"
  value       = juju_application.service.name
}