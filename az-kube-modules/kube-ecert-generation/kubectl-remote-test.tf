

#Verification 
#Check the health of the remote Kubernetes cluster:


resource "null_resource" "kubectl_testingg" {
  depends_on  = ["null_resource.start_worker_services","null_resource.kubectl_remote_setupp"] 
  
 provisioner "local-exec" {
   command=<<EOT
     echo "testing the remote user with kubectl"
     kubectl get componentstatuses
     # List the nodes in the remote Kubernetes cluster:

     kubectl get nodes 
     echo "done testing with kubectl"
   EOT
 }
}
