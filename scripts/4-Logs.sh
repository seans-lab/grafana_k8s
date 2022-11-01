#Logs: Deploy Agent ConfigMap & DaemonSet
cat <<'EOF' | NAMESPACE=default /bin/sh -c 'kubectl apply -n $NAMESPACE -f -'

kind: ConfigMap
metadata:
  name: grafana-agent-logs
apiVersion: v1
data:
  agent.yaml: |    
    metrics:
      wal_directory: /tmp/grafana-agent-wal
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
    integrations:
      prometheus_remote_write:
      - url: https://prometheus-prod-09-prod-au-southeast-0.grafana.net/api/prom/push
        basic_auth:
          username: 498476
          password: eyJrIjoiYjY5NDYwNDY5MTY1M2Y4NmRhMTE4ODI2ODEzODZhOTQyOWIzY2I3NSIsIm4iOiJzdGFjay0zOTg5MDUtZWFzeXN0YXJ0LXByb20tcHVibGlzaGVyIiwiaWQiOjYzNzE4OX0=
      
      
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
        positions:
          filename: /tmp/positions.yaml
        target_config:
          sync_period: 10s
        scrape_configs:
        - job_name: integrations/node_exporter_direct_scrape
          static_configs:
          - targets:
            - localhost
            labels:
              instance: $(hostname)
              __path__: /var/log/*.log
              job: integrations/macos-node
          pipeline_stages:
          - multiline:
              firstline: '^([\w]{3} )?[\w]{3} +[\d]+ [\d]+:[\d]+:[\d]+|[\w]{4}-[\w]{2}-[\w]{2} [\w]{2}:[\w]{2}:[\w]{2}(?:[+-][\w]{2})?'
          - regex:
              expression: '(?P<timestamp>([\w]{3} )?[\w]{3} +[\d]+ [\d]+:[\d]+:[\d]+|[\w]{4}-[\w]{2}-[\w]{2} [\w]{2}:[\w]{2}:[\w]{2}(?:[+-][\w]{2})?) (?P<hostname>\S+) (?P<sender>.+?)\[(?P<pid>\d+)\]:? (?P<message>(?s:.*))$'
          - labels:
              sender:
              hostname:
              pid:
          - match:
              selector: '{sender!="", pid!=""}'
              stages:
                - template:
                    source: message
                    template: '{{.sender }}[{{.pid}}]: {{ .message }}'
                - labeldrop:
                    - pid
                - output:
                    source: message
        - job_name: integrations/node_exporter_journal_scrape
          journal:
            max_age: 24h
            labels:
              instance: hostname
              job: integrations/node_exporter
          relabel_configs:
          - source_labels: ['__journal__systemd_unit']
            target_label: 'unit'
          - source_labels: ['__journal__boot_id']
            target_label: 'boot_id'
          - source_labels: ['__journal__transport']
            target_label: 'transport'
          - source_labels: ['__journal_priority_keyword']
            target_label: 'level'
        - job_name: integrations/kubernetes/pod-logs
          kubernetes_sd_configs:
            - role: pod
          pipeline_stages:
            - docker: {}
          relabel_configs:
            - source_labels:
                - __meta_kubernetes_pod_node_name
              target_label: __host__
            - action: labelmap
              regex: __meta_kubernetes_pod_label_(.+)
            - action: replace
              replacement: $1
              separator: /
              source_labels:
                - __meta_kubernetes_namespace
                - __meta_kubernetes_pod_name
              target_label: job
            - action: replace
              source_labels:
                - __meta_kubernetes_namespace
              target_label: namespace
            - action: replace
              source_labels:
                - __meta_kubernetes_pod_name
              target_label: pod
            - action: replace
              source_labels:
                - __meta_kubernetes_pod_container_name
              target_label: container
            - replacement: /var/log/pods/*$1/*.log
              separator: /
              source_labels:
                - __meta_kubernetes_pod_uid
                - __meta_kubernetes_pod_container_name
              target_label: __path__
        - job_name: integrations/nginx
          static_configs:
          - targets:
            - localhost
            labels:
              host: <http_hostname>
              __path__: <path to json nginx access log>
        - job_name: integrations/agent
          journal:
            max_age: 24h
            labels:
              instance: <hostname>
              job: integrations/agent
          pipeline_stages:
            - match:
                selector: '{unit!="grafana-agent.service"}'
                action: drop
                drop_counter_reason: only_keep_grafana_agent_logs
            - regex:
                expression: "(level=(?P<log_level>[\\s]*debug|warn|info|error))"
            - labels:
                level: log_level
          relabel_configs:
            - source_labels: ['__journal__systemd_unit']
              target_label: 'unit'
        - job_name: integrations/agent
          windows_events:
            use_incoming_timestamp: true
            bookmark_path: "./bookmark-application.xml"
            eventlog_name: "Application"
            xpath_query: "*[System[Provider[@Name='Grafana Agent']]]"
            labels:
              job: integrations/agent
          relabel_configs:
            - source_labels: ['computer']
              target_label: 'instance'
            - replacement: grafana-agent.service
              target_label: unit
          pipeline_stages:
          - json:
              expressions:
                message: message
          - regex:
              expression: "(level=(?P<log_level>[\\s]*debug|warn|info|error))"
          - labels:
              level: log_level
          - output:
              source: message
        
    
EOF