# Multi-tier architecture on AWS

This repository contains Terraform code to provision a 3-tier AWS environment (VPC, EKS cluster, and RDS) and Kubernetes manifests for a simple frontend/backend application running on the cluster.

Repository layout
- `infra-layer/` - Terraform code that provisions the required AWS infrastructure:
	- `provider.tf` - Terraform backend and AWS provider configuration.
	- `vpc.tf` - VPC module configuration with public, private and database subnets.
	- `eks.tf` - EKS cluster module configuration (managed node group).
	- `rds.tf` - RDS primary + replica modules and RDS security group.
	- `alb.tf` - IAM policy resource used by the AWS Load Balancer Controller (references `files/iam_policy.json`).
	- `locals.tf`, `variables.tf`, `output.tf` - local values, inputs and outputs.
	- `files/iam_policy.json` - IAM policy used to allow ALB operations for the controller.

- `k8s-layer/` - Kubernetes manifests for the sample application:
	- `backend-deployment.yaml` - Backend Deployment that reads DB credentials from a Kubernetes Secret named `rds-credentials`.
	- `backend-service.yaml` - ClusterIP Service exposing the backend on port 8080.
	- `frontend-deployment.yaml` - Frontend Deployment (nginx demo image) exposing port 80.
	- `frontend-service.yaml` - ClusterIP Service exposing the frontend on port 80.
	- `ingress.yaml` - Ingress manifest with annotations for the AWS ALB Ingress Controller (class `alb`) to expose the frontend to the internet.

High level architecture
- VPC with public, private and database subnets across three AZs.
- EKS cluster deployed into the private subnets with an EKS managed node group.
- RDS PostgreSQL primary (multi-AZ) and a read replica in the database subnets.
- Kubernetes application: a frontend served by an ALB (Ingress) that routes to a frontend Service; frontend calls backend Service which connects to RDS using credentials from a Secret.

Prerequisites
- Terraform v1.10.x (required_version ~> 1.10 in `provider.tf`).
- AWS credentials/profile that matches `environment_identifier` used by the provider (the provider uses `profile = var.environment_identifier`).
- kubectl configured to access the created EKS cluster (the cluster is configured with private endpoint only by default in `eks.tf`).
- AWS CLI installed and configured if you prefer to interact with AWS directly.

Notes about versions and modules
- Uses the official Terraform AWS modules:
	- `terraform-aws-modules/vpc/aws` v5.17.0
	- `terraform-aws-modules/eks/aws` v20.31.6
	- `terraform-aws-modules/rds/aws` v6.10.0
- EKS cluster version is set to `1.31` and cluster addons include coredns, kube-proxy, vpc-cni and pod identity agent.

Deployment guide

1) Initialize and apply Terraform

	- Set the `environment_identifier` variable (a profile name like `dev` or `prod` is expected by the provider). You can pass it on the CLI or via a `terraform.tfvars` file. Example CLI:

```bash
terraform init
terraform apply -var="environment_identifier=shared" -auto-approve
```

	- The Terraform S3 backend is configured in `provider.tf` to use bucket `tfstate-3-tier` in `eu-north-1`. Adjust the backend block or bucket name if you want a different backend.

2) Configure kubectl

	- After Terraform completes, retrieve the kubeconfig for the created EKS cluster. If you have the AWS CLI and `aws` profile configured, you can run:

```bash
aws eks --region eu-north-1 update-kubeconfig --name <cluster-name> --profile <profile>
```

	- Replace `<cluster-name>` with the output `cluster_name` shown by Terraform outputs (or use the pattern set in `eks.tf`).

3) Install AWS Load Balancer Controller (optional but recommended for ALB Ingress)

	- The repo includes an IAM policy (`infra-layer/files/iam_policy.json`) and `alb.tf` creates an IAM policy resource. You still need to create the corresponding IAM role for the service account used by the controller and install the controller manifest into the cluster. Follow the official AWS docs for the exact steps and version matching.

4) Deploy Kubernetes manifests

	- Create a Secret for RDS credentials expected by the backend Deployment. For example:

```bash
kubectl create secret generic rds-credentials \
	--from-literal=username=appdbuser \
	--from-literal=password=YOUR_DB_PASSWORD \
	--from-literal=host=<rds-endpoint> \
	--from-literal=port=5432
```

	- Apply the manifests in `k8s-layer/`:

```bash
kubectl apply -f k8s-layer/backend-deployment.yaml
kubectl apply -f k8s-layer/backend-service.yaml
kubectl apply -f k8s-layer/frontend-deployment.yaml
kubectl apply -f k8s-layer/frontend-service.yaml
kubectl apply -f k8s-layer/ingress.yaml
```

## Security and operational notes

- The EKS cluster is created with private API endpoint access only by default (`cluster_endpoint_public_access = false`). If you need public kubectl access, change the setting carefully and consider restricting CIDR blocks.
- RDS credentials are intentionally loaded from a Kubernetes Secret in the sample backend Deployment. For production, prefer AWS Secrets Manager or SSM Parameter Store with an IAM role and IRSA.
- The sample images used in the manifests are demo images (kubernetes-bootcamp, nginxdemos/hello). Replace them with your application images.

## Next steps / improvements

- Add an `outputs.tf` Terraform output for the EKS cluster name and kubeconfig helper.
- Add a small script or Makefile to simplify `terraform init/apply` and `kubectl apply` steps.
- Wire AWS IRSA for the AWS Load Balancer Controller and provide a Terraform-managed IAM role for the controller's service account.

## Contact / author

- Repository owner: m2rtenm
