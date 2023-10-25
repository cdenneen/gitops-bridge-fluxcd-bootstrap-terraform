variable "gitlab_token" {
  sensitive = true
  type      = string
}

variable "gitlab_org" {
  type = string
}

variable "gitlab_repository" {
  type    = string
  default = "gitops-flux-infra"
}

variable "components_extra" {
  type    = list(string)
  default = ["image-reflector-controller", "image-automation-controller"]
}
