terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "kubernetes" {
  config_path = "dsm-admin.kubeconfig"
}

resource "kubernetes_namespace" "terraform-ns" {
  metadata {
    annotations = {
      name = "created by terraform"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "terraform-ns"
  }
}

resource "kubernetes_manifest" "ts-pg-cluster" {
  manifest = {
    "apiVersion" = "databases.dataservices.vmware.com/v1alpha1"
    "kind" = "PostgresCluster"
    "metadata" = {
      "name" = "ts-pg-cluster"
      "namespace" = "terraform-ns"
      "annotations" = {
        "dsm.vmware.com/owner" = "thomas.sauerer@broadcom.com"
      }
      "labels": {
        "dsm.vmware.com/aria-automation-instance": "Instance"
        "dsm.vmware.com/created-in": "terraform"
        "dsm.vmware.com/aria-automation-project" = "Terraform-Test"
      }
    }
    "spec" = {
      "replicas" = 1
      "version" = "15"
      "storageSpace" = "25G"
      "vmClass" = {
        "name" = "small"
      }
      "infrastructurePolicy" = {
        "name" = "infra-dsm-policy"
      }
      "storagePolicyName" = "vpaif-cluster vSAN Storage Policy"
      "backupLocation" = {
        "name" = "DB-Backup"
      }
      "backupConfig" = {
        "backupRetentionDays" = 7
        "schedules" = [
          {
            "name" = "full-weekly"
            "type" = "full"
            "schedule" = "0 0 * * 0"
          },
          {
            "name" = "incremental-daily"
            "type" = "incremental"
            "schedule" = "0 0 * * *"
          }
        ]
      }
    }
  }

  wait {
    condition {
      type = "Ready"
      status = "True"
    }
  }
  timeouts {
    create = "10m"
    delete = "2m"
  }
}
