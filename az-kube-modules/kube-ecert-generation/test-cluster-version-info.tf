                                                             
# Verify the Kubernetes API Server by an HTTP request                        


resource "null_resource" "kube_api_server_version_testt" {  
  depends_on = ["null_resource.cluster_role_bindingg","azurerm_lb_rule.lb"]
  #KUBERNETES_PUBLIC_IP_ADDRESS = "${var.kube_public_ip}"                      
     
  provisioner "local-exec" {
    command =<<EOT
      echo "verify the cluster version info .................."
                  
      curl --cacert tls-certs/client-server/ca.pem https://$KUBERNETES_PUBLIC_IP_ADDRESS:6443/version
      echo "Okk!!! finished testing the api server health check"
      echo done
    EOT
    environment = {
      KUBERNETES_PUBLIC_IP_ADDRESS = "${var.kubernetes_public_ip_address}"
    }
                   
 
  }
  /*
  provisioner "local-exec" {
    command = "curl --cacert ~/myAzureProject/terraform/azure-k8s-terra-cluster/tls-certs/client-server/ca.pem https://${var.kubernetes_public_ip_address}:6443/version"
  }
    
  */                                                        
}                                                            
  
                                                         
