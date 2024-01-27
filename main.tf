##############################################################################
# SCC Workload Protection Agent
##############################################################################
locals {
  scc_domain         = "security-compliance-secure.cloud.ibm.com"
  api_endpoint       = var.endpoint_type == "private" ? "private.${var.region}.${local.scc_domain}" : "${var.region}.${local.scc_domain}"
  ingestion_endpoint = var.endpoint_type == "private" ? "ingest.private.${var.region}.${local.scc_domain}" : "ingest.${var.region}.${local.scc_domain}"

  kspm_analyzer_image_repo              = "kspm-analyzer"
  kspm_analyzer_image_tag_digest        = "1.39.0@sha256:705dc6dd88e0e3feb88f08b0043577793ee5fa7b8b6c1fc02e9cc252148667d6" # datasource: icr.io/ibm-iac/kspm-analyzer
  agent_kmodule_image_repo              = "agent-kmodule"
  agent_kmodule_image_tag_digest        = "12.19.0@sha256:e3e1f68e2fc3773d76acc59b36b7f3c8603fa20de2060e240540b6ff56e76366" # datasource: icr.io/ibm-iac/agent-kmodule
  vuln_runtime_scanner_image_repo       = "vuln-runtime-scanner"
  vuln_runtime_scanner_image_tag_digest = "1.6.7@sha256:c7f48c12eeacce33969f69c31b9e851c86ffe2c7aaf661d4d253f1a65c40268f" # datasource: icr.io/ibm-iac/vuln-runtime-scanner
  vuln_host_scanner_image_repo          = "vuln-host-scanner"
  vuln_host_scanner_image_tag_digest    = "0.7.4@sha256:25ac73208456d7fb1f0291ef0e5a42dba98c7001c286e2b70e00ed79592a336d" # datasource: icr.io/ibm-iac/vuln-host-scanner
  agent_slim_image_repo                 = "agent-slim"
  agent_slim_image_tag_digest           = "12.19.0@sha256:4683901b1cb505f0896ef8ba0512b2edff9d2c0153178ed7f5f27ccd0d356c43" # datasource: icr.io/ibm-iac/agent-slim
  kspm_collector_image_repo             = "kspm-collector"
  kspm_collector_image_tag_digest       = "1.37.0@sha256:42f3c9965aa769338199ad16dc836760004d2f9e577d5df272e23930bd2d98de" # datasource: icr.io/ibm-iac/kspm-collector
  image_registry                        = "icr.io"
  image_namespace                       = "ibm-iac"
}

resource "helm_release" "scc_wp_agent" {
  name             = var.name
  chart            = "oci://icr.io/ibm-iac-charts/sysdig-deploy"
  version          = "1.37.8"
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
