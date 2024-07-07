##############################################################################
# SCC Workload Protection Agent
##############################################################################
locals {
  scc_domain         = "security-compliance-secure.cloud.ibm.com"
  api_endpoint       = var.endpoint_type == "private" ? "private.${var.region}.${local.scc_domain}" : "${var.region}.${local.scc_domain}"
  ingestion_endpoint = var.endpoint_type == "private" ? "ingest.private.${var.region}.${local.scc_domain}" : "ingest.${var.region}.${local.scc_domain}"

  kspm_analyzer_image_repo                   = "kspm-analyzer"
  kspm_analyzer_image_tag_digest             = "1.43.8@sha256:16d07eea42b1944037ee7468711b706de22cf1de56b519644711f6eb1910dc67" # datasource: icr.io/ibm-iac/kspm-analyzer
  agent_kmodule_image_repo                   = "agent-kmodule"
  agent_kmodule_image_tag_digest             = "13.3.0@sha256:b721f1001db3e17a370922983d0f3b5db43236fb52cd0c90a3ee909ada464b20" # datasource: icr.io/ibm-iac/agent-kmodule
  vuln_runtime_scanner_image_repo            = "vuln-runtime-scanner"
  vuln_runtime_scanner_image_tag_digest      = "1.7.1@sha256:635b56113160e940794f448a0d9b461963ae747f860cabe2a8c9c3b57b3387a6" # datasource: icr.io/ibm-iac/vuln-runtime-scanner
  vuln_host_scanner_image_repo               = "vuln-host-scanner"
  vuln_host_scanner_image_tag_digest         = "0.10.1@sha256:bd9be89d057b2303378a34e54b735c00878016651897e2670012e93edffd3c58" # datasource: icr.io/ibm-iac/vuln-host-scanner
  agent_slim_image_repo                      = "agent-slim"
  agent_slim_image_tag_digest                = "13.3.0@sha256:fff90fbdc58fc3a6f7b04b63f5ebbdc3993e7cd264f3307b491e6231dd625e0a" # datasource: icr.io/ibm-iac/agent-slim
  kspm_collector_image_repo                  = "kspm-collector"
  kspm_collector_image_tag_digest            = "1.39.2@sha256:aaea1d04ecf8a5b688cf3a63b9aa6f364b096d396bb525700a6368aa584477b1" # datasource: icr.io/ibm-iac/kspm-collector
  sbom_extractor_image_repo                  = "image-sbom-extractor"
  sbom_extractor_image_tag_digest            = "0.8.4@sha256:540078a1531dcf9190d108688e1f68b0dc4da9653ec072d759a8d95420180685" # datasource: icr.io/ibm-iac/image-sbom-extractor
  runtime_status_integrator_image_repo       = "runtime-status-integrator"
  runtime_status_integrator_image_tag_digest = "0.8.4@sha256:c91482a664b361144106354ecac8e05efbb24f6220e529132add9272d50a7327" # datasource: icr.io/ibm-iac/runtime-status-integrator
  image_registry                             = "icr.io"
  image_namespace                            = "ibm-iac"
}

resource "helm_release" "scc_wp_agent" {
  name             = var.name
  chart            = "oci://icr.io/ibm-iac-charts/sysdig-deploy"
  version          = "1.59.0"
  namespace        = var.namespace
  create_namespace = true
  timeout          = 600
  wait             = true
  recreate_pods    = true
  force_update     = true
  reset_values     = true

  set {
    name  = "agent.collectorSettings.collectorHost"
    type  = "string"
    value = local.ingestion_endpoint
  }

  set {
    name  = "agent.slim.image.repository"
    type  = "string"
    value = local.agent_slim_image_repo
  }

  set {
    name  = "agent.slim.kmoduleImage.repository"
    type  = "string"
    value = local.agent_kmodule_image_repo
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
    name  = "global.kspm.deploy"
    value = var.kspm_deploy
  }

  set {
    name  = "global.sysdig.accessKey"
    type  = "string"
    value = var.access_key
  }

  set {
    name  = "global.sysdig.apiHost"
    type  = "string"
    value = local.api_endpoint
  }

  set {
    name  = "global.sysdig.tags.deployment"
    type  = "string"
    value = var.deployment_tag
  }

  set {
    name  = "nodeAnalyzer.secure.vulnerabilityManagement.newEngineOnly"
    value = true
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.runtimeScanner.deploy"
    value = false
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.benchmarkRunner.deploy"
    value = false
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.hostScanner.deploy"
    value = var.host_scanner_deploy
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.deploy"
    value = var.node_analyzer_deploy
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.apiEndpoint"
    type  = "string"
    value = local.api_endpoint
  }

  set {
    name  = "kspmCollector.apiEndpoint"
    type  = "string"
    value = local.api_endpoint
  }

  set {
    name  = "clusterScanner.enabled"
    value = var.cluster_scanner_deploy
  }

  set {
    name  = "clusterScanner.eveEnabled"
    value = true
  }

  set {
    name  = "agent.image.registry"
    type  = "string"
    value = local.image_registry
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
    name  = "agent.image.tag"
    type  = "string"
    value = local.agent_slim_image_tag_digest
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

  set {
    name  = "clusterScanner.imageSbomExtractor.image.repository"
    type  = "string"
    value = local.sbom_extractor_image_repo
  }

  set {
    name  = "clusterScanner.imageSbomExtractor.image.tag"
    type  = "string"
    value = local.sbom_extractor_image_tag_digest
  }

  set {
    name  = "clusterScanner.runtimeStatusIntegrator.image.repository"
    type  = "string"
    value = local.runtime_status_integrator_image_repo
  }

  set {
    name  = "clusterScanner.runtimeStatusIntegrator.image.tag"
    type  = "string"
    value = local.runtime_status_integrator_image_tag_digest
  }

}
