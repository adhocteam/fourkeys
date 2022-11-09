resource "google_cloud_run_service" "dashboard" {
  name     = "fourkeys-grafana-dashboard"
  location = var.google_region

  template {
    spec {
      containers {
        ports {
          container_port = 3000
        }
        image = "gcr.io/${var.google_project_id}/fourkeys-grafana-dashboard"
        env {
          name  = "PROJECT_NAME"
          value = var.google_project_id
        }
        env {
          name  = "BQ_REGION"
          value = var.bigquery_region
        }
      }
      service_account_name = var.fourkeys_service_account_email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  metadata {
    labels = { "created_by" : "fourkeys" }
  }
  autogenerate_revision_name = true
}

resource "google_cloud_run_service_iam_binding" "noauth" {
  location = var.google_region
  project  = var.google_project_id
  service  = "fourkeys-grafana-dashboard"

  role       = "roles/run.invoker"
  members    = ["allUsers"]
  depends_on = [google_cloud_run_service.dashboard]
}


module "grafana-loadbalancer" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "~> 6.3"
  name    = "fourkeys-grafana-dashboard"
  project = var.google_project_id

  ssl                             = true
  managed_ssl_certificate_domains = ["people-app-fourkeys.adhoc.dev"]
  https_redirect                  = true
  labels                          = { "component" = "grafana" }

  backends = {
    default = {
      description = null
      groups = [
        {
          group = google_compute_region_network_endpoint_group.serverless_neg.id
        }
      ]
      enable_cdn              = false
      security_policy         = null
      custom_request_headers  = null
      custom_response_headers = null

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
      log_config = {
        enable      = false
        sample_rate = null
      }
    }
  }
}

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  provider              = google-beta
  project               = var.google_project_id
  name                  = "fourkeys-grafana-dashboard-serverless-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.google_region
  cloud_run {
    service = google_cloud_run_service.dashboard.name
  }
}
