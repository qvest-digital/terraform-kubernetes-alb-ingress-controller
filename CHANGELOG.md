# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.1.0] - 2020-04-01

### Updated

- Default version of the ALB Ingress Controller has been set to [1.1.6](https://github.com/kubernetes-sigs/aws-alb-ingress-controller/releases/tag/v1.1.6).

### Added

- Support for AWS Shield related annotations has been added. This new feature
  needs a bunch of new AWS IAM permissions which have been added to the IAM policy
  used by the ALB Ingress Controller.

## [3.0.2] - 2020-02-09

### Fixed

- An unset IAM path prefix no longer leads to errors. ([#4](https://github.com/iplabs/terraform-kubernetes-alb-ingress-controller/issues/4))

## [3.0.1] - 2020-01-22

### Added

- Add ARN of the IAM role used by the ALB Ingress controller as output variable.

### Changed

- Improve documentation of input variables.

## [3.0.0] - 2020-01-22

### Added

- The type of the Kubernetes cluster can no be specified.
  Set this to `eks` if targeting a managed [EKS](https://aws.amazon.com/eks/) Cluster.
- If targeting EKS clusters, pods will [use IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html)
  as intended by AWS. ([#3](https://github.com/iplabs/terraform-kubernetes-alb-ingress-controller/issues/3))

### Updated

- The default version of the controller has been set to [v1.1.5](https://github.com/kubernetes-sigs/aws-alb-ingress-controller/releases/tag/v1.1.5)

## [2.0.0] - 2019-08-30

### Updated

- Module has been updated to Terraform 0.12 format. ([#1](https://github.com/iplabs/terraform-kubernetes-alb-ingress-controller/issues/1))

### Changed

- Kubernetes labels have been updated to comply with known best practices.

## [1.0.0] - 2019-04-12

### Added

- Initial version
