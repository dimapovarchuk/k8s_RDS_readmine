
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}


provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}



resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-controller"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
  depends_on = [kubernetes_service.redmine_service]
}

resource "kubernetes_ingress" "redmine_ingres" {
  depends_on             = [helm_release.nginx_ingress]
  wait_for_load_balancer = true
  metadata {
    name = "redmine-ingres"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }
  spec {
    rule {
      http {
        path {
          path = "/"
          backend {
            service_name = kubernetes_service.redmine_service.metadata.0.name
            service_port = 80
          }
        }
      }
    }
  }
}



resource "kubernetes_service" "redmine_service" {
  metadata {
    name = "redmine-service"
  }
  spec {
    port {
      //node_port   = 31000
      port        = 80
      target_port = 3000
    }
    selector = {
      app  = "redmine"
      type = "backend"
    }
    type = "NodePort"
  }
}


resource "kubernetes_deployment" "redmine_deployment" {
depends_on = [helm_release.nginx_ingress]
  metadata {
    labels = {
      app  = "redmine"
      type = "backend"
    }
    name = "redmine-deploy"
  }
  spec {
    replicas = 4
    selector {
      match_labels = {
        type = "backend"
      }
    }
    template {
      metadata {
        labels = {
          app  = "redmine"
          type = "backend"
        }
        name = "redmine"
      }
      spec {
        container {
          image = "romario11/redmine-demo2:40"
          name  = "redmine"

          env {
            name = "REDMINE_SECRET_KEY_BASE"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.redmine_secrets.metadata.0.name
                key = "secret_key_session"
              }
            }
          }
          env {
            name = "REDMINE_DB_POSTGRES"
            value = aws_db_instance.redmine_rds_db.address
          }
          env {
            name = "REDMINE_DB_DATABASE"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.redmine_secrets.metadata.0.name
                key = "db_name"
              }
            }
          }
          env {
            name = "REDMINE_DB_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.redmine_secrets.metadata.0.name
                key = "db_username"
              }
            }
          }
          env {
            name = "REDMINE_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.redmine_secrets.metadata.0.name
                key = "db_password"
              }
            }
          }
         /* volume_mount {
            mount_path = "/usr/src/redmine/files"
            name       = "redmine-storage"
          }*/
        }
        /*volume {
          name = "redmine-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.redmine_pvc.metadata[0].name
          }
        }*/
      }
    }
  }
}

resource "kubernetes_secret" "redmine_secrets" {
  metadata {
    name = "redmine-secret"
  }
  data = {
    db_username = file(var.db_user_name)
    db_password = file(var.db_password)
    db_name = file(var.db_name)
    secret_key_session = file(var.secret_key_redmine)
  }
}

output "load_balancer_hostname" {
  value = kubernetes_ingress.redmine_ingres.status.0.load_balancer.0.ingress.0.hostname
}

resource "null_resource" "install_kubectl_config" {
  provisioner "local-exec" {
    command = "aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)"
  }
  depends_on = [helm_release.nginx_ingress]
}












//==================================================

/*resource "kubernetes_persistent_volume" "redmine-pv_local" {
  metadata {
    name = "redmine-pv-local"
  }
  spec {
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            values =["master"]
            operator = "In"
          }
        }
      }
    }
    storage_class_name = "nfs-local"
    volume_mode        = "Filesystem"
    access_modes = [
      "ReadWriteMany"
    ]
    capacity = {
      storage = "10Gi"
    }
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      local {
        path = "/mnt/data"
      }
    }
  }
}



resource "kubernetes_persistent_volume_claim" "redmine_pvc_local" {
  depends_on = [kubernetes_persistent_volume.redmine-pv_local]
  metadata {
    name = "redmine-pvc-local"
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "nfs-local"
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = "redmine-pv-local"
  }
}



resource "kubernetes_storage_class" "redmine_storage_class_local" {
  metadata {
    name = "nfs-local"
  }
  storage_provisioner = "kubernetes.io/no-provisioner"
}*/
//==============================================




/*
resource "kubernetes_ingress" "redmine_ingres" {
  metadata {
    name = "redmine-ingres"
  }
  spec {
    rule {
      host = kubernetes_ingress.example.status.0.load_balancer.0.ingress.0.hostname
      http {
        path {
          path = "/"
          backend {
            service_name = "redmine-service"
            service_port = 80
          }
        }
      }
    }
  }
}*/


