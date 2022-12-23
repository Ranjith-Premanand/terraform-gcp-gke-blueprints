module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
  project_id                 = var.project
  name                       = local.name_prefix
  region                     = var.region
  zones                      = local.zones
  network                    = module.vpc.network_name
  subnetwork                 = "${local.name_prefix}-vpc-sub"
  ip_range_pods              = "pods-range"
  ip_range_services          = "services-range"
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false

  node_pools = [for nodepool_info in var.gke_cluster.nodepools :
    {
      name                      = nodepool_info.name
      machine_type              = nodepool_info.machine_type
      node_locations            = var.zone
      min_count                 = nodepool_info.min_count
      max_count                 = nodepool_info.max_count
      local_ssd_count           = nodepool_info.local_ssd_count
      disk_size_gb              = nodepool_info.disk_size_gb
      disk_type                 = nodepool_info.disk_type
      image_type                = nodepool_info.image_type
      auto_repair               = nodepool_info.auto_repair
      auto_upgrade              = nodepool_info.auto_upgrade
      service_account           = google_service_account.gke_service_account.email
      preemptible               = nodepool_info.preemptible
      initial_node_count        = nodepool_info.initial_node_count
    }
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    for nodepool_info in var.gke_cluster.nodepools : "${nodepool_info.name}" =>
    {
      component = nodepool_info.name
    }
  }

  node_pools_metadata = {
    all = {}
  }

  node_pools_taints = {
    for nodepool_info in var.gke_cluster.nodepools : "${nodepool_info.name}" =>

    nodepool_info.taints
  }

  node_pools_tags = {
    all = []
  }
  depends_on = [google_service_account.gke_service_account, module.vpc]
}

resource "google_service_account" "gke_service_account" {
  account_id   = "${var.environment}-gke"
  display_name = "${var.environment}-gke"
}

module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 6.0"

    project_id                    = var.project
    network_name                  = local.name_prefix
    routing_mode                  = "GLOBAL"
    auto_create_subnetworks       = false

    subnets = [
        {
            subnet_name           = "${local.name_prefix}-vpc-sub"
            subnet_ip             = "10.0.0.0/24"
            subnet_region         = "asia-south2"
        }
    ]

    secondary_ranges = {
        "${local.name_prefix}-vpc-sub" = [
            {
                range_name    = "services-range"
                ip_cidr_range = "10.2.0.0/24"
            },
            {
                range_name    = "pods-range"
                ip_cidr_range = "10.1.0.0/24"
            },           
        ]
    }
}