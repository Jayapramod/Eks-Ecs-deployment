# Fintech App Infrastructure Starter

This starter separates responsibilities:

- Terraform creates AWS infrastructure: ECR, VPC, EKS, ECS, load balancer, autoscaling, and logs.
- GitHub Actions builds the Docker image and pushes it to ECR.
- EKS and ECS both deploy the same ECR image tag.

## First-time setup

1. Create or choose an AWS IAM role for GitHub Actions OIDC.
2. Add this repository secret:

```text
AWS_GITHUB_ACTIONS_ROLE_ARN=arn:aws:iam::<account-id>:role/<role-name>
```

3. Copy the Terraform example variables:

```powershell
Copy-Item terraform/terraform.tfvars.example terraform/terraform.tfvars
```

4. Optionally configure remote state:

```powershell
Copy-Item terraform/backend.tf.example terraform/backend.tf
```

5. Provision the infrastructure:

```powershell
cd terraform
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

The included GitHub Actions Terraform plan workflow uses default variables so it can run before `terraform.tfvars` exists in the repository.

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
- ECR must exist before the build workflow can push images.
- RDS is not included yet. Database values are parameterized so RDS and Secrets Manager can be added cleanly later.
- The ECS service is exposed through an AWS Application Load Balancer.
- The EKS deployment uses a Kubernetes `LoadBalancer` service for a starter deployment.
