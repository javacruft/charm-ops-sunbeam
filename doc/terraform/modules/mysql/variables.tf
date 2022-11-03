variable "name" {
  description = "Name of the deployed MySQL K8S operator"
  default     = "mysql"
  type        = string
}

variable "channel" {
  description = "MySQL K8S operator channel"
  default     = "edge"
  type        = string
}

variable "scale" {
  description = "Scale of MySQL K8S operator"
  default     = 1
}

variable "model" {
  description = "Juju model to deploy resources in"
}