# Terraform Kubernetes Infrastructure

Terraform configuration for deploying and managing Kubernetes infrastructure and applications.

This repository currently demonstrates managing a Kubernetes cluster using Terraform modules, including:

* Kubernetes namespaces
* NGINX application deployment
* Argo CD installation using Helm
* Kubernetes and Helm provider configuration
* Modular Terraform infrastructure

## Repository Structure

```text
.
├── deployments/
├── kubernetes/
│   └── nginx/
│       └── nginx-deployment.yaml
├── local.yaml
├── main.tf
├── outputs.tf
├── provider.tf
├── terraform-modules/
│   ├── argocd/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── infra/
│       ├── main.tf
│       └── outputs.tf
├── test/
└── variables.tf
```

## Architecture

The root Terraform configuration calls two modules:

```text
Root Terraform Configuration
│
├── terraform-modules/infra
│   ├── Creates the application namespace
│   └── Deploys NGINX
│
└── terraform-modules/argocd
    ├── Creates the Argo CD namespace
    └── Installs Argo CD using Helm
```

## Requirements

* Terraform
* Access to a Kubernetes cluster
* A valid Kubernetes kubeconfig file
* Kubernetes API access
* Helm provider access to the Kubernetes cluster

The Terraform configuration uses the following providers:

* Kubernetes provider: `hashicorp/kubernetes`
* Helm provider: `hashicorp/helm`

Provider versions are currently defined as:

```hcl
kubernetes >= 2.0
helm       >= 3.0
```

## Connecting to a Kubernetes Cluster

The current provider configuration uses the following kubeconfig:

```text
./local.yaml
```

The provider is currently configured using an absolute path:

```hcl
provider "kubernetes" {
  config_path = "/home/smarz/terraform/terraform-infra/local.yaml"
}

provider "helm" {
  kubernetes = {
    config_path = "/home/smarz/terraform/terraform-infra/local.yaml"
  }
}
```

Before running Terraform, verify that the kubeconfig works:

```bash
kubectl --kubeconfig ./local.yaml get nodes
```

You should see the nodes in the target Kubernetes cluster.

### Using a Different Cluster

To point Terraform at another cluster, replace `local.yaml` with the kubeconfig for the desired cluster.

For example:

```bash
cp /path/to/new/kubeconfig ./local.yaml
```

Then verify access:

```bash
kubectl --kubeconfig ./local.yaml get nodes
```

> Always verify the target cluster before running `terraform apply`.

## Initialize Terraform

From the repository root:

```bash
terraform init
```

This downloads the required Terraform providers and initializes the working directory.

## Review the Terraform Plan

Before making changes to the cluster:

```bash
terraform plan
```

The plan should show the resources Terraform intends to create or modify.

## Apply the Configuration

Apply the configuration:

```bash
terraform apply
```

Terraform will prompt for confirmation before making changes.

To automatically approve the plan:

```bash
terraform apply -auto-approve
```

## Configurable Namespace

The default application namespace is defined in `variables.tf`:

```hcl
variable "namespace" {
  description = "Namespace to create"
  type        = string
  default     = "terraform-demo"
}
```

The default namespace is:

```text
terraform-demo
```

You can override it when running Terraform:

```bash
terraform apply -var="namespace=my-application"
```

This will create the namespace:

```text
my-application
```

and deploy the NGINX application into that namespace.

## Current Resources

### NGINX Application

The `infra` module creates the application namespace and deploys NGINX.

The current deployment configuration is:

```text
Namespace: terraform-demo
Deployment: nginx-deployment
Replicas: 2
Container: nginx
Image: nginx:1.25
Container Port: 80
```

The deployment is managed by:

```text
terraform-modules/infra/main.tf
```

The resulting resources can be viewed with:

```bash
kubectl --kubeconfig ./local.yaml -n terraform-demo get all
```

Example:

```bash
kubectl --kubeconfig ./local.yaml \
  -n terraform-demo get deployment,pods
```

## Argo CD

The `argocd` module creates the `argocd` namespace and installs Argo CD using the official Argo Helm repository.

