variable "channel" {
  description = "Operator channel"
  default     = "22.03/edge"
  type        = string
}

variable "scale" {
  description = "Scale of OVN central application"
  type        = number
  default     = 1
}

variable "model" {
  description = "Juju model to deploy resources in"
  type        = string
}

variable "relay" {
  description = "Enable OVN relay"
  type        = bool
  default     = true
}

variable "relay_scale" {
  description = "Scale of OVN relay application"
  type        = number
  default     = 1
}

variable "vault" {
  description = "Application name of Vault operator"
  type        = string
  default     = ""
}
