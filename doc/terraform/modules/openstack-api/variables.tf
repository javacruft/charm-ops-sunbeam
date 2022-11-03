variable "name" {
  description = "Name of the deployed operator"
  type        = string
}

variable "channel" {
  description = "Operator channel"
  default     = "latest/edge"
  type        = string
}

variable "scale" {
  description = "Scale of application"
  type        = number
  default     = 1
}

variable "charm" {
  description = "Charmed operator to deploy"
  type        = string
}

variable "model" {
  description = "Juju model to deploy resources in"
  type        = string
}

variable "rabbitmq" {
  description = "RabbitMQ operator to integrate with"
  type        = string
  default     = ""
}

variable "mysql" {
  description = "MySQL operator to integrate with"
  type        = string
}

variable "keystone" {
  description = "Keystone operator to integrate with"
  type        = string
  default     = ""
}

variable "ingress-internal" {
  description = "Ingress operator to integrate with for internal endpoints"
  type        = string
}

variable "ingress-public" {
  description = "Ingress operator to integrate with for public endpoints"
  type        = string
}