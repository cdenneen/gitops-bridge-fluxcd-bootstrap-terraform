terraform {
  required_version = ">= 1.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.22.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 1.0.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.0.0"
    }
  }
}
