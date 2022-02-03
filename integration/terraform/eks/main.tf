terraform {
  required_providers {
    kubernetes = {
      version = "~> 1.13"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
 }
}

# get eks cluster by name
data "aws_eks_cluster" "testing_cluster" {
  name = var.eks_cluster_name
}
data "aws_eks_cluster_auth" "testing_cluster" {
  name = var.eks_cluster_name
}

# set up kubectl
provider "kubernetes" {
  host                   = data.aws_eks_cluster.testing_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.testing_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.testing_cluster.token
  load_config_file       = false
}

provider "kubectl" {
  // Note: copy from eks module. Please avoid use shorted-lived tokens when running locally.
  // For more information: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#exec-plugins
  host                   = data.aws_eks_cluster.testing_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.testing_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.testing_cluster.token
  load_config_file       = false
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

resource "kubernetes_service_account" "aoc-agent-role" {
  count = 1
  metadata {
    name      = "aoc-agent-${module.common.testing_id}"
    namespace = var.deployment_type == "fargate" ? tolist(aws_eks_fargate_profile.test_profile[count.index].selector)[0].namespace : kubernetes_namespace.aoc_ns.metadata[0].name
  }

  automount_service_account_token = true
  depends_on                      = [aws_eks_fargate_profile.test_profile]
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