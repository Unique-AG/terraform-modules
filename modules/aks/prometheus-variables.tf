variable "prometheus_node_alert_rules" {

  type = list(object({
    action = optional(object({
      action_group_id = string
    }))
    alert       = optional(string)
    annotations = optional(map(string))
    enabled     = optional(bool)
    expression  = string
    for         = optional(string)
    labels      = optional(map(string))
    record      = optional(string)
    alert_resolution = optional(object({
      auto_resolved   = bool
      time_to_resolve = string
    }))
    severity = optional(number)
  }))

  default = [
    {
      alert      = "KubeNodeUnreachable"
      enabled    = true
      expression = <<EOF
(kube_node_spec_taint{job="kube-state-metrics",key="node.kubernetes.io/unreachable",effect="NoSchedule"} unless ignoring(key,value) kube_node_spec_taint{job="kube-state-metrics",key=~"ToBeDeletedByClusterAutoscaler|cloud.google.com/imminent-node-termination|aws-node-termination-handler/spot-itn"} == 1)
EOF
      for        = "PT15M"
      severity   = 3
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      annotations = {
        description = "{{ $labels.node }} in {{ $labels.cluster }} is unreachable."
      }
      labels = {
        team       = "prod"
        alert_name = "KubeNodeUnreachable"
      }
    },
    {
      alert      = "KubeNodeReadinessFlapping"
      enabled    = true
      expression = "sum(changes(kube_node_status_condition{status=\"true\",condition=\"Ready\"}[15m])) by (cluster, node) > 2"
      for        = "PT15M"
      severity   = 3
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      annotations = {
        description = "Node readiness is flapping."
      }
      labels = {
        team       = "prod"
        alert_name = "KubeNodeReadinessFlapping"
      }
    }
  ]
}

