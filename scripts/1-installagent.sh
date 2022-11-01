cat <<'EOF' | NAMESPACE=default /bin/sh -c 'kubectl apply -n $NAMESPACE -f -'

kind: ConfigMap
metadata:
  name: grafana-agent
apiVersion: v1
data:
  agent.yaml: |    
    metrics:
      wal_directory: /var/lib/agent/wal
      global:
        scrape_interval: 60s
        external_labels:
          cluster: cloud
      configs:
      - name: integrations
        remote_write:
        - url: https://prometheus-prod-09-prod-au-southeast-0.grafana.net/api/prom/push
          basic_auth:
            username: 498476
            password: eyJrIjoiYjY5NDYwNDY5MTY1M2Y4NmRhMTE4ODI2ODEzODZhOTQyOWIzY2I3NSIsIm4iOiJzdGFjay0zOTg5MDUtZWFzeXN0YXJ0LXByb20tcHVibGlzaGVyIiwiaWQiOjYzNzE4OX0=
        scrape_configs:
        - bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
          job_name: integrations/kubernetes/cadvisor
          kubernetes_sd_configs:
              - role: node
          metric_relabel_configs:
              - source_labels: [__name__]
                regex: namespace_workload_pod:kube_pod_owner:relabel|container_memory_working_set_bytes|cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits|kube_pod_owner|kubelet_runtime_operations_errors_total|kube_deployment_spec_replicas|kube_statefulset_metadata_generation|namespace_memory:kube_pod_container_resource_limits:sum|kubelet_pod_start_duration_seconds_bucket|kube_daemonset_status_updated_number_scheduled|kube_statefulset_status_observed_generation|kube_daemonset_status_current_number_scheduled|kubelet_certificate_manager_server_ttl_seconds|container_network_receive_packets_total|kube_resourcequota|kubelet_volume_stats_inodes_used|kubelet_volume_stats_inodes|kubelet_server_expiration_renew_errors|kube_horizontalpodautoscaler_spec_min_replicas|kube_statefulset_status_replicas_ready|container_network_transmit_packets_dropped_total|container_fs_reads_total|kubelet_running_pod_count|node_namespace_pod_container:container_memory_swap|kube_deployment_metadata_generation|kubelet_cgroup_manager_duration_seconds_bucket|cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests|kubelet_certificate_manager_client_ttl_seconds|process_cpu_seconds_total|kubelet_pod_worker_duration_seconds_bucket|kubelet_pod_start_duration_seconds_count|kube_node_status_capacity|kubelet_running_containers|namespace_memory:kube_pod_container_resource_requests:sum|kubelet_pod_worker_duration_seconds_count|volume_manager_total_volumes|kubelet_running_container_count|node_namespace_pod_container:container_memory_rss|go_goroutines|kube_namespace_status_phase|kube_node_info|container_cpu_usage_seconds_total|namespace_cpu:kube_pod_container_resource_requests:sum|storage_operation_errors_total|kubelet_cgroup_manager_duration_seconds_count|node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile|kube_statefulset_replicas|kubelet_volume_stats_available_bytes|kube_statefulset_status_current_revision|kube_horizontalpodautoscaler_spec_max_replicas|kubelet_certificate_manager_client_expiration_renew_errors|kubelet_running_pods|kubelet_runtime_operations_total|kube_job_status_active|node_namespace_pod_container:container_memory_cache|kube_horizontalpodautoscaler_status_desired_replicas|kube_statefulset_status_update_revision|container_memory_rss|container_network_receive_bytes_total|kube_node_status_allocatable|kubelet_node_name|node_namespace_pod_container:container_memory_working_set_bytes|kube_deployment_status_observed_generation|rest_client_requests_total|storage_operation_duration_seconds_count|container_memory_swap|kubernetes_build_info|kubelet_pleg_relist_duration_seconds_count|kubelet_node_config_error|kube_replicaset_owner|namespace_cpu:kube_pod_container_resource_limits:sum|container_memory_cache|kube_job_status_start_time|kube_deployment_status_replicas_updated|kube_node_status_condition|node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate|namespace_workload_pod|container_cpu_cfs_throttled_periods_total|kube_daemonset_status_number_available|process_resident_memory_bytes|kube_deployment_status_replicas_available|kube_pod_container_status_waiting_reason|container_network_transmit_packets_total|kube_pod_container_resource_limits|kube_statefulset_status_replicas_updated|kube_pod_container_resource_requests|cluster:namespace:pod_memory:active:kube_pod_container_resource_requests|kube_pod_status_phase|container_network_receive_packets_dropped_total|kube_statefulset_status_replicas|kube_job_failed|kube_daemonset_status_number_misscheduled|container_fs_reads_bytes_total|kubelet_volume_stats_capacity_bytes|kube_node_spec_taint|machine_memory_bytes|kubelet_pleg_relist_duration_seconds_bucket|cluster:namespace:pod_memory:active:kube_pod_container_resource_limits|kube_horizontalpodautoscaler_status_current_replicas|container_network_transmit_bytes_total|kubelet_pleg_relist_interval_seconds_bucket|container_cpu_cfs_periods_total|container_fs_writes_bytes_total|container_fs_writes_total|kube_pod_info|kube_daemonset_status_desired_number_scheduled|kube_namespace_status_phase|container_cpu_usage_seconds_total|kube_pod_status_phase|kube_pod_start_time|kube_pod_container_status_restarts_total|kube_pod_container_info|kube_pod_container_status_waiting_reason|kube_daemonset.*|kube_replicaset.*|kube_statefulset.*|kube_job.*|kube_node_status_capacity|node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate|cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests|namespace_cpu:kube_pod_container_resource_requests:sum
                action: keep
          relabel_configs:
              - replacement: kubernetes.default.svc.cluster.local:443
                target_label: __address__
              - regex: (.+)
                replacement: /api/v1/nodes/${1}/proxy/metrics/cadvisor
                source_labels:
                  - __meta_kubernetes_node_name
                target_label: __metrics_path__
          scheme: https
          tls_config:
              ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
              insecure_skip_verify: false
              server_name: kubernetes
        - bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
          job_name: integrations/kubernetes/kubelet
          kubernetes_sd_configs:
              - role: node
          metric_relabel_configs:
              - source_labels: [__name__]
                regex: namespace_workload_pod:kube_pod_owner:relabel|container_memory_working_set_bytes|cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits|kube_pod_owner|kubelet_runtime_operations_errors_total|kube_deployment_spec_replicas|kube_statefulset_metadata_generation|namespace_memory:kube_pod_container_resource_limits:sum|kubelet_pod_start_duration_seconds_bucket|kube_daemonset_status_updated_number_scheduled|kube_statefulset_status_observed_generation|kube_daemonset_status_current_number_scheduled|kubelet_certificate_manager_server_ttl_seconds|container_network_receive_packets_total|kube_resourcequota|kubelet_volume_stats_inodes_used|kubelet_volume_stats_inodes|kubelet_server_expiration_renew_errors|kube_horizontalpodautoscaler_spec_min_replicas|kube_statefulset_status_replicas_ready|container_network_transmit_packets_dropped_total|container_fs_reads_total|kubelet_running_pod_count|node_namespace_pod_container:container_memory_swap|kube_deployment_metadata_generation|kubelet_cgroup_manager_duration_seconds_bucket|cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests|kubelet_certificate_manager_client_ttl_seconds|process_cpu_seconds_total|kubelet_pod_worker_duration_seconds_bucket|kubelet_pod_start_duration_seconds_count|kube_node_status_capacity|kubelet_running_containers|namespace_memory:kube_pod_container_resource_requests:sum|kubelet_pod_worker_duration_seconds_count|volume_manager_total_volumes|kubelet_running_container_count|node_namespace_pod_container:container_memory_rss|go_goroutines|kube_namespace_status_phase|kube_node_info|container_cpu_usage_seconds_total|namespace_cpu:kube_pod_container_resource_requests:sum|storage_operation_errors_total|kubelet_cgroup_manager_duration_seconds_count|node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile|kube_statefulset_replicas|kubelet_volume_stats_available_bytes|kube_statefulset_status_current_revision|kube_horizontalpodautoscaler_spec_max_replicas|kubelet_certificate_manager_client_expiration_renew_errors|kubelet_running_pods|kubelet_runtime_operations_total|kube_job_status_active|node_namespace_pod_container:container_memory_cache|kube_horizontalpodautoscaler_status_desired_replicas|kube_statefulset_status_update_revision|container_memory_rss|container_network_receive_bytes_total|kube_node_status_allocatable|kubelet_node_name|node_namespace_pod_container:container_memory_working_set_bytes|kube_deployment_status_observed_generation|rest_client_requests_total|storage_operation_duration_seconds_count|container_memory_swap|kubernetes_build_info|kubelet_pleg_relist_duration_seconds_count|kubelet_node_config_error|kube_replicaset_owner|namespace_cpu:kube_pod_container_resource_limits:sum|container_memory_cache|kube_job_status_start_time|kube_deployment_status_replicas_updated|kube_node_status_condition|node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate|namespace_workload_pod|container_cpu_cfs_throttled_periods_total|kube_daemonset_status_number_available|process_resident_memory_bytes|kube_deployment_status_replicas_available|kube_pod_container_status_waiting_reason|container_network_transmit_packets_total|kube_pod_container_resource_limits|kube_statefulset_status_replicas_updated|kube_pod_container_resource_requests|cluster:namespace:pod_memory:active:kube_pod_container_resource_requests|kube_pod_status_phase|container_network_receive_packets_dropped_total|kube_statefulset_status_replicas|kube_job_failed|kube_daemonset_status_number_misscheduled|container_fs_reads_bytes_total|kubelet_volume_stats_capacity_bytes|kube_node_spec_taint|machine_memory_bytes|kubelet_pleg_relist_duration_seconds_bucket|cluster:namespace:pod_memory:active:kube_pod_container_resource_limits|kube_horizontalpodautoscaler_status_current_replicas|container_network_transmit_bytes_total|kubelet_pleg_relist_interval_seconds_bucket|container_cpu_cfs_periods_total|container_fs_writes_bytes_total|container_fs_writes_total|kube_pod_info|kube_daemonset_status_desired_number_scheduled|kube_namespace_status_phase|container_cpu_usage_seconds_total|kube_pod_status_phase|kube_pod_start_time|kube_pod_container_status_restarts_total|kube_pod_container_info|kube_pod_container_status_waiting_reason|kube_daemonset.*|kube_replicaset.*|kube_statefulset.*|kube_job.*|kube_node_status_capacity|node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate|cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests|namespace_cpu:kube_pod_container_resource_requests:sum
                action: keep
          relabel_configs:
              - replacement: kubernetes.default.svc.cluster.local:443
                target_label: __address__
              - regex: (.+)
                replacement: /api/v1/nodes/${1}/proxy/metrics
                source_labels:
                  - __meta_kubernetes_node_name
                target_label: __metrics_path__
          scheme: https
          tls_config:
              ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
              insecure_skip_verify: false
              server_name: kubernetes
        - job_name: integrations/kubernetes/kube-state-metrics
          kubernetes_sd_configs:
              - role: pod
          metric_relabel_configs:
              - source_labels: [__name__]
                regex: namespace_workload_pod:kube_pod_owner:relabel|container_memory_working_set_bytes|cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits|kube_pod_owner|kubelet_runtime_operations_errors_total|kube_deployment_spec_replicas|kube_statefulset_metadata_generation|namespace_memory:kube_pod_container_resource_limits:sum|kubelet_pod_start_duration_seconds_bucket|kube_daemonset_status_updated_number_scheduled|kube_statefulset_status_observed_generation|kube_daemonset_status_current_number_scheduled|kubelet_certificate_manager_server_ttl_seconds|container_network_receive_packets_total|kube_resourcequota|kubelet_volume_stats_inodes_used|kubelet_volume_stats_inodes|kubelet_server_expiration_renew_errors|kube_horizontalpodautoscaler_spec_min_replicas|kube_statefulset_status_replicas_ready|container_network_transmit_packets_dropped_total|container_fs_reads_total|kubelet_running_pod_count|node_namespace_pod_container:container_memory_swap|kube_deployment_metadata_generation|kubelet_cgroup_manager_duration_seconds_bucket|cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests|kubelet_certificate_manager_client_ttl_seconds|process_cpu_seconds_total|kubelet_pod_worker_duration_seconds_bucket|kubelet_pod_start_duration_seconds_count|kube_node_status_capacity|kubelet_running_containers|namespace_memory:kube_pod_container_resource_requests:sum|kubelet_pod_worker_duration_seconds_count|volume_manager_total_volumes|kubelet_running_container_count|node_namespace_pod_container:container_memory_rss|go_goroutines|kube_namespace_status_phase|kube_node_info|container_cpu_usage_seconds_total|namespace_cpu:kube_pod_container_resource_requests:sum|storage_operation_errors_total|kubelet_cgroup_manager_duration_seconds_count|node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile|kube_statefulset_replicas|kubelet_volume_stats_available_bytes|kube_statefulset_status_current_revision|kube_horizontalpodautoscaler_spec_max_replicas|kubelet_certificate_manager_client_expiration_renew_errors|kubelet_running_pods|kubelet_runtime_operations_total|kube_job_status_active|node_namespace_pod_container:container_memory_cache|kube_horizontalpodautoscaler_status_desired_replicas|kube_statefulset_status_update_revision|container_memory_rss|container_network_receive_bytes_total|kube_node_status_allocatable|kubelet_node_name|node_namespace_pod_container:container_memory_working_set_bytes|kube_deployment_status_observed_generation|rest_client_requests_total|storage_operation_duration_seconds_count|container_memory_swap|kubernetes_build_info|kubelet_pleg_relist_duration_seconds_count|kubelet_node_config_error|kube_replicaset_owner|namespace_cpu:kube_pod_container_resource_limits:sum|container_memory_cache|kube_job_status_start_time|kube_deployment_status_replicas_updated|kube_node_status_condition|node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate|namespace_workload_pod|container_cpu_cfs_throttled_periods_total|kube_daemonset_status_number_available|process_resident_memory_bytes|kube_deployment_status_replicas_available|kube_pod_container_status_waiting_reason|container_network_transmit_packets_total|kube_pod_container_resource_limits|kube_statefulset_status_replicas_updated|kube_pod_container_resource_requests|cluster:namespace:pod_memory:active:kube_pod_container_resource_requests|kube_pod_status_phase|container_network_receive_packets_dropped_total|kube_statefulset_status_replicas|kube_job_failed|kube_daemonset_status_number_misscheduled|container_fs_reads_bytes_total|kubelet_volume_stats_capacity_bytes|kube_node_spec_taint|machine_memory_bytes|kubelet_pleg_relist_duration_seconds_bucket|cluster:namespace:pod_memory:active:kube_pod_container_resource_limits|kube_horizontalpodautoscaler_status_current_replicas|container_network_transmit_bytes_total|kubelet_pleg_relist_interval_seconds_bucket|container_cpu_cfs_periods_total|container_fs_writes_bytes_total|container_fs_writes_total|kube_pod_info|kube_daemonset_status_desired_number_scheduled|kube_namespace_status_phase|container_cpu_usage_seconds_total|kube_pod_status_phase|kube_pod_start_time|kube_pod_container_status_restarts_total|kube_pod_container_info|kube_pod_container_status_waiting_reason|kube_daemonset.*|kube_replicaset.*|kube_statefulset.*|kube_job.*|kube_node_status_capacity|node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate|cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests|namespace_cpu:kube_pod_container_resource_requests:sum
                action: keep
          relabel_configs:
              - action: keep
                regex: kube-state-metrics
                source_labels:
                  - __meta_kubernetes_pod_label_app_kubernetes_io_name
        
    integrations:
      eventhandler:
        cache_path: /var/lib/agent/eventhandler.cache
        logs_instance: integrations
    logs:
      configs:
      - name: integrations
        clients:
        - url: https://logs-prod-004.grafana.net/loki/api/v1/push
          basic_auth:
            username: 248208
            password: eyJrIjoiYjY5NDYwNDY5MTY1M2Y4NmRhMTE4ODI2ODEzODZhOTQyOWIzY2I3NSIsIm4iOiJzdGFjay0zOTg5MDUtZWFzeXN0YXJ0LXByb20tcHVibGlzaGVyIiwiaWQiOjYzNzE4OX0=
          external_labels:
            cluster: cloud
            job: integrations/kubernetes/eventhandler
        positions:
          filename: /tmp/positions.yaml
        target_config:
          sync_period: 10s
    
EOF
