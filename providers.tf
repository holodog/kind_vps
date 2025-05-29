terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.8.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.36.0"
    }
  }

  backend "s3" {
    bucket       = "local-k8s-tfstate-bucket"
    key          = "state/kind-vps-terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "kubernetes" {
  config_path = module.cluster.kubeconfig_path
}

provider "kubectl" {
  config_path = module.cluster.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = module.cluster.kubeconfig_path
  }
}