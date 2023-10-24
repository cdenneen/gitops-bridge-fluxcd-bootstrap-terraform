variable "create" {
  description = "Create terraform resources"
  type        = bool
  default     = true
}
variable "fluxcd" {
  description = "FluxCD Bootstrap options"
  type        = any
  default     = {}
}

variable "cluster" {
  description = "fluxcd cluster secret"
  type        = any
  default     = null
}

variable "apps" {
  description = "fluxcd app of apps to deploy"
  type        = any
  default     = {}
}