variable "prometheus_cluster_alert_rules" {
  type = list(object({
    action = optional(object({
      action_group_id = string
    }))
    alert       = optional(string)
    annotations = optional(map(string))
    enabled     = optional(bool)
    expression  = string
    for         = optional(string)
    labels      = optional(map(string))
    record      = optional(string)
    alert_resolution = optional(object({
      auto_resolved   = bool
      time_to_resolve = string
    }))
    severity = optional(number)
  }))

  default = [
    {
      alert = "KubeCPUQuotaOvercommit"
      annotations = {
        description = "Cluster {{ $labels.cluster }} has overcommitted CPU resource requests for Namespaces. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."
      }
      enabled    = true
      expression = "sum(min without(resource) (kube_resourcequota{job=\"kube-state-metrics\", type=\"hard\", resource=~\"(cpu|requests.cpu)\"})) / sum(kube_node_status_allocatable{resource=\"cpu\", job=\"kube-state-metrics\"}) > 1.5"
      for        = "PT5M"
      labels = {
        severity = "warning"
      }
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      severity = 3
    },
    {
      alert = "KubeMemoryQuotaOvercommit"
      annotations = {
        description = "Cluster {{ $labels.cluster }} has overcommitted memory resource requests for Namespaces. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."
      }
      enabled    = true
      expression = "sum(min without(resource) (kube_resourcequota{job=\"kube-state-metrics\", type=\"hard\", resource=~\"(memory|requests.memory)\"})) / sum(kube_node_status_allocatable{resource=\"memory\", job=\"kube-state-metrics\"}) > 1.5"
      for        = "PT5M"
      labels     = {}
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      severity = 3
    },
    {
      alert = "KubeContainerOOMKilledCount"
      annotations = {
        description = "Number of OOM killed containers is greater than 0. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."
      }
      enabled    = true
      expression = "sum by (cluster,container,controller,namespace) (kube_pod_container_status_last_terminated_reason{reason=\"OOMKilled\"} * on(cluster,namespace,pod) group_left(controller) label_replace(kube_pod_owner, \"controller\", \"$1\", \"owner_name\", \".*\")) > 0"
      for        = "PT5M"
      labels     = {}
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      severity = 4
    },
    {
      alert = "KubeClientErrors"
      annotations = {
        description = "Kubernetes API server client '{{ $labels.job }}/{{ $labels.instance }}' is experiencing {{ $value | humanizePercentage }} errors. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."
      }
      enabled    = true
      expression = "(sum(rate(rest_client_requests_total{code=~\"5..\"}[5m])) by (cluster, instance, job, namespace) / sum(rate(rest_client_requests_total[5m])) by (cluster, instance, job, namespace)) > 0.01"
      for        = "PT15M"
      labels     = {}
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      severity = 3
    },
    {
      alert = "KubePersistentVolumeFillingUp"
      annotations = {
        description = "Based on recent sampling, the PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} is expected to fill up within four days. Currently {{ $value | humanizePercentage }} is available. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."
      }
      enabled    = true
      expression = "kubelet_volume_stats_available_bytes{job=\"kubelet\"}/kubelet_volume_stats_capacity_bytes{job=\"kubelet\"} < 0.15 and kubelet_volume_stats_used_bytes{job=\"kubelet\"} > 0 and predict_linear(kubelet_volume_stats_available_bytes{job=\"kubelet\"}[6h], 4 * 24 * 3600) < 0 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_access_mode{access_mode=\"ReadOnlyMany\"} == 1 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_labels{label_excluded_from_alerts=\"true\"} == 1"
      for        = "PT15M"
      labels     = {}
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT15M"
      }
      severity = 4
    },
    {
      alert = "KubePersistentVolumeInodesFillingUp"
      annotations = {
        description = "The PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} only has {{ $value | humanizePercentage }} free inodes. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."
      }
      enabled    = true
      expression = "kubelet_volume_stats_inodes_free{job=\"kubelet\"} / kubelet_volume_stats_inodes{job=\"kubelet\"} < 0.03"
      for        = "PT15M"
      labels     = {}
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      severity = 4
    },
    {
      alert = "KubePersistentVolumeErrors"
      annotations = {
        description = "The persistent volume {{ $labels.persistentvolume }} has status {{ $labels.phase }}. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."
      }
      enabled    = true
      expression = "kube_persistentvolume_status_phase{phase=~\"Failed|Pending\",job=\"kube-state-metrics\"} > 0"
      for        = "PT15M"
      labels     = {}
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      severity = 4
    },
    {
      alert = "KubeDaemonSetNotScheduled"
      annotations = {
        description = "{{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} are not scheduled. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."
      }
      enabled    = true
      expression = "kube_daemonset_status_desired_number_scheduled{job=\"kube-state-metrics\"} - kube_daemonset_status_current_number_scheduled{job=\"kube-state-metrics\"} > 0"
      for        = "PT15M"
      labels     = {}
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      severity = 3
    },
    {
      alert = "KubeDaemonSetMisScheduled"
      annotations = {
        description = "{{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} are running where they are not supposed to run. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."
      }
      enabled    = true
      expression = "kube_daemonset_status_number_misscheduled{job=\"kube-state-metrics\"} > 0"
      for        = "PT15M"
      labels     = {}
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      severity = 3
    },
    {
      alert = "KubeQuotaAlmostFull"
      annotations = {
        description = "{{ $value | humanizePercentage }} usage of {{ $labels.resource }} in namespace {{ $labels.namespace }} in {{ $labels.cluster }}. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/cluster-level-recommended-alerts)."
      }
      enabled    = true
      expression = "kube_resourcequota{job=\"kube-state-metrics\", type=\"used\"} / ignoring(instance, job, type)(kube_resourcequota{job=\"kube-state-metrics\", type=\"hard\"} > 0) > 0.9 < 1"
      for        = "PT15M"
      labels     = {}
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      severity = 3
    }

  ]
}

