resource "flux_bootstrap_git" "this" {
  count = var.create ? 1 : 0

  # https://registry.terraform.io/providers/fluxcd/flux/latest/docs/resources/bootstrap_git
  # Optional
  cluster_domain          = try(var.fluxcd.cluster_domain, null)
  components              = try(var.fluxcd.components, null)
  components_extra        = try(var.fluxcd.components_extra, null)
  disable_secret_creation = try(var.fluxcd.disable_secret_creation, null)
  image_pull_secret       = try(var.fluxcd.image_pull_secret, null)
  interval                = try(var.fluxcd.interval, null)
  kustomization_override  = try(var.fluxcd.kustomization_override, null)
  log_level               = try(var.fluxcd.log_level, null)
  namespace               = try(var.fluxcd.namespace, null)
  network_policy          = try(var.fluxcd.network_policy, null)
  path                    = try(var.fluxcd.path, null)
  recurse_submodules      = try(var.fluxcd.recurse_submodules, null)
  registry                = try(var.fluxcd.registry, null)
  secret_name             = try(var.fluxcd.secret_name, null)
  timeouts                = try(var.fluxcd.timeouts, null)
  toleration_keys         = try(var.fluxcd.toleration_keys, null)
  version                 = try(var.fluxcd.version, null)
  watch_all_namespaces    = try(var.fluxcd.watch_all_namespaces, null)
}

locals {
  cluster_name = try(var.cluster.cluster_name, "in-cluster")
  environment  = try(var.cluster.environment, "dev")
  fluxcd_labels = merge({
    cluster_name               = local.cluster_name
    environment                = local.environment
    },
    try(var.cluster.addons, {})
  )
  fluxcd_annotations = merge(
    {
      cluster_name = local.cluster_name
      environment  = local.environment
    },
    try(var.cluster.metadata, {})
  )
}

resource "helm_release" "bootstrap" {
 for_each = var.create ? var.apps : {}

 name      = each.key
 namespace = try(var.fluxcd.namespace, "flux-system")
 chart     = "${path.module}/charts/resources"
 version   = "1.0.0"

 values = [
   <<-EOT
   resources:
     - ${indent(4, each.value)}
   metadata:
     annotations:
     %{ for k, v in local.fluxcd_annotations ~}
  ${k}: ${v}
     %{ endfor }
     labels:
     %{ for k, v in local.fluxcd_labels ~}
  ${k}: ${v}
     %{ endfor ~}
   EOT
 ]

 depends_on = [
   flux_bootstrap_git.this
 ]
}
