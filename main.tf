##############################################################################
# SCC Workload Protection Agent
##############################################################################
locals {
  scc_domain         = "security-compliance-secure.cloud.ibm.com"
  api_endpoint       = var.endpoint_type == "private" ? "private.${var.region}.${local.scc_domain}" : "${var.region}.${local.scc_domain}"
  ingestion_endpoint = var.endpoint_type == "private" ? "ingest.private.${var.region}.${local.scc_domain}" : "ingest.${var.region}.${local.scc_domain}"

  kspm_analyzer_image_repo                   = "kspm-analyzer"
  kspm_analyzer_image_tag_digest             = "1.44.33@sha256:c3fd1a86d60b6460487453f1b8899b10cb18b027049b8d7a7fa914210e5318ae" # datasource: icr.io/ext/sysdig/kspm-analyzer
  agent_kmodule_image_repo                   = "agent-kmodule"
  agent_kmodule_image_tag_digest             = "13.8.0@sha256:370b0eaa567068cdb9e735e3b956f16c8f004a12a8d9109f6925430b3c2ba2d1" # datasource: icr.io/ext/sysdig/agent-kmodule
  vuln_runtime_scanner_image_repo            = "vuln-runtime-scanner"
  vuln_runtime_scanner_image_tag_digest      = "1.8.0@sha256:2cb5a33765445bfb072d1be2cd948bfdd3d1cf82f2be6c46f54388d4c88c6215" # datasource: icr.io/ext/sysdig/vuln-runtime-scanner
  vuln_host_scanner_image_repo               = "vuln-host-scanner"
  vuln_host_scanner_image_tag_digest         = "0.13.0@sha256:de8d854003e28bf7e2dcdb9d3f10f8b34ff0fec0c40198f573f5e4cf3fc1d53e" # datasource: icr.io/ext/sysdig/vuln-host-scanner
  agent_slim_image_repo                      = "agent-slim"
  agent_slim_image_tag_digest                = "13.8.0@sha256:7faa495571c446da9700ca47160c38bc9b213de496d2348174c05d95d2dfa02e" # datasource: icr.io/ext/sysdig/agent-slim
  kspm_collector_image_repo                  = "kspm-collector"
  kspm_collector_image_tag_digest            = "1.39.8@sha256:0b71ee0ccb94d3838374f99a9b57569fb25a089fc37c50bde7c51f72c2c94b82" # datasource: icr.io/ext/sysdig/kspm-collector
  sbom_extractor_image_repo                  = "image-sbom-extractor"
  sbom_extractor_image_tag_digest            = "0.10.0@sha256:59543aa19bcdea4973f3d70351b8e1df60c5de998eb829c143a9f9deaed10a7b" # datasource: icr.io/ext/sysdig/image-sbom-extractor
  runtime_status_integrator_image_repo       = "runtime-status-integrator"
  runtime_status_integrator_image_tag_digest = "0.10.0@sha256:524cadd672c276c04845081c6fff4999c37f860a60117821c60d173b9d50a0ab" # datasource: icr.io/ext/sysdig/runtime-status-integrator
  cluster_shield_image_repo                  = "cluster-shield"
  cluster_shield_image_tag_digest            = "1.8.2@sha256:a28ee903b354b12c956992bc4d65a2e386dc5ce0cd35e143d07f9789579bde88" # datasource: icr.io/ext/sysdig/cluster-shield
  image_registry                             = "icr.io"
  image_namespace                            = "ext/sysdig"

  # input variable validation
  # tflint-ignore: terraform_unused_declarations
  validate_cluster_shield = var.cluster_shield_deploy && (var.cluster_scanner_deploy || var.kspm_deploy) ? tobool("var.kspm_deploy or var.cluster_scanner_deploy cannot be enabled if var.cluster_shield_deploy is true") : true
}

