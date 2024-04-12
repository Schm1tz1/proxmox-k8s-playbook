#!/usr/bin/env bash

helm upgrade --install rancher rancher-latest/rancher \
 --namespace cattle-system \
 --set hostname=rancher.k8s.internal.schmitzi.net \
 --set ingress.tls.source=secret \
 --set bootstrapPassword=admin \
 --create-namespace
