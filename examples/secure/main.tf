##############################################################################
# Resource Group
##############################################################################
module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.4"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}


#############################################################################
# Provision cloud object storage and bucket
#############################################################################

resource "ibm_resource_instance" "cos_instance" {
  name              = "${var.prefix}-vpc-logs-cos"
  resource_group_id = module.resource_group.resource_group_id
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
}

resource "ibm_cos_bucket" "cos_bucket" {
  bucket_name          = "${var.prefix}-vpc-logs-cos-bucket"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  region_location      = var.region
  storage_class        = "standard"
}


##############################################################################
# Key Protect
##############################################################################

module "kp_all_inclusive" {
  source                    = "terraform-ibm-modules/key-protect-all-inclusive/ibm"
  version                   = "4.4.1"
  key_protect_instance_name = "${var.prefix}-kp-instance"
  resource_group_id         = module.resource_group.resource_group_id
  region                    = var.region
  resource_tags             = var.resource_tags
  key_map = { "ocp" = [
    "${var.prefix}-cluster-key",
    "${var.prefix}-default-pool-boot-volume-encryption-key",
    "${var.prefix}-other-pool-boot-volume-encryption-key"
  ] }
}

##############################################################################
# Base OCP Cluster in single zone
##############################################################################
locals {
  cluster_vpc_subnets = {
    default = [
      for subnet in module.slz_vpc.subnet_zone_list :
      {
        id         = subnet.id
        zone       = subnet.zone
        cidr_block = subnet.cidr
      }
    ]
  }

  worker_pools = [
    {
      subnet_prefix     = "default"
      pool_name         = "default" # ibm_container_vpc_cluster automatically names standard pool "default" (See https://github.com/IBM-Cloud/terraform-provider-ibm/issues/2849)
      machine_type      = "bx2.4x16"
      workers_per_zone  = 2
      labels            = {}
      resource_group_id = module.resource_group.resource_group_id
      boot_volume_encryption_kms_config = {
        crk             = module.kp_all_inclusive.keys["ocp.${var.prefix}-default-pool-boot-volume-encryption-key"].key_id
        kms_instance_id = module.kp_all_inclusive.key_protect_guid
      }
    }
  ]
}

module "ocp_base" {
  source               = "terraform-ibm-modules/base-ocp-vpc/ibm"
  version              = "3.10.2"
  cluster_name         = var.prefix
  ibmcloud_api_key     = var.ibmcloud_api_key
  resource_group_id    = module.resource_group.resource_group_id
  region               = var.region
  force_delete_storage = true
  vpc_id               = module.slz_vpc.vpc_id
  vpc_subnets          = local.cluster_vpc_subnets
  worker_pools         = local.worker_pools
  ocp_version          = var.ocp_version
  tags                 = var.resource_tags
  kms_config = {
    instance_id = module.kp_all_inclusive.key_protect_guid
    crk_id      = module.kp_all_inclusive.keys["ocp.${var.prefix}-cluster-key"].key_id
  }
  access_tags = var.access_tags
}

#############################################################################
# Provision VPC
#############################################################################

module "slz_vpc" {
  source                                 = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version                                = "7.13.0"
  resource_group_id                      = module.resource_group.resource_group_id
  region                                 = var.region
  name                                   = "wp-vpc"
  prefix                                 = var.prefix
  tags                                   = var.resource_tags
  access_tags                            = var.access_tags
  enable_vpc_flow_logs                   = true
  create_authorization_policy_vpc_to_cos = true
  existing_cos_instance_guid             = ibm_resource_instance.cos_instance.guid
  existing_storage_bucket_name           = ibm_cos_bucket.cos_bucket.bucket_name
  address_prefixes                       = var.address_prefixes
  network_cidrs                          = var.network_cidrs
  use_public_gateways = {
    zone-1 = false
    zone-2 = false
    zone-3 = false
  }
}

##############################################################################
# SCC Workload Protection Instance
##############################################################################

module "scc_wp" {
  source            = "terraform-ibm-modules/scc-workload-protection/ibm"
  version           = "v1.1.0"
  name              = "${var.prefix}-scc-wp"
  region            = var.region
  resource_group_id = module.resource_group.resource_group_id
  resource_key_tags = var.resource_tags

}

##############################################################################
# SCC Workload Protection Agent
##############################################################################

module "scc_wp_agent" {
  source        = "../.."
  cluster_name  = module.ocp_base.cluster_name
  access_key    = module.scc_wp.access_key
  region        = var.region
  endpoint_type = "private"
  name          = "${var.prefix}-scc-wp-agent"
}

##############################################################################
