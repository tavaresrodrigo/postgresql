#!/bin/bash
# A sample script to install prometheus using helm
helm install prometheus stable/prometheus --namespace prometheus --set alertmanager.persistentVolume.storageClass="gp7" --set server.persistentVolume.storageClass="gp2"
