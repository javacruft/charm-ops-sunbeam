output "name" {
  description = "Name of the deployed MYSQL resource"
  value       = juju_application.mysql.name
}