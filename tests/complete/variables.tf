variable "github_token" {
  sensitive = true
  type      = string
}

variable "github_org" {
  type = string
}

variable "github_repository" {
  type    = string
  default = "gitops-flux-infra"
}

variable "components_extra" {
  type    = list(string)
  default = ["image-reflector-controller", "image-automation-controller"]
}
