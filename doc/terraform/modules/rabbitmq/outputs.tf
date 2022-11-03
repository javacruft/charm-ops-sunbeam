output "name" {
  description = "Name of the deployed RabbitMQ resource"
  value       = juju_application.rabbitmq.name
}