provider "kubernetes" {
  version = "~> 1.5"
}

provider "aws" {
  version = "~> 2.6"
}

locals {
  aws_alb_ingress_controller_version      = "1.1.2"
  aws_alb_ingress_controller_docker_image = "docker.io/amazon/aws-alb-ingress-controller:v${local.aws_alb_ingress_controller_version}"
  aws_alb_ingress_class                   = "alb"
}

resource "aws_iam_role" "this" {
  name        = "k8s-${var.k8s_cluster_name}-alb-ingress-controller"
  description = "Permissions required by the Kubernetes AWS ALB Ingress controller to do it's job."
  path        = "${var.aws_iam_path_prefix}"

  tags = "${var.aws_tags}"

  force_detach_policies = true

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "this" {
  name        = "k8s-${var.k8s_cluster_name}-alb-management"
  description = "Permissions that are required to manage the AWS Application Load Balancer."
  path        = "${var.aws_iam_path_prefix}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:GetCertificate"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVpcs",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:RemoveListenerCertificates",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:SetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "tag:GetResources",
        "tag:TagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf:GetWebACL"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = "${aws_iam_policy.this.arn}"
  role       = "${aws_iam_role.this.name}"
}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = "aws-alb-ingress-controller"
    namespace = "${var.k8s_namespace}"

    labels {
      "app"      = "aws-alb-ingress-controller"
      "heritage" = "Terraform"
    }
  }
}

resource "kubernetes_cluster_role" "this" {
  metadata {
    name = "aws-alb-ingress-controller"

    labels {
      "app"      = "aws-alb-ingress-controller"
      "heritage" = "Terraform"
    }
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "configmaps",
      "endpoints",
      "events",
      "ingresses",
      "ingresses/status",
      "services",
    ]

    verbs = [
      "create",
      "get",
      "list",
      "update",
      "watch",
      "patch",
    ]
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "nodes",
      "pods",
      "secrets",
      "services",
      "namespaces",
    ]

    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
}

resource "kubernetes_cluster_role_binding" "this" {
  metadata {
    name = "aws-alb-ingress-controller"

    labels {
      "app"      = "aws-alb-ingress-controller"
      "heritage" = "Terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${kubernetes_cluster_role.this.metadata.0.name}"
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.this.metadata.0.name}"
    namespace = "${kubernetes_service_account.this.metadata.0.namespace}"
  }
}

resource "kubernetes_deployment" "this" {
  depends_on = [
    "kubernetes_cluster_role_binding.this",
  ]

  metadata {
    name      = "aws-alb-ingress-controller"
    namespace = "${var.k8s_namespace}"

    labels {
      "app"      = "aws-alb-ingress-controller"
      "version"  = "${local.aws_alb_ingress_controller_version}"
      "heritage" = "Terraform"
    }

    annotations {
      "field.cattle.io/description" = "AWS ALB Ingress Controller"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        "name" = "aws-alb-ingress-controller"
      }
    }

    template {
      metadata {
        labels {
          "name" = "aws-alb-ingress-controller"
        }

        annotations {
          # Annotation to be used by KIAM
          "iam.amazonaws.com/role" = "${aws_iam_role.this.arn}"
        }
      }

      spec {
        dns_policy     = "ClusterFirst"
        restart_policy = "Always"

        container {
          name                     = "server"
          image                    = "${local.aws_alb_ingress_controller_docker_image}"
          image_pull_policy        = "Always"
          termination_message_path = "/dev/termination-log"

          args = [
            "--ingress-class=${local.aws_alb_ingress_class}",
            "--cluster-name=${var.k8s_cluster_name}",
            "--aws-vpc-id=${var.aws_vpc_id}",
            "--aws-region=${var.aws_region_name}",
            "--aws-max-retries=10",
          ]

          volume_mount {
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
            name       = "${kubernetes_service_account.this.default_secret_name}"
            read_only  = true
          }

          port {
            name           = "health"
            container_port = 10254
            protocol       = "TCP"
          }

          readiness_probe {
            http_get {
              path   = "/healthz"
              port   = "health"
              scheme = "HTTP"
            }

            initial_delay_seconds = 30
            period_seconds        = 60
            timeout_seconds       = 3
          }

          liveness_probe {
            http_get {
              path   = "/healthz"
              port   = "health"
              scheme = "HTTP"
            }

            initial_delay_seconds = 60
            period_seconds        = 60
          }
        }

        volume {
          name = "${kubernetes_service_account.this.default_secret_name}"

          secret {
            secret_name = "${kubernetes_service_account.this.default_secret_name}"
          }
        }

        service_account_name             = "${kubernetes_service_account.this.metadata.0.name}"
        termination_grace_period_seconds = 60
      }
    }
  }
}
