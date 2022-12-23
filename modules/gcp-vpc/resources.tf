module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 6.0"

    project_id                    = var.project
    network_name                  = local.name_prefix
    routing_mode                  = "GLOBAL"
    auto_create_subnetworks       = true

    subnets = [
        {
            subnet_name           = "${local.name_prefix}-general-vpc-sub"
            subnet_ip             = "10.10.1.0/24"
            subnet_region         = "asia-south2"
        }
    ]

    secondary_ranges = {
        "${local.name_prefix}-vpc-sub" = [
            {
                range_name    = "services-range"
                ip_cidr_range = "10.10.2.0/24"
            },
            {
                range_name    = "pods-range"
                ip_cidr_range = "10.10.3.0/24"
            },           
        ]
    }
}