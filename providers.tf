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
  client_certificate     = module.cluster.client_certificate
  host                   = module.cluster.endpoint
  client_key             = module.cluster.client_key
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
}

provider "kubectl" {
  alias                  = "kubectl"
  client_certificate     = module.cluster.client_certificate
  host                   = module.cluster.endpoint
  client_key             = module.cluster.client_key
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    client_certificate     = module.cluster.client_certificate
    host                   = module.cluster.endpoint
    client_key             = module.cluster.client_key
    cluster_ca_certificate = module.cluster.cluster_ca_certificate
  }
}