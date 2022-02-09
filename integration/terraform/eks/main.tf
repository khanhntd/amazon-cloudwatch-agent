locals {
  eks_pod_config_path = fileexists("${var.testcase}/eks_pod_config.tpl") ? "${var.testcase}/eks_pod_config.tpl" : module.common.default_eks_pod_config_path
}

module "common" {
  source = "../common"

  aoc_image_repo = var.aoc_image_repo
  aoc_version    = var.aoc_version
}

# get eks cluster by name
data "aws_eks_cluster" "testing_cluster" {
  name = var.eks_cluster_name
}
data "aws_eks_cluster_auth" "testing_cluster" {
  name = var.eks_cluster_name
}

data "template_file" "kubeconfig_file" {
  template = file("./kubeconfig.tpl")
  vars = {
    CA_DATA : data.aws_eks_cluster.testing_cluster.certificate_authority[0].data
    SERVER_ENDPOINT : data.aws_eks_cluster.testing_cluster.endpoint
    TOKEN = data.aws_eks_cluster_auth.testing_cluster.token
  }
}

resource "local_file" "kubeconfig" {
  filename = "kubeconfig"
  content  = data.template_file.kubeconfig_file.rendered
}

# create a unique namespace for each run
resource "kubernetes_namespace" "aoc_ns" {
  metadata {
    name = "aoc-ns-${module.common.testing_id}"
  }
}

resource "kubernetes_service_account" "aoc-role" {
  metadata {
    name      = "aoc-role-${module.common.testing_id}"
    namespace = kubernetes_namespace.aoc_ns.metadata[0].name
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "aoc-role-binding" {
  metadata {
    name = "aoc-role-binding-${module.common.testing_id}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "aoc-role-${module.common.testing_id}"
    namespace = kubernetes_namespace.aoc_ns.metadata[0].name
  }
}

resource "kubernetes_service_account" "aoc-agent-role" {
  metadata {
    name      = "aoc-agent-${module.common.testing_id}"
    namespace = kubernetes_namespace.aoc_ns.metadata[0].name
  }

  automount_service_account_token = true
}

module "adot_operator" {
  count  = replace(var.testcase, "_adot_operator", "") == var.testcase ? 0 : 1
  source = "./adot-operator"

  testing_id = module.common.testing_id
  kubeconfig = local_file.kubeconfig.filename
}


##########################################
# Validation
##########################################
module "validator" {
  source = "../validation"

  validation_config            = var.validation_config
  region                       = var.region
  testing_id                   = module.common.testing_id
  metric_namespace             = "${module.common.otel_service_namespace}/${module.common.otel_service_name}"
  sample_app_endpoint          = length(kubernetes_service.sample_app_service) > 0 ? "http://${kubernetes_service.sample_app_service.0.load_balancer_ingress.0.hostname}:${module.common.sample_app_lb_port}" : ""
  mocked_server_validating_url = length(kubernetes_service.mocked_server_service) > 0 ? "http://${kubernetes_service.mocked_server_service.0.load_balancer_ingress.0.hostname}/check-data" : ""
  cloudwatch_context_json = var.aoc_base_scenario == "prometheus" ? jsonencode({
    clusterName : var.eks_cluster_name
    appMesh : {
      namespace : module.demo_appmesh.0.metric_dimension_namespace
      job : "kubernetes-pod-appmesh-envoy"
    }
    nginx : {
      namespace : module.demo_nginx.0.metric_dimension_namespace
      job : "kubernetes-service-endpoints"
    }
    jmx : {
      namespace : module.demo_jmx.0.metric_dimension_namespace
      job : "kubernetes-pod-jmx"
    }
    memcached : {
      namespace : module.demo_memcached.0.metric_dimension_namespace
      job : "kubernetes-service-endpoints"
    }
    haproxy : {
      namespace : module.demo_haproxy.0.metric_dimension_namespace
      job : "kubernetes-service-endpoints"
    }
    }) : jsonencode({
    clusterName : var.eks_cluster_name
  })
  cortex_instance_endpoint = var.cortex_instance_endpoint

  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key

  depends_on = [
    module.aoc_oltp,
  module.adot_operator]
}