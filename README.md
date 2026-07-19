# Jenkins Terraform EKS Pipeline

This project creates an Amazon EKS cluster and its supporting network in **us-east-1 only**. Terraform creates the VPC, public and private subnets, internet and NAT gateways, IAM roles, EKS control plane, managed node group, CloudWatch control-plane logging, and core EKS managed add-ons.

## Repository Files

- `Jenkinsfile` — parameterized Jenkins pipeline for init, plan, apply, and destroy.
- `versions.tf` — Terraform, provider, and S3 backend requirements.
- `main.tf` — us-east-1 VPC, IAM, EKS, nodes, and add-ons.
- `variables.tf` — configurable cluster and node settings.
- `outputs.tf` — cluster, network, and kubectl outputs.
- `terraform.tfvars.example` — example configuration.

## Prerequisites

The Jenkins agent can use any node, but the selected node must provide:

- Terraform 1.6 or newer
- AWS CLI v2
- Git
- Jenkins AWS Credentials plugin
- An AWS credential with access to EKS, EC2/VPC, IAM, CloudWatch Logs, and S3 state

Before the first run, create the S3 state bucket in `us-east-1`. The pipeline does not create its own backend because Terraform must initialize the backend before it can manage resources.

Create a Jenkins **AWS Credentials** credential. The default credential ID expected by the pipeline is:

```text
aws-jenkins-terraform
```

The pipeline defaults to AWS account `768477844960` and the `2026-state` S3 state bucket, so these values do not need to be entered for each build. The account guardrail stops the build if Jenkins authenticates to a different AWS account.

## Jenkins Pipeline Actions

The `ACTION` parameter supports:

- `INIT` — initialize the S3 backend.
- `PLAN` — initialize and create a saved plan.
- `APPLY` — plan and create or update the EKS cluster. `CONFIRM_APPLY=true` is required.
- `DESTROY` — create and apply a destroy plan. `CONFIRM_DESTROY=DESTROY` is required.

`AUTO_APPROVE=false` adds a Jenkins input approval before apply or destroy. The pipeline always uses `us-east-1`; the AWS region is intentionally not a parameter.

The following cluster settings are parameterized:

- Cluster name and optional Kubernetes version
- Environment tag
- Node instance type
- Minimum, desired, and maximum node counts
- AWS credential ID and optional expected AWS account ID
- S3 state bucket and key
- Terraform variable file

## Pull Request Planning

Create the Jenkins job as a **Multibranch Pipeline** and set the script path to `Jenkinsfile`. Enable pull-request discovery in the GitHub Branch Source configuration and configure a GitHub webhook for Jenkins.

When Jenkins exposes `CHANGE_ID`, the pipeline forces the effective action to `PLAN`. A pull request cannot select `APPLY` or `DESTROY` through pipeline parameters.

For security:

- Do not expose the deployment credential to untrusted fork pull requests.
- Configure the GitHub Branch Source trust policy to trust only organization members or explicitly trusted contributors.
- Prefer a separate least-privilege, read-oriented AWS credential for pull-request planning.
- Protect the `main` branch and require the Jenkins plan check before merging.

## First Deployment

1. Create the Jenkins Multibranch Pipeline and AWS credential.
2. Run `ACTION=PLAN` and review `terraform-plan.txt` in the Jenkins artifacts.
3. Run `ACTION=APPLY` with `CONFIRM_APPLY=true`.
4. Keep `AUTO_APPROVE=false` if a manual approval is required.

After deployment:

```bash
aws eks update-kubeconfig --region us-east-1 --name jenkins-eks
kubectl get nodes
```

## Important Cost and Security Notes

- The default configuration creates a NAT gateway, EKS control plane, EC2 worker nodes, and CloudWatch logs, all of which incur AWS charges.
- `endpoint_public_access_cidrs` defaults to `0.0.0.0/0` for initial connectivity. Restrict it to Jenkins, VPN, or corporate egress CIDRs before a production deployment.
- Remote state can contain sensitive infrastructure data. Keep the S3 bucket private, encrypted, versioned, and access-controlled.
- Destroy the cluster when it is no longer required to stop ongoing charges.
