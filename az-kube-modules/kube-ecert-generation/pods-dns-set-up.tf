
resource "null_resource" "list_pods_cidr_routes" {
  depends_on  = ["null_resource.kubectl_testingg"]
  
  provisioner "local-exec" {
    command = "az network route-table route list -g ${var.rsg_name} --route-table-name kubernetes-routes -o table"
  }
  /*
  provisioner "local-exec" {
    command =<<EOT
      echo Routes
      echo "network routes created for worker instance:"
      # az network vnet subnet update -g ${var.rsg_name} -n ${var.vnet_subnet_name} --vnet-name  ${var.vnet_name} --route-table kubernetes-routes
      az network route-table route list -g ${var.rsg_name} --route-table-name kubernetes-routes -o table
      echo "done creating the pods routing table"
      EOT 
  }*/
}

################################################
# Deploying the DNS Cluster Add-on
# In this lab we will deploy the DNS add-on which provides DNS based service discovery, 
# backed by CoreDNS, to applications running inside the Kubernetes cluster.
########################################

resource "null_resource" "pod_dns_add_on_deployment" {
  depends_on  = ["null_resource.list_pods_cidr_routes"]
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
      "kubectl apply -f 'https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml'",
      "kubectl get pods -l k8s-app=kube-dns -n kube-system" 
    ]
  }
}

