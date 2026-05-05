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

## Answers (Assignment)

### (a) Architecture Design

Use a VPC across 2 Availability Zones with public subnets for ALBs/NAT and private subnets for EKS nodes, ECS tasks, RDS PostgreSQL, and Redis. ECS uses an internet-facing ALB, while EKS is exposed through a LoadBalancer service or ALB Ingress. For multi-region HA, deploy the same stack in a secondary region and use Route 53 health checks for failover. Security is handled with private subnets, security groups, IAM roles, encrypted secrets, and no hardcoded credentials; cost is controlled using small dev nodes and scaling production only when needed.

### (b) Terraform Strategy

Use parent folders like `terraform/environments/dev` and `terraform/environments/prod`, with reusable modules such as `network`, `eks`, `ecs`, `argocd`, and `monitoring`. Store remote state in S3 with DynamoDB locking, separated by environment and region. Multi-region can be handled using provider aliases or separate state folders per region. Main challenges are state drift, region sync, and dependency ordering, handled through module outputs, CI plans, and avoiding manual AWS changes.

### (c) Docker & Image Strategy

Use multi-stage Docker builds with slim/alpine base images, `.dockerignore`, non-root users, and only production dependencies. Store images in Amazon ECR and tag them with Git commit SHA plus `latest`. GitHub Actions builds, tests, scans, pushes the image, and updates the Kubernetes manifest with the new image tag.

### (d) Kubernetes Deployment

Use Kubernetes Deployments with rolling updates, readiness/liveness probes, and HPA for CPU or request-based autoscaling. Store secrets using Kubernetes Secrets for simple use, or AWS Secrets Manager with External Secrets for production. Services communicate internally using Kubernetes DNS and `ClusterIP`. Argo CD watches the Git repo and automatically syncs Kubernetes manifests to EKS.

### (e) CI/CD Pipeline Design

GitHub Actions runs on push to `main`: build, test, login to ECR, create ECR repo if missing, push image, and update the Kubernetes manifest. Argo CD detects the manifest change and deploys it to EKS automatically. If any pipeline step fails, deployment stops. Rollback is done by reverting the Git manifest or selecting an older commit SHA image tag.

### (f) Failure & Failover Scenario

Use Route 53 health checks and DNS failover to route traffic from the primary region to the secondary region. Keep secondary infrastructure ready using Terraform. PostgreSQL consistency can be handled with RDS cross-region replicas or Aurora Global Database, and Redis with ElastiCache Global Datastore. Tools used include Route 53, CloudWatch, RDS/Aurora replication, ECR replication, Terraform, and Argo CD.
