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
    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.6.0"
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

provider "github" {
  owner = var.github_org
  token = var.github_token
}

provider "kubernetes" {
  host                   = module.cluster.endpoint
  client_certificate     = module.cluster.client_certificate
  client_key             = module.cluster.client_key
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
  # config_path = module.cluster.kubeconfig_path
}

provider "kubectl" {
  host                   = module.cluster.endpoint
  client_certificate     = module.cluster.client_certificate
  client_key             = module.cluster.client_key
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
  load_config_file       = false
  # config_path = module.cluster.kubeconfig_path
}

provider "helm" {
  kubernetes {
    host                   = module.cluster.endpoint
    client_certificate     = module.cluster.client_certificate
    client_key             = module.cluster.client_key
    cluster_ca_certificate = module.cluster.cluster_ca_certificate
    # config_path = module.cluster.kubeconfig_path
  }
}

provider "flux" {
  kubernetes = {
    host                   = module.cluster.endpoint
    client_certificate     = module.cluster.client_certificate
    client_key             = module.cluster.client_key
    cluster_ca_certificate = module.cluster.cluster_ca_certificate
  }
  git = {
    url = "https://github.com/${var.github_org}/${var.github_flux_repository}.git"
    http = {
      username = "git"
      password = var.github_token
    }
  }
}
