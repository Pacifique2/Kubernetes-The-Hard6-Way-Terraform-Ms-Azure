#!/usr/bin

set -e
echo "kubernetes pip ip"
az vm list -d -g RG-Kube-Free -o table
KUBERNETES_PUBLIC_ADDRESS=$(az network public-ip show -g RG-Kube-Free -n RG-Kube-Free-terraform-kubernetes-pip --query ipAddress -otsv)
