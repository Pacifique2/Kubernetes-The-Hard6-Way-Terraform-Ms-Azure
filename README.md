# Terraformized-Kube-The-Hard-Way

This project highlights the basic steps to set up Kubernetes the hard way with terraform asan automation tool. This takes us through a complete automated implementation  to bring up a Kubernetes cluster. To do so, we use terraform to provision and deploy the whole kubernetes ecosystem.

Kubernetes The Hard Way is optimized for learning, which means taking the long route to ensure you understand each task required to bootstrap a Kubernetes cluster.

Kubernetes The Hard Way guides you through bootstrapping a highly available Kubernetes cluster with end-to-end encryption between components and RBAC authentication.

In this project, we end up adding a special use case where we use the RBAC kubernetes autorization mode to grant and limit user permissions with respect to their respective namespaces. We used  terraform to implement kubernetes the hard way.

# Cluster Details

Kubernetes The Hard Way guides you through bootstrapping a highly available Kubernetes cluster with end-to-end encryption between components and RBAC authentication.

 ## Kubernetes 1.12.0  
 ### https://github.com/kubernetes/kubernetes

## containerd Container Runtime 1.2.0-rc.0
## gVisor 50c283b9f56bb7200938d9e207355f05f79f0d17
## CNI Container Networking 0.6.0
## etcd v3.3.9
## CoreDNS v1.2.2

# Steps to bring up the kubernetes cluster

We would like to note that our kubernetes implementation is tructured into modules that are all found into the **az-modules directory**.
Other modules other than the mentioned one, are for test purposes.
The man terraform file of this project is named **az-provider.tf**.

## Prerequisites
Despite the need to install PKI install from the original implementation of kuberntes the hard way, we wouldn't need to do so since we use terraform tls modules to automatically generate tls certifications.

We won't need to install the PKI tools such cfssl cfssljon as mentioned in the original kubernetes the hard way project.
We don't need to install go either

## Provisioning Compute Resources
### az-modules/kube-avnet
 This module creates the overall resource group with supporting infrastructure, such as VNET, Subnet
*https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/tree/master/az-kube-modules/kube-avnet*
### az-modules/kube-bpip-lb
This module created the kubernetes public ip and the load balancer within MS azure cloud platform.
 *https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/tree/master/az-kube-modules/kube-bpip-lb*
 
 ### az-modules/kube-lb-rules
This module created the kubernetes the load balancer rules within MS azure cloud platform.
 *https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/tree/master/az-kube-modules/kube-lb-rules*
 
 ### az-modules/kube-cnodes
This module created a set of linux virtual machines that would be used while boostrapping the kubernetes control plane within MS azure cloud platform.
 *https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/tree/master/az-kube-modules/kube-cnodes*
 
 ### az-modules/kube-cnodes
This module created a set of linux virtual machines that would be used as kubernetes worker nodes.
 *https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/tree/master/az-kube-modules/kube-dworker-nodes*
 
 
 
## Provisioning the CA and Generating TLS Certificates
## Generating Kubernetes Configuration Files for Authentication
## Generating the Data Encryption Config and Key
## Bootstrapping the etcd Cluster
## Bootstrapping the Kubernetes Control Plane
## Bootstrapping the Kubernetes Worker Nodes
## Configuring kubectl for Remote Access
## Provisioning Pod Network Routes
## Deploying the DNS Cluster Add-on
## Adding two namespaces for two external users to use the set up kubernetes cluster
  Here we add two users, one from a company called **Devoteam France and an other from an engineering school known as Telecom SudParis.**
we use the kubernetes RBAC roles and rolesbindings to grant different permissions to these two users with respect to their namespaces.



# Installation
The following steps are required to setup and run this project:

Clone the repo  **https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure.git**
## SSH
Generate an SSH key which can be used to SSH to the Kubernetes vms instances which will be created within MS Azure public cloud. The generated public/private key pair should be generated in a folder matching the path found in the ssh_key_data variable for path to public key and make sure that both the public key and private key can be located from the .ssh directory. This will ensure that the Terraform **vm** files can read them correctly. Ensure that the ssh agent is running from your local machine that you used to clone the repo.

Ensure that the AZURE credentials profile that you wish to use to run this project is specified correctly in your Azure CLI authentication to Azure portal . Ensure that your subscription id is configured  int azure prvider file before testing. 

## Install Terraform 
## Install kubectl
From the project root directory, run :
## run terraform init
 This will ensure that all the necessary environment plugins are downloaded for terraform to run the implementation
## Run terraform plan
## Then run terraform apply 
By typing yes, terraform sets up the whole functionning  kubernetes cluster.
## Testing Two external users and Understanding RBAC
Now, the cluster has generated a kubernetes config file in your local machine.
Type kubectl config view;
You will find three configured remote users that have beeen granted different permissions to interact with our new kubernetes cluster hosted on MS Azure.
 

