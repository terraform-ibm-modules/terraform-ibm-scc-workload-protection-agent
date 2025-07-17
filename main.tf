##############################################################################
# SCC Workload Protection Agent
##############################################################################
locals {
  scc_domain         = "security-compliance-secure.cloud.ibm.com"
  api_endpoint       = var.endpoint_type == "private" ? "private.${var.region}.${local.scc_domain}" : "${var.region}.${local.scc_domain}"
  ingestion_endpoint = var.endpoint_type == "private" ? "ingest.private.${var.region}.${local.scc_domain}" : "ingest.${var.region}.${local.scc_domain}"

  kspm_analyzer_image_repo                   = "kspm-analyzer"
  kspm_analyzer_image_tag_digest             = "1.45.0@sha256:a963f432a7842c916404165a70a02616cf3c51c908c361ab5daa27fd195ba56b" # datasource: icr.io/ext/sysdig/kspm-analyzer
  agent_kmodule_image_repo                   = "agent-kmodule"
  agent_kmodule_image_tag_digest             = "14.0.1@sha256:9b1e900e2cd47cabe31b36f6ed41705b33e849de0639b29b326fb73e67ed8b68" # datasource: icr.io/ext/sysdig/agent-kmodule
  vuln_runtime_scanner_image_repo            = "vuln-runtime-scanner"
  vuln_runtime_scanner_image_tag_digest      = "1.8.0@sha256:2cb5a33765445bfb072d1be2cd948bfdd3d1cf82f2be6c46f54388d4c88c6215" # datasource: icr.io/ext/sysdig/vuln-runtime-scanner
  vuln_host_scanner_image_repo               = "vuln-host-scanner"
  vuln_host_scanner_image_tag_digest         = "0.13.7@sha256:e5cf28635c2096cedc5d1272c56e81cafc92cd424466dc2ef5e50e28daee6ba4" # datasource: icr.io/ext/sysdig/vuln-host-scanner
  agent_slim_image_repo                      = "agent-slim"
  agent_slim_image_tag_digest                = "14.0.1@sha256:b1f5bf4677632c715e9a5cde9af8d36dd66f5e79c80aadfd4b74dc5cc310a570" # datasource: icr.io/ext/sysdig/agent-slim
  kspm_collector_image_repo                  = "kspm-collector"
  kspm_collector_image_tag_digest            = "1.39.12@sha256:b8f77e72f159fc9110ec11a710cab40cd32b7ab5cf5130edf019499af841de65" # datasource: icr.io/ext/sysdig/kspm-collector
  sbom_extractor_image_repo                  = "image-sbom-extractor"
  sbom_extractor_image_tag_digest            = "0.10.0@sha256:59543aa19bcdea4973f3d70351b8e1df60c5de998eb829c143a9f9deaed10a7b" # datasource: icr.io/ext/sysdig/image-sbom-extractor
  runtime_status_integrator_image_repo       = "runtime-status-integrator"
  runtime_status_integrator_image_tag_digest = "0.10.0@sha256:524cadd672c276c04845081c6fff4999c37f860a60117821c60d173b9d50a0ab" # datasource: icr.io/ext/sysdig/runtime-status-integrator
  cluster_shield_image_repo                  = "cluster-shield"
  cluster_shield_image_tag_digest            = "1.13.0@sha256:0c8ee65a473e51b2a2c7bddf4e89008299cf203c50cd80fd97503cb121c1230a" # datasource: icr.io/ext/sysdig/cluster-shield
  image_registry                             = "icr.io"
  image_namespace                            = "ext/sysdig"
}