The current configuration installs:

```text
Chart: argo-cd
Chart Version: 8.3.1
Namespace: argocd
```

The Argo CD server is configured as a NodePort service:

```text
NodePort: 30080
```

After Terraform completes, verify the installation:

```bash
kubectl --kubeconfig ./local.yaml -n argocd get pods
```

Check the services:

```bash
kubectl --kubeconfig ./local.yaml -n argocd get svc
```

The Argo CD server should be available through a Kubernetes node IP on port `30080`:

```text
https://<NODE-IP>:30080
```

## Adding Another Application

There are two basic ways to add applications to this repository.

### Option 1: Add the Application to the Existing Infrastructure Module

For a simple application, resources can be added to:

```text
terraform-modules/infra/main.tf
```

For example, another deployment could be added:

```hcl
resource "kubernetes_deployment" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.example.metadata[0].name

    labels = {
      app = "redis"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {
        container {
          name  = "redis"
          image = "redis:7"

          port {
            container_port = 6379
          }
        }
      }
    }
  }
}
```

After adding the resource:

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
```

Verify the new deployment:

```bash
kubectl --kubeconfig ./local.yaml \
  -n terraform-demo get deployments
```

### Option 2: Create a Separate Terraform Module

For larger applications, create a dedicated module:

```text
terraform-modules/
└── my-application/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

Then add the module to the root `main.tf`:

```hcl
module "my_application" {
  source    = "./terraform-modules/my-application"
  namespace = var.namespace
}
```

This approach keeps larger applications separated and makes the Terraform configuration easier to maintain.

## Adding a Helm-Based Application

Applications distributed as Helm charts can be added using a `helm_release` resource.

For example:

```hcl
resource "helm_release" "my_application" {
  name       = "my-application"
  repository = "https://example.com/helm-charts"
  chart      = "my-application"
  namespace  = var.namespace

  create_namespace = false
}
```

The application can then be managed using the normal Terraform workflow:

```bash
terraform plan
terraform apply
```

## Terraform Workflow

The recommended workflow is:

```bash
# Format Terraform files
terraform fmt -recursive

# Initialize Terraform
terraform init

# Validate the configuration
terraform validate

# Review the proposed changes
terraform plan

# Apply the changes
terraform apply
```

After applying changes, verify the cluster:

```bash
kubectl --kubeconfig ./local.yaml get namespaces

kubectl --kubeconfig ./local.yaml \
  -n terraform-demo get pods

kubectl --kubeconfig ./local.yaml \
  -n argocd get pods
```

## Important Files

| File                       | Purpose                                          |
| -------------------------- | ------------------------------------------------ |
| `main.tf`                  | Calls the Terraform modules                      |
| `provider.tf`              | Configures the Kubernetes and Helm providers     |
| `variables.tf`             | Defines root-level Terraform variables           |
| `outputs.tf`               | Defines Terraform outputs                        |
| `local.yaml`               | Kubeconfig used to connect to the target cluster |
| `terraform-modules/infra`  | Manages the application namespace and NGINX      |
| `terraform-modules/argocd` | Installs Argo CD using Helm                      |

## Terraform State and Sensitive Files

The following files may contain sensitive information and should generally not be committed to a public GitHub repository:

```text
local.yaml
terraform.tfstate
terraform.tfstate.backup
terraform.tfstate.bak
rancher.tfplan
```

A recommended `.gitignore`:

```gitignore
# Terraform working directory
.terraform/

# Terraform state files
*.tfstate
*.tfstate.*
*.tfplan

# Local kubeconfig
local.yaml
```

The `.terraform.lock.hcl` file is normally safe and recommended to commit because it locks provider versions.

## Future Improvements

Potential improvements to this repository include:

* Replace the hard-coded kubeconfig path with a variable or environment-based configuration
* Add Kubernetes Services for deployed applications
* Add additional application modules
* Add Helm-based application modules
* Manage Argo CD Applications through Terraform
* Add remote Terraform state
* Add CI/CD validation using GitHub Actions
* Add separate configurations for development, test, and production clusters
