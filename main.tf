##############################################################################
# SCC Workload Protection Agent
##############################################################################
locals {
  scc_domain         = "security-compliance-secure.cloud.ibm.com"
  api_endpoint       = var.endpoint_type == "private" ? "private.${var.region}.${local.scc_domain}" : "${var.region}.${local.scc_domain}"
  ingestion_endpoint = var.endpoint_type == "private" ? "ingest.private.${var.region}.${local.scc_domain}" : "ingest.${var.region}.${local.scc_domain}"

  kspm_analyzer_image_repo              = "kspm-analyzer"
  kspm_analyzer_image_tag_digest        = "1.39.1@sha256:1a4c2f508beabed6a17c1584729dc8b40f1f37d59bef3a8e9d40f804d37bc807" # datasource: icr.io/ibm-iac/kspm-analyzer
  agent_kmodule_image_repo              = "agent-kmodule"
  agent_kmodule_image_tag_digest        = "12.20.0@sha256:9b3b1fd6cbf05f5fa79098202ba9ec79c464d846643f6956c382788da7fdf4ec" # datasource: icr.io/ibm-iac/agent-kmodule
  vuln_runtime_scanner_image_repo       = "vuln-runtime-scanner"
  vuln_runtime_scanner_image_tag_digest = "1.6.9@sha256:b8032f3ca8b4623aa16a305272a40fc77c1856b7a783e89297489d4a82954450" # datasource: icr.io/ibm-iac/vuln-runtime-scanner
  vuln_host_scanner_image_repo          = "vuln-host-scanner"
  vuln_host_scanner_image_tag_digest    = "0.7.4@sha256:25ac73208456d7fb1f0291ef0e5a42dba98c7001c286e2b70e00ed79592a336d" # datasource: icr.io/ibm-iac/vuln-host-scanner
  agent_slim_image_repo                 = "agent-slim"
  agent_slim_image_tag_digest           = "12.20.0@sha256:79dda7a5d0f93435b29d648242da293406cc163795890c10a9aa8e25d3e32ae0" # datasource: icr.io/ibm-iac/agent-slim
  kspm_collector_image_repo             = "kspm-collector"
  kspm_collector_image_tag_digest       = "1.37.1@sha256:1a1abeb152a97455ecd251b78f8fb2f7e570292dd98186e50244d46f40efc09f" # datasource: icr.io/ibm-iac/kspm-collector
  image_registry                        = "icr.io"
  image_namespace                       = "ibm-iac"
}

resource "helm_release" "scc_wp_agent" {
  name             = var.name
  chart            = "oci://icr.io/ibm-iac-charts/sysdig-deploy"
  version          = "1.37.16"
  namespace        = var.namespace
  create_namespace = true
  timeout          = 12000
  wait             = true
  recreate_pods    = true
  force_update     = true
  reset_values     = true

  set {
    name  = "global.sysdig.accessKey"
    type  = "string"
    value = var.access_key
  }

  set {
    name  = "agent.collectorSettings.collectorHost"
    type  = "string"
    value = local.ingestion_endpoint
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.apiEndpoint"
    type  = "string"
    value = local.api_endpoint
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.runtimeScanner.settings.eveEnabled"
    value = true
  }

  set {
    name  = "nodeAnalyzer.secure.vulnerabilityManagement.newEngineOnly"
    value = true
  }

  set {
    name  = "global.kspm.deploy"
    value = true
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.benchmarkRunner.deploy"
    value = false
  }

  set {
    name  = "agent.slim.enabled"
    value = true
  }

  set {
    name  = "global.clusterConfig.name"
    type  = "string"
    value = var.cluster_name
  }

  set {
    name  = "kspmCollector.apiEndpoint"
    type  = "string"
    value = local.api_endpoint
  }

  set {
    name  = "agent.image.registry"
    type  = "string"
    value = local.image_registry
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.deploy"
    value = true
  }

  set {
    name  = "Values.image.repository"
    type  = "string"
    value = local.image_registry
  }

  set {
    name  = "global.imageRegistry"
    type  = "string"
    value = "${local.image_registry}/${local.image_namespace}"
  }
  set {
    name  = "kspmCollector.image.repository"
    type  = "string"
    value = local.kspm_collector_image_repo
  }

  set {
    name  = "kspmCollector.image.tag"
    type  = "string"
    value = local.kspm_collector_image_tag_digest
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.kspmAnalyzer.image.repository"
    type  = "string"
    value = local.kspm_analyzer_image_repo
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.kspmAnalyzer.image.tag"
    type  = "string"
    value = local.kspm_analyzer_image_tag_digest
  }

  set {
    name  = "agent.slim.image.repository"
    type  = "string"
    value = local.agent_slim_image_repo
  }

  set {
    name  = "agent.image.tag"
    type  = "string"
    value = local.agent_slim_image_tag_digest
  }

  set {
    name  = "agent.slim.kmoduleImage.repository"
    type  = "string"
    value = local.agent_kmodule_image_repo
  }

  set {
    name  = "agent.slim.kmoduleImage.digest"
    type  = "string"
    value = regex("@(.*)", local.agent_kmodule_image_tag_digest)[0]
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.runtimeScanner.image.tag"
    type  = "string"
    value = local.vuln_runtime_scanner_image_tag_digest
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.runtimeScanner.image.repository"
    type  = "string"
    value = local.vuln_runtime_scanner_image_repo
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.hostScanner.image.tag"
    type  = "string"
    value = local.vuln_host_scanner_image_tag_digest
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.hostScanner.image.repository"
    type  = "string"
    value = local.vuln_host_scanner_image_repo
  }
}