resource "helm_release" "scc_wp_agent" {
  name             = var.name
  repository       = "https://charts.sysdig.com"
  chart            = "sysdig-deploy"
  version          = "1.89.1"
  namespace        = var.namespace
  create_namespace = true
  timeout          = 1500
  wait             = true
  recreate_pods    = true
  force_update     = true
  reset_values     = true

  set = [
    {
      name  = "agent.collectorSettings.collectorHost"
      type  = "string"
      value = local.ingestion_endpoint
    },
    {
      name  = "agent.slim.image.repository"
      type  = "string"
      value = local.agent_slim_image_repo
    },
    {
      name  = "agent.slim.kmoduleImage.repository"
      type  = "string"
      value = local.agent_kmodule_image_repo
    },
    {
      name  = "agent.slim.enabled"
      value = true
    },
    {
      name  = "global.clusterConfig.name"
      type  = "string"
      value = var.cluster_name
    },
    {
      name  = "global.kspm.deploy"
      value = var.kspm_deploy
    },
    {
      name  = "global.sysdig.accessKey"
      type  = "string"
      value = var.access_key
    },
    {
      name  = "global.sysdig.apiHost"
      type  = "string"
      value = local.api_endpoint
    },
    {
      name  = "global.sysdig.tags.deployment"
      type  = "string"
      value = var.deployment_tag
    },
    {
      name  = "nodeAnalyzer.secure.vulnerabilityManagement.newEngineOnly"
      value = true
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.runtimeScanner.deploy"
      value = false
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.benchmarkRunner.deploy"
      value = false
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.hostScanner.deploy"
      value = var.host_scanner_deploy
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.deploy"
      value = var.node_analyzer_deploy
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.apiEndpoint"
      type  = "string"
      value = local.api_endpoint
    },
    {
      name  = "kspmCollector.enabled"
      value = var.kspm_deploy && !var.cluster_shield_deploy # Only enable kspm collector if cluster shield not enabled
    },
    {
      name  = "kspmCollector.apiEndpoint"
      type  = "string"
      value = local.api_endpoint
    },
    {
      name  = "clusterScanner.enabled"
      value = var.cluster_scanner_deploy && !var.cluster_shield_deploy # Only enable cluster scanner if cluster shield not enabled
    },
    {
      name  = "clusterScanner.eveEnabled"
      value = true
    },
    {
      name  = "agent.image.registry"
      type  = "string"
      value = local.image_registry
    },
    {
      name  = "Values.image.repository"
      type  = "string"
      value = local.image_registry
    },
    {
      name  = "global.imageRegistry"
      type  = "string"
      value = "${local.image_registry}/${local.image_namespace}"
    },
    {
      name  = "kspmCollector.image.repository"
      type  = "string"
      value = local.kspm_collector_image_repo
    },
    {
      name  = "kspmCollector.image.tag"
      type  = "string"
      value = local.kspm_collector_image_tag_digest
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.kspmAnalyzer.image.repository"
      type  = "string"
      value = local.kspm_analyzer_image_repo
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.kspmAnalyzer.image.tag"
      type  = "string"
      value = local.kspm_analyzer_image_tag_digest
    },
    {
      name  = "agent.image.tag"
      type  = "string"
      value = local.agent_slim_image_tag_digest
    },
    {
      name  = "agent.slim.kmoduleImage.digest"
      type  = "string"
      value = regex("@(.*)", local.agent_kmodule_image_tag_digest)[0]
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.runtimeScanner.image.tag"
      type  = "string"
      value = local.vuln_runtime_scanner_image_tag_digest
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.runtimeScanner.image.repository"
      type  = "string"
      value = local.vuln_runtime_scanner_image_repo
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.hostScanner.image.tag"
      type  = "string"
      value = local.vuln_host_scanner_image_tag_digest
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.hostScanner.image.repository"
      type  = "string"
      value = local.vuln_host_scanner_image_repo
    },
    {
      name  = "clusterScanner.imageSbomExtractor.image.repository"
      type  = "string"
      value = local.sbom_extractor_image_repo
    },
    {
      name  = "clusterScanner.imageSbomExtractor.image.tag"
      type  = "string"
      value = local.sbom_extractor_image_tag_digest
    },
    {
      name  = "clusterScanner.runtimeStatusIntegrator.image.repository"
      type  = "string"
      value = local.runtime_status_integrator_image_repo
    },
    {
      name  = "clusterScanner.runtimeStatusIntegrator.image.tag"
      type  = "string"
      value = local.runtime_status_integrator_image_tag_digest
    },
    {
      name  = "agent.resources.requests.cpu"
      type  = "string"
      value = var.agent_requests_cpu
    },
    {
      name  = "agent.resources.requests.memory"
      type  = "string"
      value = var.agent_requests_memory
    },
    {
      name  = "agent.resources.limits.cpu"
      type  = "string"
      value = var.agent_limits_cpu
    },
    {
      name  = "agent.resources.limits.memory"
      type  = "string"
      value = var.agent_limits_memory
    },
    {
      name  = "kspmCollector.resources.requests.cpu"
      type  = "string"
      value = var.kspm_collector_requests_cpu
    },
    {
      name  = "kspmCollector.resources.requests.memory"
      type  = "string"
      value = var.kspm_collector_requests_memory
    },
    {
      name  = "kspmCollector.resources.limits.cpu"
      type  = "string"
      value = var.kspm_collector_limits_cpu
    },
    {
      name  = "kspmCollector.resources.limits.memory"
      type  = "string"
      value = var.kspm_collector_limits_memory
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.kspmAnalyzer.resources.requests.cpu"
      type  = "string"
      value = var.kspm_analyzer_requests_cpu
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.kspmAnalyzer.resources.requests.memory"
      type  = "string"
      value = var.kspm_analyzer_requests_memory
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.kspmAnalyzer.resources.limits.cpu"
      type  = "string"
      value = var.kspm_analyzer_limits_cpu
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.kspmAnalyzer.resources.limits.memory"
      type  = "string"
      value = var.kspm_analyzer_limits_memory
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.hostScanner.resources.requests.cpu"
      type  = "string"
      value = var.host_scanner_requests_cpu
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.hostScanner.resources.requests.memory"
      type  = "string"
      value = var.host_scanner_requests_memory
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.hostScanner.resources.limits.cpu"
      type  = "string"
      value = var.host_scanner_limits_cpu
    },
    {
      name  = "nodeAnalyzer.nodeAnalyzer.hostScanner.resources.limits.memory"
      type  = "string"
      value = var.host_scanner_limits_memory
    },
    {
      name  = "clusterScanner.runtimeStatusIntegrator.resources.requests.cpu"
      type  = "string"
      value = var.cluster_scanner_runtimestatusintegrator_requests_cpu
    },
    {
      name  = "clusterScanner.runtimeStatusIntegrator.resources.requests.memory"
      type  = "string"
      value = var.cluster_scanner_runtimestatusintegrator_requests_memory
    },
    {
      name  = "clusterScanner.runtimeStatusIntegrator.resources.limits.cpu"
      type  = "string"
      value = var.cluster_scanner_runtimestatusintegrator_limits_cpu
    },
    {
      name  = "clusterScanner.runtimeStatusIntegrator.resources.limits.memory"
      type  = "string"
      value = var.cluster_scanner_runtimestatusintegrator_limits_memory
    },
    {
      name  = "clusterScanner.imageSbomExtractor.resources.requests.cpu"
      type  = "string"
      value = var.cluster_scanner_imagesbomextractor_requests_cpu
    },
    {
      name  = "clusterScanner.imageSbomExtractor.resources.requests.memory"
      type  = "string"
      value = var.cluster_scanner_imagesbomextractor_requests_memory
    },
    {
      name  = "clusterScanner.imageSbomExtractor.resources.limits.cpu"
      type  = "string"
      value = var.cluster_scanner_imagesbomextractor_limits_cpu
    },
    {
      name  = "clusterScanner.imageSbomExtractor.resources.limits.memory"
      type  = "string"
      value = var.cluster_scanner_imagesbomextractor_limits_memory
    },
    {
      name  = "clusterShield.enabled"
      value = var.cluster_shield_deploy
    },
    {
      name  = "clusterShield.image.repository"
      value = local.cluster_shield_image_repo
    },
    {
      name  = "clusterShield.image.tag"
      value = local.cluster_shield_image_tag_digest
    },
    {
      name  = "clusterShield.cluster_shield.sysdig_endpoint.region"
      type  = "string"
      value = "custom"
    },
    {
      name  = "clusterShield.cluster_shield.log_level"
      type  = "string"
      value = "info"
    },
    {
      name  = "clusterShield.cluster_shield.features.admission_control.enabled"
      value = true
    },
    {
      name  = "clusterShield.cluster_shield.features.container_vulnerability_management.enabled"
      value = true
    },
    {
      name  = "clusterShield.cluster_shield.features.audit.enabled"
      value = true
    },
    {
      name  = "clusterShield.cluster_shield.features.posture.enabled"
      value = true
    },
    {
      name  = "agent.ebpf.enabled"
      value = var.universal_ebpf
    },
    {
      name  = "agent.ebpf.kind"
      value = "universal_ebpf"
    }
  ]
}
