

# echo "Setting the kubectl remote user"
resource "null_resource" "kubectl_remote_setupp" { 
  depends_on  = ["null_resource.kube_api_server_version_testt","null_resource.start_worker_services"]
  # "null_resource.kube_worker_nodes_verification"
  provisioner "local-exec" {
    command=<<EOT
      echo "setting up the kubectl remote client"
      KUBERNETES_PUBLIC_ADDRESS=$(az network public-ip show -g RG-Kube-Free -n RG-Kube-Free-terraform-kubernetes-pip --query ipAddress -otsv)
      kubectl config set-cluster kubernetes-the-hard-way --certificate-authority=tls-certs/client-server/ca.pem --embed-certs=true --server=https://$${KUBERNETES_PUBLIC_ADDRESS}:6443
      kubectl config set-credentials admin --client-certificate=tls-certs/client-server/admin.pem --client-key=tls-certs/client-server/admin-key.pem
      kubectl config set-context kubernetes-the-hard-way --cluster=kubernetes-the-hard-way --user=admin
      kubectl config use-context kubernetes-the-hard-way
      echo "done configuring the kubernetes remote user"
    EOT
  }
  
}


################################################################################
