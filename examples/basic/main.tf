########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.2.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create a VPC with single subnet and zone, and public gateway
##############################################################################

resource "ibm_is_vpc" "vpc" {
  count                     = var.is_vpc_cluster ? 1 : 0
  name                      = "${var.prefix}-vpc"
  resource_group            = module.resource_group.resource_group_id
  address_prefix_management = "auto"
  tags                      = var.resource_tags
}

resource "ibm_is_public_gateway" "gateway" {
  count          = var.is_vpc_cluster ? 1 : 0
  name           = "${var.prefix}-gateway-1"
  vpc            = ibm_is_vpc.vpc[0].id
  resource_group = module.resource_group.resource_group_id
  zone           = "${var.region}-1"
}

resource "ibm_is_subnet" "subnet_zone_1" {
  count                    = var.is_vpc_cluster ? 1 : 0
  name                     = "${var.prefix}-subnet-1"
  vpc                      = ibm_is_vpc.vpc[0].id
  resource_group           = module.resource_group.resource_group_id
  zone                     = "${var.region}-1"
  total_ipv4_address_count = 256
  public_gateway           = ibm_is_public_gateway.gateway[0].id
}

##############################################################################
# Base OCP Cluster in single zone
##############################################################################
locals {
  cluster_vpc_subnets = {
    default = [
      {
        id         = var.is_vpc_cluster ? ibm_is_subnet.subnet_zone_1[0].id : null
        cidr_block = var.is_vpc_cluster ? ibm_is_subnet.subnet_zone_1[0].ipv4_cidr_block : null
        zone       = var.is_vpc_cluster ? ibm_is_subnet.subnet_zone_1[0].zone : null
      }
    ]
  }

  worker_pools = [
    {
      subnet_prefix     = "default"
      pool_name         = "default" # ibm_container_vpc_cluster automatically names standard pool "default" (See https://github.com/IBM-Cloud/terraform-provider-ibm/issues/2849)
      machine_type      = "bx2.4x16"
      operating_system  = "REDHAT_8_64"
      workers_per_zone  = 2
      labels            = {}
      resource_group_id = module.resource_group.resource_group_id
    }
  ]
}

# Create OCP cluster in VPC
module "ocp_base" {
  count                = var.is_openshift && var.is_vpc_cluster ? 1 : 0
  source               = "terraform-ibm-modules/base-ocp-vpc/ibm"
  version              = "3.46.11"
  cluster_name         = var.prefix
  resource_group_id    = module.resource_group.resource_group_id
  region               = var.region
  force_delete_storage = true
  vpc_id               = ibm_is_vpc.vpc[0].id
  vpc_subnets          = local.cluster_vpc_subnets
  worker_pools         = local.worker_pools
  tags                 = var.resource_tags
}

# Lookup the current default kube version
data "ibm_container_cluster_versions" "cluster_versions" {}
locals {
  default_version = var.is_openshift ? "${data.ibm_container_cluster_versions.cluster_versions.default_openshift_version}_openshift" : data.ibm_container_cluster_versions.cluster_versions.default_kube_version
}

# Create IKS VPC cluster, only if variable is_openshift is false and is_vpc_cluster is true
resource "ibm_container_vpc_cluster" "cluster" {
  count                = var.is_vpc_cluster && !var.is_openshift ? 1 : 0
  name                 = var.prefix
  vpc_id               = ibm_is_vpc.vpc[0].id
  kube_version         = local.default_version
  flavor               = "bx2.4x16"
  worker_count         = "2"
  force_delete_storage = true
  wait_till            = "Normal"
  zones {
    subnet_id = ibm_is_subnet.subnet_zone_1[0].id
    name      = "${var.region}-1"
  }
  resource_group_id = module.resource_group.resource_group_id
  tags              = var.resource_tags

  timeouts {
    delete = "2h"
    create = "3h"
  }
}

# Create IKS or ROKS classic cluster, only if is_vpc_cluster is false
resource "ibm_container_cluster" "cluster" {
  #checkov:skip=CKV2_IBM_7:Public endpoint is required for testing purposes
  count                = var.is_vpc_cluster ? 0 : 1
  name                 = var.prefix
  datacenter           = var.datacenter
  default_pool_size    = 2
  hardware             = "shared"
  kube_version         = local.default_version
  entitlement          = var.is_openshift ? "cloud_pak" : null
  force_delete_storage = true
  machine_type         = "b3c.4x16"
  public_vlan_id       = ibm_network_vlan.public_vlan[0].id
  private_vlan_id      = ibm_network_vlan.private_vlan[0].id
  wait_till            = "Normal"
  resource_group_id    = module.resource_group.resource_group_id
  tags                 = var.resource_tags

  timeouts {
    delete = "2h"
    create = "3h"
  }
}

# Public network VLAN for classic clusters
resource "ibm_network_vlan" "public_vlan" {
  count      = var.is_vpc_cluster ? 0 : 1
  datacenter = var.datacenter
  type       = "PUBLIC"
}

# Private network VLAN for classic clusters
resource "ibm_network_vlan" "private_vlan" {
  count      = var.is_vpc_cluster ? 0 : 1
  datacenter = var.datacenter
  type       = "PRIVATE"
}

##############################################################################
# SCC Workload Protection Instance
##############################################################################

module "scc_wp" {
  source            = "terraform-ibm-modules/scc-workload-protection/ibm"
  version           = "v1.5.9"
  name              = "${var.prefix}-scc-wp"
  region            = var.region
  resource_group_id = module.resource_group.resource_group_id
  resource_key_tags = var.resource_tags

}

# Sleep to allow RBAC sync on cluster
resource "time_sleep" "wait_operators" {
  depends_on      = [data.ibm_container_cluster_config.cluster_config]
  create_duration = "5s"
}

##############################################################################
# SCC Workload Protection Agent
##############################################################################

module "scc_wp_agent" {
  source                 = "../.."
  depends_on             = [time_sleep.wait_operators]
  cluster_name           = (!var.is_vpc_cluster ? ibm_container_cluster.cluster[0].name : (var.is_openshift ? module.ocp_base[0].cluster_name : ibm_container_vpc_cluster.cluster[0].name))
  access_key             = module.scc_wp.access_key
  region                 = var.region
  name                   = var.prefix
  cluster_scanner_deploy = var.cluster_scanner_deploy
  kspm_deploy            = var.kspm_deploy
  cluster_shield_deploy  = var.cluster_shield_deploy

}

##############################################################################
