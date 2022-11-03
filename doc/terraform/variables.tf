variable "openstack_channel" {
  description = "OpenStack channel for deployment"
  default     = "yoga/edge"
}

variable "mysql_channel" {
  description = "Operator channel for MySQL deployment"
  default     = "edge"
}

variable "rabbitmq_channel" {
  description = "Operator channel for RabbitMQ deployment"
  default     = "3.11/edge"
}

variable "ovn_channel" {
  description = "Operator channel for OVN deployment"
  default     = "22.03/edge"
}
