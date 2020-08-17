#!/bin/bash
# A sample script to install grafana using helm
helm install grafana stable/grafana     --namespace grafana     --set persistence.storageClassName="gp2"     --set persistence.enabled=true     --set adminPassword='EKS!sAWSome'     --values grafana.yaml     --set service.type=LoadBalancer
