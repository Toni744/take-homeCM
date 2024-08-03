module "vpc" {
  source      = "./modules/vpc"
  vpc_cidr    = "10.0.0.0/16"
  vpc_name    = "main-vpc"
  subnet_count = 2
  
}


module "roles" {
  source            = "./modules/roles"
  cluster_role_name = "eks-role"
  node_role_name    = "eks-node-role"
}


module "eks" {
  source           = "./modules/eks"
  cluster_name     = "eks-cluster"
  node_group_name  = "eks-node-group"
  cluster_role_arn = module.roles.eks_cluster_role_arn
  node_role_arn    = module.roles.eks_node_role_arn
  subnet_ids       = module.vpc.public_subnet_ids
  desired_size     = 2
  max_size         = 3
  min_size         = 1
  vpc_id           = module.vpc.vpc_id
  sg_name          = "eks-sg"

}

data "aws_eks_node_group" "eks-node-group" {
  cluster_name = "eks-cluster"
}

resource "time_sleep" "wait_for_kubernetes" {

    depends_on = [
        data.aws_eks_cluster.eks-cluster
    ]

    create_duration = "20s"
}

resource "kubernetes_namespace" "kube-namespace" {
  depends_on = [data.aws_eks_node_group.eks-node-group, time_sleep.wait_for_kubernetes]
  metadata {
    
    name = "prometheus"
  }
}

resource "helm_release" "prometheus" {
  depends_on = [kubernetes_namespace.kube-namespace, time_sleep.wait_for_kubernetes]
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.kube-namespace.id
  create_namespace = true
  version    = "45.7.1"
  values = [
    file("values.yaml")
  ]
  timeout = 2000
  

set {
    name  = "podSecurityPolicy.enabled"
    value = true
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = false
  }

  set {
    name = "server\\.resources"
    value = yamlencode({
      limits = {
        cpu    = "200m"
        memory = "50Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "30Mi"
      }
    })
  }
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "mycomponents_tf_lockid"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}
