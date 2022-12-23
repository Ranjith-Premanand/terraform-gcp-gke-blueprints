locals {
  name_prefix = "${var.environment}-gke-cluster"
  zones = slice(data.google_compute_zones.available.names, 1, var.zone_count)
}
