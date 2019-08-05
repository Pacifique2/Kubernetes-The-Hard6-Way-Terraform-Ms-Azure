# Terraformized-Kube-The-Hard-Way

This project highlights the basic steps to set up Kubernetes the hard way with terraform automation tool. This takes us through a complete automated implementation  to bring up a Kubernetes cluster. To do so, we use terraform hashicorp to provision and deploy the whole kubernetes ecosystem.

Kubernetes The Hard Way is optimized for learning, which means taking the long route to ensure a deep understanding of each required  task to bootstrap a Kubernetes cluster.

Kubernetes The Hard Way guides you through bootstrapping a highly available Kubernetes cluster with end-to-end encryption between components and RBAC authentication.

In this project, we end up adding a special use case where we use the RBAC kubernetes autorization mode to grant and limit user permissions with respect to their respective namespaces. We used  terraform to implement kubernetes the hard way.

# Cluster Details

Kubernetes The Hard Way guides you through bootstrapping a highly available Kubernetes cluster with end-to-end encryption between components and RBAC authorization.

 ## Kubernetes 1.13.0  
 ### https://github.com/kubernetes/kubernetes

## containerd Container Runtime 1.2.0-rc.0
## gVisor 50c283b9f56bb7200938d9e207355f05f79f0d17
## CNI Container Networking 0.6.0
## etcd v3.3.9
## CoreDNS from docker image: coredns/coredns:1.2.2


# Steps to bring up the kubernetes cluster

We would like to note that our kubernetes implementation is tructured into modules that are all found into the **az-kube-modules directory**.
Other modules other than the mentioned one, are for test purposes.
The main terraform file of this project is named **az-provider.tf**.

## Prerequisites
**********
**********
Despite the need to install necessary tools to provision a **PKI (Public Key Infrastructure)** as done from the original implementation of kubernetes the hard way, we wouldn't need to do so since we use terraform TLS modules to automatically create and manage TLS certificates that will be used to authenticate kubernetes components to the kube-apiserver.

We won't need to install the **PKI*** tools such cfssl cfssljson as mentioned in the original Kubernetes The Hard way project. We don't need to install go either. However, we would need to install the kubectl command line utility that is used to interact with the Kubernetes API Server. More about downloading and installing instructions for the remote Kubernetes API, kubectl, can be found in official Kubernetes docs.

## Provisioning Compute Resources
Kubernetes (K8S) requires a set of machines to host the K8S control plane and the worker nodes where containers are ultimately run. In this section, we will use Microsoft azure cloud platform to provision the required compute resources for running a secure and highly available K8S cluster in a single region. Before doing so, we need to set up a secure network so that network traffic can be securely distributed not only within our K8S model but also for managing traffic to and from the internet.

Therefore, we dedicated a VNET for hosting the K8S cluster. We use one subnet within our network, that can handle up to 254 Azure virtual machines in case where they would be needed.
### az-kube-modules/kube-avnet (Networking)
We consider a large subnet within the created kubernetes virtual network, that can provision an wide IP address range to assign a private IP address to each node in the Kubernetes cluster. We provide the 10.240.0.0/24 IP address range that can host up to 254 compute instances. More information on how does Microsoft azure describe azure virtual network, security groups and subnets within networks, can be found in the official documentation of MS Azure.
We create a firewall referred to us as a Network Security Group,  and we end up assigning  it to the previously created subnet. Then, we go on to create some firewall rules that allow incoming SSH and HTTPS traffic. Despite having established some network security rules, we will explain later how we use azure load balancer to expose the kubernetes api server component to the outside world. More details about azure load balancer, can be found in MS Azure docs.
 This module creates the overall azure resource group with supporting infrastructure, such as Virtual Network, Security rules attached to a security group and a subnet eventually.
*https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/tree/master/az-kube-modules/kube-avnet*
### az-kube-modules/kube-bpip-lb
To make sure that we have a static kubernetes Ip address that will be used by the kubernetes API servers from the provisioned control plane's compute instances, we allocate a static public IP address that will be attached to the external load balancer fronting the Kubernetes API Servers. As highlighted on the proposed architecture of our Kubernetes the hard way implementation, we need to provision an external load balancer to front the Kubernetes API Servers. The previously created public static IP address will be attached to the resulting load balancer. The detailed implementation can be found below and the setup its health probe for the required Load Balancer rule are all created as shown on the link following the one that is here down.

This module created the kubernetes public ip and the load balancer within MS azure cloud platform.
 *https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/tree/master/az-kube-modules/kube-bpip-lb*
 
 ### az-kube-modules/kube-lb-rules
This module created the kubernetes the load balancer rules within MS azure cloud platform.
 *https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/tree/master/az-kube-modules/kube-lb-rules*
 
 ### Kubernetes Nodes
 As discussed earlier, both kubernetes control plane and workers are made of compute instances that are created depending on the chosen hosting platform. So, given that kubernetes nodes are all compute instances, we provisioned them using Ubuntu Server 18.04, from the fact that it has good support for the cri-containerd container runtime. Each compute instance is provisioned with a fixed private IP address that is chosen from the previously defined Ip range within the created Azure subnet. This lead us to simplified Kubernetes bootstrapping process.
 
 ### az-kube-modules/kube-cnodes
 AS shown in the proposed architectural design of kubernetes the hard way, we created three compute instances which will host the Kubernetes control plane in one Availability Set. Azure uses the concept of availability sets to highlight them as a logical grouping capability that makes it possible to automatically isolate Virtual Machines' resources from each other when they're deployed.\
