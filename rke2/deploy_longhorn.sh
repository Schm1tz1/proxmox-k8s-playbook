#!/usr/bin/env bash

helm repo add longhorn https://charts.longhorn.io
helm repo update

helm upgrade -i longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --create-namespace
