#!/bin/bash
# A sample script to install prometheys using helm
helm install prometheus stable/prometheus --namespace prometheus --set alertmanager.persistentVolume.storageClass="gp2"  --set server.persistentVolume.storageClass="gp2"
