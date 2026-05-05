# Fintech App Infrastructure Starter

This starter separates responsibilities:

- Terraform creates AWS infrastructure: VPC, EKS, ECS, separate internet-facing load balancers, autoscaling, logs, alarms, and a CloudWatch dashboard.
- GitHub Actions creates the ECR repository if missing, then builds the Docker image and pushes it to ECR.
- EKS and ECS both deploy the same ECR image tag.

## First-time setup

1. Create or choose an AWS IAM role for GitHub Actions OIDC.
2. Add this repository secret:

```text
AWS_GITHUB_ACTIONS_ROLE_ARN=arn:aws:iam::<account-id>:role/<role-name>
```

3. Edit the environment variables file before applying:

```powershell
notepad terraform/environments/dev/terraform.tfvars
```

Use `terraform/environments/prod/terraform.tfvars` when you want to apply the prod parent.

4. Optionally configure remote state:

```powershell
Copy-Item terraform/environments/dev/backend.tf.example terraform/environments/dev/backend.tf
```

5. Provision the infrastructure:

```powershell
cd terraform/environments/dev
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Use `terraform/environments/dev` or `terraform/environments/prod` as parent entry points. The dev and prod folders intentionally use the same module shape for now, with different names/CIDRs so they can exist separately later.

The child modules are organized here:

```text
terraform/modules/network     # VPC, subnets, routing, NAT
terraform/modules/eks         # EKS cluster, node group, observability add-on
terraform/modules/ecs         # ECS Fargate, ALB, target group, autoscaling
terraform/modules/argocd      # Argo CD install and application sync
terraform/modules/monitoring  # CloudWatch alarms and dashboard
```

6. Push to `main` or manually run the `Build and Push Docker Image` workflow.

## Deploying a specific image tag

The build workflow pushes two tags:

- `latest`
- the Git commit SHA

To deploy a specific version:

```powershell
terraform apply -var-file=terraform.tfvars -var "image_tag=<git-sha>"
```

## Important notes

- Terraform does not build the Docker image in this setup. GitHub Actions does.
- ECR is created by the build workflow if it does not already exist.
- RDS is not included yet. Database values are parameterized so RDS and Secrets Manager can be added cleanly later.
- The ECS service is exposed through an AWS Application Load Balancer.
- The EKS deployment is managed by Argo CD from `k8s/web-app` and exposed through its own internet-facing Kubernetes service load balancer.
- ECS sends container logs to CloudWatch Logs and has Container Insights enabled.
- EKS has control-plane logging enabled and installs the CloudWatch observability add-on for cluster/container visibility.
- Argo CD is installed into the `argocd` namespace and auto-syncs the `web-app` application from Git.
- The example EKS node group uses two `t3.small` nodes so Argo CD, CloudWatch, and the app have enough pod capacity.
