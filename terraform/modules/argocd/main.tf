resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  depends_on = [terraform_data.node_group_ready]
}

resource "terraform_data" "node_group_ready" {
  input = var.node_group_dependency
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "7.8.2"

  wait            = true
  timeout         = 1200
  cleanup_on_fail = true

  values = [
    yamlencode({
      dex = {
        enabled = false
      }
      notifications = {
        enabled = false
      }
      applicationSet = {
        enabled = false
      }
      configs = {
        params = {
          "server.insecure" = true
        }
      }
      controller = {
        replicas = 1
        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }
      server = {
        replicas = 1
        resources = {
          requests = {
            cpu    = "50m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "250m"
            memory = "256Mi"
          }
        }
      }
      repoServer = {
        replicas = 1
        resources = {
          requests = {
            cpu    = "50m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "250m"
            memory = "256Mi"
          }
        }
      }
      redis = {
        resources = {
          requests = {
            cpu    = "25m"
            memory = "64Mi"
          }
          limits = {
            cpu    = "100m"
            memory = "128Mi"
          }
        }
      }
    })
  ]

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  depends_on = [kubernetes_namespace.argocd]
}

resource "helm_release" "argocd_apps" {
  name       = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "2.0.2"

  values = [
    yamlencode({
      applications = {
        web-app = {
          namespace             = kubernetes_namespace.argocd.metadata[0].name
          project               = "default"
          finalizers            = ["resources-finalizer.argocd.argoproj.io"]
          additionalAnnotations = {}
          additionalLabels      = {}
          source = {
            repoURL        = var.git_repo_url
            targetRevision = "main"
            path           = var.app_path
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "default"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = [
              "CreateNamespace=true"
            ]
          }
        }
      }
    })
  ]

  depends_on = [helm_release.argocd]
}
