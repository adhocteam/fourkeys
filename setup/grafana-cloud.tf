# SA to allow Grafana cloud to query the same resources

locals {
  grafana_sa_name = "fourkeys-grafana-cloud"
}

resource "google_service_account" "grafana" {
  project = var.google_project_id
  account_id   = local.grafana_sa_name
  display_name = local.grafana_sa_name
}


# Grant the SA IAM permissions to view Cloud monitoring
resource "google_project_iam_member" "grafana_cloud_monitor_access" {
  project = var.google_project_id
  role    = "roles/bigquery.user"
  member  = "serviceAccount:${google_service_account.grafana.email}"
}
