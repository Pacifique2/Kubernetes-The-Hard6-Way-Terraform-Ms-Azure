
###############################
# setting up the user from the remote device
# Create the two namespaces for two different remote kubernetes users
#################################################



##############################################o "Setting the kubectl remote user"
resource "null_resource" "kubectl_external_users_setup" {
  depends_on  = ["null_resource.pod_dns_add_on_deployment"]
  provisioner "local-exec" {
    command=<<EOT
      echo "Setting up both devoteam-pacy and tsp-pacy external users with respect to their kubernetes namespaces"
      kubectl create namespace devoteam-apps
      kubectl create namespace telecom-sud-paris-apps
      kubectl config set-credentials devoteam-pacy --client-certificate=tls-certs/client-server/devoteam-pacy.pem --client-key=tls-certs/client-server/devoteam-pacy-key.pem
      kubectl config set-context devo-context --cluster=kubernetes-the-hard-way --namespace=devoteam-apps --user=devoteam-pacy
      kubectl config set-credentials tsp-pacy --client-certificate=tls-certs/client-server/tsp-pacy.pem  --client-key=tls-certs/client-server/tsp-pacy-key.pem
      kubectl config set-context tsp-context --cluster=kubernetes-the-hard-way --namespace=telecom-sud-paris-apps --user=tsp-pacy
      echo "done configuring the both users"
    EOT
  }

}


################################################################################                                                                                             # Create both the roles and roleBindings to grant them limited access with respect to the created namespaces,          
################################################################################          
                                      
                                                                                                 
resource "null_resource" "granting_permissions_to_external_users" {                                           
  depends_on  = ["null_resource.kubectl_external_users_setup"]                                          
  connection {                                                                                   
    type         = "ssh"                                                                         
    host = "${element(var.controller_dns_names,0)}"                                    
    user         = "${var.api_server_username}"                                                  
    password     = "${var.api_server_password}"                                                  
    private_key  = "${file("~/.ssh/kube-devolab_id_rsa")}"                                       
    timeout      =  "1m"                                                                         
    agent        = true                                                                          
  }                                                                                              
  provisioner "remote-exec" {                                                                    
    inline = [                                                                                   
      "echo 'granting permissions to users within the devoteam-apps namespace'",  
      "echo 'granting permissions to users within the telecom-sud-paris-apps namespace'"                                      
    ]                                                                                            
  }                      
  provisioner "remote-exec" {
    script = "${path.module}/scripts/users-rolesRoleBings.sh"
  }                                                                        
}                                                                                                
