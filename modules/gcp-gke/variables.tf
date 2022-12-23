variable "project" {
       type   = string
       description = "GCP project"
}

variable "environment" {
       type   = string
       description = "environment targeted"
}

variable "region" {
       type   = string
       description = "region targeted"
}

variable "zone" {
       type   = string
       description = "zone targeted"
}

variable "zone_count" {
       type   = number
       description = "Number of zones to be deployed"
       default = 2
}

variable "gke_cluster" {
  type = object({
       nodepools = list(object({
              name = string,
              machine_type = string,
              min_count = number,
              max_count = number,
              local_ssd_count = number,
              disk_size_gb = number,
              disk_type = string,
              image_type = string,
              auto_repair = bool,
              auto_upgrade = bool,
              preemptible = bool,
              initial_node_count = number,
              taints = list(object({
                     key = string
                     value = string
                     effect = string
              }))
       }))
  })
}
