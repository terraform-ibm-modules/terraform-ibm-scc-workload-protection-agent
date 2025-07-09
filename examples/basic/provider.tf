########################################################################################################################
# Provider config
########################################################################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

# Init cluster config for helm and kubernetes providers
data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = (!var.is_vpc_cluster ? ibm_container_cluster.cluster[0].id : (var.is_openshift ? module.ocp_base[0].cluster_id : ibm_container_vpc_cluster.cluster[0].id))
  resource_group_id = module.resource_group.resource_group_id
}

# Helm provider used to deploy workload protection agent
provider "helm" {
  kubernetes = {
    host                   = data.ibm_container_cluster_config.cluster_config.host
    token                  = data.ibm_container_cluster_config.cluster_config.token
    cluster_ca_certificate = data.ibm_container_cluster_config.cluster_config.ca_certificate
  }
}

provider "kubernetes" {
  host  = data.ibm_container_cluster_config.cluster_config.host
  token = data.ibm_container_cluster_config.cluster_config.token
}

data "ibm_iam_auth_token" "auth_token" {}

provider "restapi" {
  # see https://cloud.ibm.com/apidocs/resource-controller/resource-controller#endpoint-url for full list of available resource controller endpoints
  uri = "https://resource-controller.cloud.ibm.com"
  headers = {
    Authorization = data.ibm_iam_auth_token.auth_token.iam_access_token
  }
  write_returns_object = true
}
