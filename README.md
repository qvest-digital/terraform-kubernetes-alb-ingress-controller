# Terraform module: AWS ALB Ingress Controller installation

This Terraform module can be used to install the [AWS ALB Ingress Controller](https://github.com/kubernetes-sigs/aws-alb-ingress-controller)
into a Kubernetes cluster.

## Improved integration with Amazon Elastic Kubernetes Service (EKS)

This module can be used to install the ALB Ingress controller into a "vanilla" Kubernetes cluster (which is the default)
or it can be used to integrate tightly with AWS-managed [EKS](https://aws.amazon.com/eks/) clusters which allows the deployed pods to
[use IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html).

It is required, that an OpenID connect provider [has already been created](https://www.terraform.io/docs/providers/aws/r/eks_cluster.html#example-iam-role-for-eks-cluster) for your EKS cluster for this feature to work.

Just make sure that you set the variable `k8s_cluster_type` type if running on EKS.

## Examples

### EKS deployment

To deploy the AWS ALB Ingress Controller into an EKS cluster, the following
snippet might be used.

```hcl
module "alb_ingress_controller" {
  source  = "iplabs/alb-ingress-controller/kubernetes"
  version = "3.1.0"

  k8s_cluster_type = "eks"
  k8s_namespace    = "kube-system"

  aws_region_name  = "us-east-1"
  aws_vpc_id       = var.aws_vpc_id       # Your VPC ID goes here.
  k8s_cluster_name = var.k8s_cluster_name # Your AWS EKS Cluster ID goes here.
}
```
