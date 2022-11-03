variable "name" {
  description = "Name of the deployed RabbitMQ K8S operator"
  default     = "rabbitmq"
  type        = string
}

variable "channel" {
  description = "RabbitMQ K8S charm channel"
  default     = "latest/edge"
  type        = string
}

variable "scale" {
  description = "Scale of RabbitMQ charm"
  default     = 1
}

variable "model" {
  description = "Juju model to deploy resources in"
}