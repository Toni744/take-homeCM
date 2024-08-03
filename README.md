  QUOTES - APP

 Quotes App is a unique platform dedicated to showcasing the memorable and often thought-provoking quotes of Kanye West. This app features an API that allows users to access and display Kanye's quotes effortlessly. This details the deployment, infrastructure automation and monitoring architecture of the app.




Prerequisites
Before starting,  ensure you have the following tools installed:
Terraform
kubectl
Kustomize
ArgoCD CLI
Helm (for Prometheus and Grafana setup) 
AWS access

Terraform Modules
The Terraform configuration is modular, which allows for better organization and reuse of code. A Kubernetes cluster is provisioned on the AWS managed EKS platform using these modules. The primary modules used include:
eks: Provision the AWS Elastic Kubernetes cluster and node-groups.
vpc: Sets up the necessary VPC, subnets, and security groups.
roles: Deploys Roles and Policies for the nodes and cluster resources
Note: For external modules, locking to the exact version is encouraged, to prevent breaking production due to incompatibilities.

root/
├── providers.tf
├── main.tf
└── modules/
    ├── eks/
    │   ├── main.tf
    │   ├── variable.tf
    │   └── output.tf
    ├── vpc/
    │   ├── main.tf
    │   ├── variable.tf
    │   └── output.tf
    └── roles/
        ├── main.tf
        ├── variable.tf
        └── output.tf

The commands terraform init, terraform plan and terraform apply are used to implement our terraform config files. The root directory consists of the main.tf deployment file which calls various modules stored in the modules directory. Resources such as node-groups, clusters and a VPC which are used to provision the cluster are configured in the main.tf file. Each module contains reusable resources. Resources provisioned include 
 
VPC network
Public and a private subnet for the database
Auto-scaling group for redundancy
Network load Balancer
Security groups
Roles and policies. Etc
Terraform backend

Note: The terraform backend was stored in an S3 bucket with versioning enabled and locked with a Dynamodb table. 




Application Deployment with Kustomize(Kubernetes)

Kustomize is used to orchestrate application deployments into multiple Kubernetes clusters as well as environments providing for easy reusability of templates . It was used to deploy the application in this scenario. The directory structure used in this deployment was:


/quotes-app
├── base
│   ├── deployment.yaml
│   └── kustomization.yaml
└── overlays
   ├── dev(staging)
   │   ├── deployment-patch.yaml
   │   └── kustomization.yaml
   └── production
       ├── deployment-patch.yaml
       └── kustomization.yaml

Within the base configuration directory, the main deployment.yaml file contains configurations for the 

Quotes application,
Load balancer service, 
Postgres database to store quotes from the application, 
Database secrets configuration, as well as 
Persistent volume and persistent volume claims for the database 
A cron job for recurrent backup of the postgres db *(This uses an empty db-backup image)

Kubernetes secrets are encouraged for use in production environments instead of configmaps, external secrets managers also exist for kubernetes like AWS Secrets manager.



Monitoring with Prometheus & Grafana

Helm is used to install Prometheus and Grafana using on the Kubernetes cluster, both prometheus and grafana namespaces are created and their repositories installed on the cluster. Their services are exposed and secrets retrieved to access the GUI. Metrics to monitor include. Prometheus especially uses node exporters to expose system metrics

Network I/O pressure
CPU usage
Pod CPU usage
Cluster memory usage


ArgoCD

For CD, argoCD manifests are created to continuously track changes in the github repository and push the same to the kubernetes cluster. 


Challenges faced.

Some challenges faced include version incompatibility, CIDR block API errors on terraform
Cycle errors due to cyclical dependency of resources.
File system structuring
ArgoCD due to some unprovisioned resources.

Also had a trade off between using helm templates and Kustomize.
