provider "gitlab" {
  token = var.gitlab_token
}

resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

data "gitlab_project" "main" {
  path_with_namespace = "${var.gitlab_org}/${var.gitlab_repository}"
}

resource "gitlab_deploy_key" "flux" {
  title    = local.name
  project  = data.gitlab_project.main.id
  key      = tls_private_key.flux.public_key_openssh
  can_push = true
}
