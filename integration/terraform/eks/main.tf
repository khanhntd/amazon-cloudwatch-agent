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
