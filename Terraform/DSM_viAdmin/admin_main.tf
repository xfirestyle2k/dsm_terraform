terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}
provider "kubernetes" {
  config_path = "dsm-viadmin.kubeconfig"
}

resource "kubernetes_manifest" "dev-ip-pool" {
  manifest = {
    "apiVersion" = "infrastructure.dataservices.vmware.com/v1alpha1"
    "kind" = "IPPool"
    "metadata" = {
      "name" = "dev-ip-pool"
    }
    "spec" = {
      "addresses" = [
        "172.21.207.81-172.21.207.90"
      ]
      "prefix" = 24
      "gateway" = "172.21.207.1"
    }
  }
  wait {
    condition {
      type = "Ready"
      status = "True"
    }
  }
  timeouts {
    create = "10s"
    delete = "10s"
  }
}

resource "kubernetes_manifest" "dev-infra-policy" {
  manifest = {
    "apiVersion" = "infrastructure.dataservices.vmware.com/v1alpha1"
    "kind" = "InfrastructurePolicy"
    "metadata" = {
      "name" = "dev-infra-policy"
    }
    "spec" = {
      "enabled" = true
      "placements" = [
        {
            "datacenter" = "vpaif-dc"
            "cluster" = "vpaif-cluster"
            "portGroups" = [
                "segment207"
            ]
        }
      ]
      "storagePolicies" = [
        "vpaif-cluster vSAN Storage Policy"
      ]
      "ipRanges" = [
        {
          "poolName" = "dev-ip-pool"
          "portGroups" = [
            {
                "datacenter" = "vpaif-dc"
                "name" = "segment207"
            }
          ]
        }
      ]
      "vmClasses" = [
        {
            "name" = "small"
        },
        {
            "name" = "medium"
        }
      ]
    }
  }
  depends_on = [ kubernetes_manifest.dev-ip-pool ]
  wait {
    condition {
      type = "Ready"
      status = "True"
    }
  }
  timeouts {
    create = "20s"
    delete = "10s"
  }

}
