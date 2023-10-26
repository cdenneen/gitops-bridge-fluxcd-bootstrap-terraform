provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
provider "kubernetes" {
  config_path = "~/.kube/config"
}
provider "flux" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
  git = {
    url = local.gitops_addons_url
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}

locals {
  name                   = "ex-${replace(basename(path.cwd), "_", "-")}"
  environment            = "dev"
  cluster_version        = "1.27"
  gitops_addons_url      = "ssh://git@gitlab.com/${var.gitlab_org}/${var.gitlab_repository}"
  gitops_addons_basepath = ""
  gitops_addons_path     = "bootstrap/control-plane/addons"
  gitops_addons_revision = "helm_values"
  components_extra       = var.components_extra

  oss_addons = {
    #enable_argo_rollouts                         = true
    #enable_argo_workflows                        = true
    #enable_cluster_proportional_autoscaler       = true
    #enable_gatekeeper                            = true
    #enable_gpu_operator                          = true
    enable_ingress_nginx = true
    #enable_kyverno                               = true
    enable_kube_prometheus_stack = true
    #enable_metrics_server = true
    #enable_prometheus_adapter                    = true
    #enable_secrets_store_csi_driver              = true
    #enable_vpa                                   = true
    #enable_foo                                   = true # you can add any addon here, make sure to update the gitops repo with the corresponding application set
  }
  addons = merge(local.oss_addons, { kubernetes_version = local.cluster_version })

  addons_metadata = merge(
    {
      addons_cluster_name  = local.name
      addons_repo_url      = local.gitops_addons_url
      addons_repo_basepath = local.gitops_addons_basepath
      addons_repo_path     = local.gitops_addons_path
      addons_repo_revision = local.gitops_addons_revision
    }
  )

  fluxcd_resources = {
    gitrepository = file("${path.module}/bootstrap/gitrepository.yaml")
    kustomization = file("${path.module}/bootstrap/kustomization.yaml")
  }

}

################################################################################
# GitOps Bridge: Bootstrap
################################################################################
module "gitops_bridge_bootstrap" {
  source = "../../"

  fluxcd = {
    path                   = "clusters/${local.name}"
    components_extra       = local.components_extra
    kustomization_override = file("${path.module}/kustomization-override.yaml")
  }
  cluster = {
    cluster_name = local.name
    environment  = local.environment
    metadata     = local.addons_metadata
    addons       = local.addons
  }
  apps = local.fluxcd_resources
}