This ensures that our provisioned compute instances remain operational even whenever a certain hardware or software might have faced some failure issues, hence, a reliable cloud based infrastructure solution that would ensure reliability and availability for hosting a ready to use kubernetes cluster.

This module created a set of linux virtual machines that would be used while boostrapping the kubernetes control plane within MS azure cloud platform.\
 *https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/tree/master/az-kube-modules/kube-cnodes*
 
 ### az-kube-modules/kube-dworker-nodes
By following the same approach as the one under which we provisioned kubernetes master nodes, we provisioned  kubernetes worker nodes. However, we should not that there some requirements that need to be fulfilled before creating these instances. Since the worker nodes are the ones that run scheduled pods and kubernetes workloads, it is vital to allocate a pod subnet from the Kubernetes cluster cidr range for each worker instance.  The pod subnet allocation will later be used to configure container networking and set up pods routes table. The pod-cidr instance tag will be used to expose pod subnet allocations to compute instances at runtime.

The Kubernetes cluster cidr range is defined by the Controller Manager's --cluster-cidr flag. Our implementation uses the cluster cidr range of 10.200.0.0/16, which can handle up to 254 subnets.

We create three compute instances which will host the Kubernetes worker nodes in an Availability Set that is different from the one that was previously used when we provisioned the control plane's compute resources.
 
This module created a set of linux virtual machines that would be used as kubernetes worker nodes.
 *https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/tree/master/az-kube-modules/kube-dworker-nodes*
 
## Provisioning the CA and Generating TLS Certificates

 ### az-kube-modules/kube-ecert-generation
 
This module creates not only the certificates and kubernetes configurations files, but also all the remaining necessary resources and deployments to have a fully set up kubernetes cluster.\
 *https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/blob/master/az-kube-modules/kube-ecert-generation/d-kube-ca.tf*. \
 All the remaing steps have their terraform files within the above module. The link is below:\
 *https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/tree/master/az-kube-modules/kube-ecert-generation*
 
## Generating both Kubernetes Configuration Files for Authentication and the Data Encryption Config and Key
*https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/blob/master/az-kube-modules/kube-ecert-generation/e-kube-configs.tf*.

## Bootstrapping the etcd Cluster
*https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/blob/master/az-kube-modules/kube-ecert-generation/f-kube-etcd.tf*.
## Bootstrapping the Kubernetes Control Plane
*https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/blob/master/az-kube-modules/kube-ecert-generation/g-boostrap-kube-control-plane.tf*.
## Bootstrapping the Kubernetes Worker Nodes
*https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/blob/master/az-kube-modules/kube-ecert-generation/h-bootstrapping-kube-worker-nodes.tf*.
## Configuring kubectl for Remote Access
*https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/blob/master/az-kube-modules/kube-ecert-generation/kubectl-remote-setup.tf*.
## Testing remote admin user with kubectl 
*https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/blob/master/az-kube-modules/kube-ecert-generation/kubectl-remote-test.tf*.
## Provisioning Pod Network Routes
### az-kube-modules/kube-pods-route-table
*https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/tree/master/az-kube-modules/kube-pods-route-table*.
## Deploying the DNS Cluster Add-on
*https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/blob/master/az-kube-modules/kube-ecert-generation/pods-dns-set-up.tf*.
## Adding two namespaces for two external users to use the set up kubernetes cluster
  Here we add two users, one from a company called **Devoteam France and an other from an engineering school known as Telecom SudParis.**
we use the kubernetes RBAC authorization to create roles and rolesbindings that grant different permissions to these two users with respect to their namespaces.\

*https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/blob/master/az-kube-modules/kube-ecert-generation/add-kube-users-with-permissions.tf*.



# Installation
The following steps are required to setup and run this project:

Clone the repo  **https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure.git**
## SSH
Generate an SSH key which can be used to SSH to the Kubernetes vms instances which will be created within MS Azure public cloud. The generated public/private key pair should be generated in a folder matching the path found in the ssh_key_data variable for path to public key and make sure that both the public key and private key can be located from the .ssh directory. This will ensure that the Terraform **vm** files can read them correctly. Ensure that the ssh agent is running from your local machine that you used to clone the repo.

Ensure that the AZURE credentials profile that you wish to use to run this project is specified correctly in your Azure CLI authentication to Azure portal . Ensure that your subscription id is configured  into azure provider file before testing. 

## Install Terraform 
## Install kubectl
From the project root directory, run :
## run terraform init
 This will ensure that all the necessary environment plugins are downloaded for terraform to run the implementation
## Run terraform plan
## Then run terraform apply 
After typing yes, terraform sets up the whole functionning  kubernetes cluster.
## Testing Two external users and Understanding RBAC Authorization
Now, the cluster has generated a kubernetes config file in your local machine.
Type kubectl config view;
You will find three configured remote users that have beeen granted different permissions to interact with our new kubernetes cluster hosted on MS Azure.
The defined RBAC roles and roleBindings can be found at the link below: \
*https://github.com/Pacifique2/Kubernetes-The-Hard6-Way-Terraform-Ms-Azure/blob/master/az-kube-modules/kube-ecert-generation/scripts/users-rolesRoleBings.sh*

The first user is the **admin user** that have been granted permissions at the cluster-scope.
The other two remote users are first, a **devoteam-pacy user within the devoteam-apps namespace** and a **tsp-pacy user within telecom-sud-paris-apps kubernetes namespace**. Each user has permissions to carry out applicaions deployments in the namespace to which he belongs. This means that devoteam-pacy user has no rights to deploy and view applications deployed within the telecom-sud-paris-apps kubernetes namespace and vice-versa. 


 