resource "helm_release" "scc_wp_agent" {
  name             = var.name
  repository       = "https://charts.sysdig.com"
  chart            = "sysdig-deploy"
  version          = "1.78.0"
  namespace        = var.namespace
  create_namespace = true
  timeout          = 1500
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
    name  = "kspmCollector.enabled"
    value = var.kspm_deploy && !var.cluster_shield_deploy # Only enable kspm collector if cluster shield not enabled
  }

  set {
    name  = "kspmCollector.apiEndpoint"
    type  = "string"
    value = local.api_endpoint
  }

  set {
    name  = "clusterScanner.enabled"
    value = var.cluster_scanner_deploy && !var.cluster_shield_deploy # Only enable cluster scanner if cluster shield not enabled
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

  set {
    name  = "agent.resources.requests.cpu"
    type  = "string"
    value = var.agent_requests_cpu
  }

  set {
    name  = "agent.resources.requests.memory"
    type  = "string"
    value = var.agent_requests_memory
  }

  set {
    name  = "agent.resources.limits.cpu"
    type  = "string"
    value = var.agent_limits_cpu
  }

  set {
    name  = "agent.resources.limits.memory"
    type  = "string"
    value = var.agent_limits_memory
  }

  set {
    name  = "kspmCollector.resources.requests.cpu"
    type  = "string"
    value = var.kspm_collector_requests_cpu
  }

  set {
    name  = "kspmCollector.resources.requests.memory"
    type  = "string"
    value = var.kspm_collector_requests_memory
  }

  set {
    name  = "kspmCollector.resources.limits.cpu"
    type  = "string"
    value = var.kspm_collector_limits_cpu
  }

  set {
    name  = "kspmCollector.resources.limits.memory"
    type  = "string"
    value = var.kspm_collector_limits_memory
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.kspmAnalyzer.resources.requests.cpu"
    type  = "string"
    value = var.kspm_analyzer_requests_cpu
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.kspmAnalyzer.resources.requests.memory"
    type  = "string"
    value = var.kspm_analyzer_requests_memory
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.kspmAnalyzer.resources.limits.cpu"
    type  = "string"
    value = var.kspm_analyzer_limits_cpu
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.kspmAnalyzer.resources.limits.memory"
    type  = "string"
    value = var.kspm_analyzer_limits_memory
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.hostScanner.resources.requests.cpu"
    type  = "string"
    value = var.host_scanner_requests_cpu
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.hostScanner.resources.requests.memory"
    type  = "string"
    value = var.host_scanner_requests_memory
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.hostScanner.resources.limits.cpu"
    type  = "string"
    value = var.host_scanner_limits_cpu
  }

  set {
    name  = "nodeAnalyzer.nodeAnalyzer.hostScanner.resources.limits.memory"
    type  = "string"
    value = var.host_scanner_limits_memory
  }

  set {
    name  = "clusterScanner.runtimeStatusIntegrator.resources.requests.cpu"
    type  = "string"
    value = var.cluster_scanner_runtimestatusintegrator_requests_cpu
  }

  set {
    name  = "clusterScanner.runtimeStatusIntegrator.resources.requests.memory"
    type  = "string"
    value = var.cluster_scanner_runtimestatusintegrator_requests_memory
  }

  set {
    name  = "clusterScanner.runtimeStatusIntegrator.resources.limits.cpu"
    type  = "string"
    value = var.cluster_scanner_runtimestatusintegrator_limits_cpu
  }

  set {
    name  = "clusterScanner.runtimeStatusIntegrator.resources.limits.memory"
    type  = "string"
    value = var.cluster_scanner_runtimestatusintegrator_limits_memory
  }

  set {
    name  = "clusterScanner.imageSbomExtractor.resources.requests.cpu"
    type  = "string"
    value = var.cluster_scanner_imagesbomextractor_requests_cpu
  }

  set {
    name  = "clusterScanner.imageSbomExtractor.resources.requests.memory"
    type  = "string"
    value = var.cluster_scanner_imagesbomextractor_requests_memory
  }

  set {
    name  = "clusterScanner.imageSbomExtractor.resources.limits.cpu"
    type  = "string"
    value = var.cluster_scanner_imagesbomextractor_limits_cpu
  }

  set {
    name  = "clusterScanner.imageSbomExtractor.resources.limits.memory"
    type  = "string"
    value = var.cluster_scanner_imagesbomextractor_limits_memory
  }

  set {
    name  = "clusterShield.enabled"
    value = var.cluster_shield_deploy
  }

  set {
    name  = "clusterShield.image.repository"
    value = local.cluster_shield_image_repo
  }

  set {
    name  = "clusterShield.image.tag"
    value = local.cluster_shield_image_tag_digest
  }

  set {
    name  = "clusterShield.cluster_shield.sysdig_endpoint.region"
    type  = "string"
    value = "custom"
  }

  set {
    name  = "clusterShield.cluster_shield.log_level"
    type  = "string"
    value = "info"
  }

  set {
    name  = "clusterShield.cluster_shield.features.admission_control.enabled"
    value = true
  }

  set {
    name  = "clusterShield.cluster_shield.features.container_vulnerability_management.enabled"
    value = true
  }

  set {
    name  = "clusterShield.cluster_shield.features.audit.enabled"
    value = true
  }

  set {
    name  = "clusterShield.cluster_shield.features.posture.enabled"
    value = true
  }

}