variable "prometheus_pod_alert_rules" {

  type = list(object({
    action = optional(object({
      action_group_id = string
    }))
    alert       = optional(string)
    annotations = optional(map(string))
    enabled     = optional(bool)
    expression  = string
    for         = optional(string)
    labels      = optional(map(string))
    record      = optional(string)
    alert_resolution = optional(object({
      auto_resolved   = bool
      time_to_resolve = string
    }))
    severity = optional(number)
  }))

  default = [
    {
      alert      = "KubePVUsageHigh"
      enabled    = true
      expression = <<EOF
avg by (namespace, controller, container, cluster) (
  (kubelet_volume_stats_used_bytes{job="kubelet"} / on(namespace, cluster, pod, container) group_left
  kubelet_volume_stats_capacity_bytes{job="kubelet"}) * on(namespace, pod, cluster) group_left(controller)
  label_replace(kube_pod_owner, "controller", "$1", "owner_name", "(.*)")
) > 0.8
EOF
      for        = "PT15M"
      severity   = 3
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      annotations = {
        description = "Average PV usage on pod {{ $labels.pod }} in container {{ $labels.container }} is greater than 80%. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."
      }
      labels = {
        alert_name = "KubePVUsageHigh"
      }
    },
    {
      alert      = "KubeDeploymentReplicasMismatch"
      enabled    = true
      expression = <<EOF
(
  kube_deployment_spec_replicas{job="kube-state-metrics"} > kube_deployment_status_replicas_available{job="kube-state-metrics"}
  and (changes(kube_deployment_status_replicas_updated{job="kube-state-metrics"}[10m]) == 0)
)
EOF
      for        = "PT15M"
      severity   = 4
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT15M"
      }
      annotations = {
        description = "Deployment {{ $labels.namespace }}/{{ $labels.deployment }} in {{ $labels.cluster}} replica mismatch. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."
      }
      labels = {
        alert_name = "KubeDeploymentReplicasMismatch"
      }
    },
    {
      alert      = "KubeStatefulSetReplicasMismatch"
      enabled    = true
      expression = <<EOF
(
  kube_statefulset_status_replicas_ready{job="kube-state-metrics"} != kube_statefulset_status_replicas{job="kube-state-metrics"}
  and (changes(kube_statefulset_status_replicas_updated{job="kube-state-metrics"}[10m]) == 0)
)
EOF
      for        = "PT15M"
      severity   = 4
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      annotations = {
        description = "StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} in {{ $labels.cluster}} replica mismatch. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."
      }
      labels = {
        alert_name = "KubeStatefulSetReplicasMismatch"
      }
    },
    {
      alert      = "KubeHpaReplicasMismatch"
      enabled    = true
      expression = <<EOF
(
  kube_horizontalpodautoscaler_status_desired_replicas{job="kube-state-metrics"} != kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics"}
  and (kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics"} > kube_horizontalpodautoscaler_spec_min_replicas{job="kube-state-metrics"})
  and (kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics"} < kube_horizontalpodautoscaler_spec_max_replicas{job="kube-state-metrics"})
  and (changes(kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics"}[15m]) == 0)
)
EOF
      for        = "PT15M"
      severity   = 4
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT15M"
      }
      annotations = {
        description = "Horizontal Pod Autoscaler in {{ $labels.cluster}} has not matched the desired number of replicas for longer than 15 minutes. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."
      }
      labels = {
        alert_name = "KubeHpaReplicasMismatch"
      }
    },
    {
      alert      = "KubeHpaMaxedOut"
      enabled    = true
      expression = <<EOF
kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics"} == kube_horizontalpodautoscaler_spec_max_replicas{job="kube-state-metrics"}
EOF
      for        = "PT15M"
      severity   = 4
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT15M"
      }
      annotations = {
        description = "Horizontal Pod Autoscaler in {{ $labels.cluster}} has been running at max replicas for longer than 15 minutes. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."
      }
      labels = {
        alert_name = "KubeHpaMaxedOut"
      }
    },
    {
      alert      = "KubePodCrashLooping"
      enabled    = true
      expression = <<EOF
max_over_time(kube_pod_container_status_waiting_reason{reason="CrashLoopBackOff", job="kube-state-metrics"}[5m]) >= 1
EOF
      for        = "PT15M"
      severity   = 4
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      annotations = {
        description = "{{ $labels.namespace }}/{{ $labels.pod }} ({{ $labels.container }}) in {{ $labels.cluster}} is restarting {{ printf \"%.2f\" $value }} / second. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."
      }
      labels = {
        alert_name = "KubePodCrashLooping"
      }
    },
    {
      alert      = "KubePodContainerRestart"
      enabled    = true
      expression = <<EOF
sum by (namespace, controller, container, cluster)
(increase(kube_pod_container_status_restarts_total{job="kube-state-metrics"}[1h])
* on(namespace, pod, cluster) group_left(controller)
label_replace(kube_pod_owner, "controller", "$1", "owner_name", "(.*)")) > 0
EOF
      for        = "PT15M"
      severity   = 4
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      annotations = {
        description = "Pod container restarted in last 1 hour. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."
      }
      labels = {
        alert_name = "KubePodContainerRestart"
      }
    },
    {
      alert      = "KubePodReadyStateLow"
      enabled    = true
      expression = <<EOF
sum by (cluster,namespace,deployment)
(kube_deployment_status_replicas_ready) / sum by
(cluster,namespace,deployment)(kube_deployment_spec_replicas) < .8 or sum
by (cluster,namespace,deployment)(kube_daemonset_status_number_ready) /
sum by (cluster,namespace,deployment)(kube_daemonset_status_desired_number_scheduled) < .8
EOF
      for        = "PT5M"
      severity   = 4
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT15M"
      }
      annotations = {
        description = "Ready state of pods is less than 80%. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."
      }
      labels = {
        alert_name = "KubePodReadyStateLow"
      }
    },
    {
      alert      = "KubePodFailedState"
      enabled    = true
      expression = <<EOF
    sum by (cluster, namespace, controller)
    (kube_pod_status_phase{phase="failed"} * on(namespace, pod, cluster)
    group_left(controller) label_replace(kube_pod_owner, "controller", "$1", "owner_name", "(.*)")) > 0
    EOF
      for        = "PT5M"
      severity   = 4
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT15M"
      }
      annotations = {
        description = "Number of pods in failed state are greater than 0. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."
      }
      labels = {
        alert_name = "KubePodFailedState"
      }
    },
    {
      alert      = "KubePodNotReadyByController"
      enabled    = true
      expression = <<EOF
    sum by (namespace, controller, cluster) (max by(namespace, pod, cluster)
    (kube_pod_status_phase{job="kube-state-metrics", phase=~"Pending|Unknown"})
    * on(namespace, pod, cluster) group_left(controller)
    label_replace(kube_pod_owner, "controller", "$1", "owner_name", "(.*)")) > 0
    EOF
      for        = "PT15M"
      severity   = 3
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      annotations = {
        description = "{{ $labels.namespace }}/{{ $labels.pod }} in {{ $labels.cluster }} by controller is not ready. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."
      }
      labels = {
        alert_name = "KubePodNotReadyByController"
      }
    },
    {
      alert      = "KubeStatefulSetGenerationMismatch"
      enabled    = true
      expression = <<EOF
    kube_statefulset_status_observed_generation{job="kube-state-metrics"} !=
    kube_statefulset_metadata_generation{job="kube-state-metrics"}
    EOF
      for        = "PT15M"
      severity   = 3
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      annotations = {
        description = "StatefulSet generation for {{ $labels.namespace }}/{{ $labels.statefulset }} does not match, this indicates that the StatefulSet has failed but has not been rolled back. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."
      }
      labels = {
        alert_name = "KubeStatefulSetGenerationMismatch"
      }
    },
    {
      alert      = "KubeJobFailed"
      enabled    = true
      expression = <<EOF
    kube_job_failed{job="kube-state-metrics"} > 0
    EOF
      for        = "PT15M"
      severity   = 3
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      annotations = {
        description = "Job {{ $labels.namespace }}/{{ $labels.job_name }} in {{ $labels.cluster}} failed to complete. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."
      }
      labels = {
        alert_name = "KubeJobFailed"
      }
    },
    {
      alert      = "KubeContainerAverageCPUHigh"
      enabled    = true
      expression = <<EOF
sum (rate(container_cpu_usage_seconds_total{image!="", container!="POD"}[5m])) by (pod,cluster,container,namespace)
/ sum(container_spec_cpu_quota{image!="", container!="POD"}/container_spec_cpu_period{image!="", container!="POD"})
by (pod,cluster,container,namespace) > .95
    EOF
      for        = "PT5M"
      severity   = 4
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT15M"
      }
      annotations = {
        description = "Average CPU usage per container is greater than 95%. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."
      }
      labels = {
        alert_name = "KubeContainerAverageCPUHigh"
      }
    },
    {
      alert      = "KubeContainerAverageMemoryHigh"
      enabled    = true
      expression = <<EOF
avg by (namespace, controller, container, cluster)(((container_memory_working_set_bytes{container!="", image!="", container!="POD"}
/ on(namespace,cluster,pod,container) group_left kube_pod_container_resource_limits{resource="memory", node!=""})
*on(namespace, pod, cluster) group_left(controller) label_replace(kube_pod_owner, "controller", "$1", "owner_name", "(.*)")) > .95)
    EOF
      for        = "PT10M"
      severity   = 4
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      annotations = {
        description = "Average Memory usage per container is greater than 95%. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."
      }
      labels = {
        alert_name = "KubeContainerAverageMemoryHigh"
      }
    },
    {
      alert      = "KubeletPodStartUpLatencyHigh"
      enabled    = true
      expression = <<EOF
    histogram_quantile(0.99,
    sum(rate(kubelet_pod_worker_duration_seconds_bucket{job="kubelet"}[5m]))
    by (cluster, instance, le)) * on(cluster, instance) group_left(node)
    kubelet_node_name{job="kubelet"} > 60
    EOF
      for        = "PT10M"
      severity   = 4
      alert_resolution = {
        auto_resolved   = true
        time_to_resolve = "PT10M"
      }
      annotations = {
        description = "Kubelet Pod startup latency is too high. For more information on this alert, please refer to this [link](https://aka.ms/aks-alerts/pod-level-recommended-alerts)."
      }
      labels = {
        alert_name = "KubeletPodStartUpLatencyHigh"
      }
    }
  ]
}
