##############################################################################
# SCC Workload Protection Agent
##############################################################################
locals {
  scc_domain         = "security-compliance-secure.cloud.ibm.com"
  api_endpoint       = var.endpoint_type == "private" ? "private.${var.region}.${local.scc_domain}" : "${var.region}.${local.scc_domain}"
  ingestion_endpoint = var.endpoint_type == "private" ? "ingest.private.${var.region}.${local.scc_domain}" : "ingest.${var.region}.${local.scc_domain}"

  kspm_analyzer_image_repo              = "kspm-analyzer"
  kspm_analyzer_image_tag_digest        = "1.38.0@sha256:81c2bad292154951b96e9ed8cfb1baaa1e0c57cd16748654371a1932533f3e5a" # datasource: icr.io/ibm-iac/kspm-analyzer
  agent_kmodule_image_repo              = "agent-kmodule"
  agent_kmodule_image_tag_digest        = "12.18.0@sha256:2abb706fb3c4b6ab9e3e464127badde0a1ca95f242354f75fea802734561897c" # datasource: icr.io/ibm-iac/agent-kmodule
  vuln_runtime_scanner_image_repo       = "vuln-runtime-scanner"
  vuln_runtime_scanner_image_tag_digest = "1.6.6@sha256:b26e0cd89712441c6335d69b54e50711a6b81ef8c2a99313143d12c7728549ac" # datasource: icr.io/ibm-iac/vuln-runtime-scanner
  vuln_host_scanner_image_repo          = "vuln-host-scanner"
  vuln_host_scanner_image_tag_digest    = "0.6.8@sha256:fb62345feaaa3f8a2d5511b6c50cdfa74d5245acc232ad669953662aba6980b2" # datasource: icr.io/ibm-iac/vuln-host-scanner
  agent_slim_image_repo                 = "agent-slim"
  agent_slim_image_tag_digest           = "12.18.0@sha256:5c57308fb5063f377e6b9559749ba2bd21dce405c596c3d167f62e3861e89477" # datasource: icr.io/ibm-iac/agent-slim
  kspm_collector_image_repo             = "kspm-collector"
  kspm_collector_image_tag_digest       = "1.36.0@sha256:23b3b876e3c10266aec62cbae79684d39bc2eb621ed8ec140d75364b1e786846" # datasource: icr.io/ibm-iac/kspm-collector
  image_registry                        = "icr.io"
  image_namespace                       = "ibm-iac"
}

resource "helm_release" "scc_wp_agent" {
  name             = var.name
  chart            = "oci://icr.io/ibm-iac-charts/sysdig-deploy"
  version          = "1.34.4"
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
