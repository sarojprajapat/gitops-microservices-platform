# GitOps Microservices Platform

An end-to-end DevOps project demonstrating a production-style GitOps workflow — from containerized microservices to automated CI/CD, security scanning, monitoring, and cloud deployment on Azure Kubernetes Service (AKS).

## Architecture

```
Developer pushes code
        │
        ▼
GitHub Actions (CI)
  ├── Build Docker image
  ├── Scan image with Trivy (security)
  ├── Push image to GHCR (GitHub Container Registry)
  └── Update Helm values.yaml with new image tag
        │
        ▼
Git repository (source of truth)
        │
        ▼
Argo CD (GitOps controller)
  ├── Detects change in Git
  ├── Auto-syncs to Kubernetes cluster
  └── Self-heals any manual drift
        │
        ▼
Kubernetes (Kind locally / AKS in production)
  ├── App pods (FastAPI microservice)
  ├── Prometheus + Grafana (monitoring)
  └── Custom app metrics via /metrics endpoint
```

## Tech Stack

| Layer | Tool |
|---|---|
| Application | Python, FastAPI |
| Containerization | Docker |
| Orchestration | Kubernetes (Kind for local dev, AKS for cloud) |
| Package Management | Helm |
| GitOps / CD | Argo CD |
| CI | GitHub Actions |
| Container Registry | GitHub Container Registry (GHCR) |
| Security Scanning | Trivy |
| Monitoring | Prometheus, Grafana |
| Infrastructure as Code | Terraform |
| Cloud Provider | Microsoft Azure (AKS) |

## Features

- **Zero-downtime deployments** via Kubernetes rolling updates
- **Self-healing infrastructure** — Kubernetes automatically restarts failed pods; Argo CD reverts manual drift from Git
- **Fully automated CI/CD** — a single `git push` triggers build, security scan, registry push, and deployment
- **Security-first** — every image is scanned for CVEs before deployment; dependencies are kept patched (see Security section below)
- **Observability** — custom application metrics (request count, latency) exposed via Prometheus, visualized in Grafana
- **Infrastructure as Code** — the entire AKS cluster is defined in Terraform and reproducible with a single `terraform apply`
- **Cost-conscious cloud design** — minimal single-node AKS cluster, Free pricing tier, fully deletable with `terraform destroy`

## Project Structure

```
.
├── main.py                  # FastAPI application
├── requirements.txt         # Python dependencies
├── Dockerfile                # Container image definition
├── myapi-chart/              # Helm chart for the application
│   ├── values.yaml
│   └── templates/
├── servicemonitor.yaml       # Prometheus scrape config for custom metrics
├── terraform/                 # Infrastructure as Code for AKS
│   ├── main.tf
│   └── variables.tf
└── .github/workflows/ci.yml  # CI/CD pipeline definition
```

## How It Works — Step by Step

1. **Local development**: The FastAPI app is containerized with Docker and tested on a local Kind (Kubernetes-in-Docker) cluster — no cloud cost incurred.
2. **Packaging**: A Helm chart templates the Kubernetes manifests (Deployment, Service), making the app deployable to any environment by changing only `values.yaml`.
3. **GitOps**: Argo CD continuously watches this Git repository. Any change to `myapi-chart/` is automatically detected and applied to the cluster — no manual `kubectl apply` needed.
4. **CI/CD**: On every push to `main`, GitHub Actions builds the Docker image, scans it with Trivy, pushes it to GHCR, and updates `values.yaml` with the new image tag — completing the automation loop.
5. **Monitoring**: A `ServiceMonitor` tells Prometheus to scrape the app's `/metrics` endpoint (exposed via `prometheus-fastapi-instrumentator`), and Grafana visualizes request counts, latency, and cluster resource usage.
6. **Cloud deployment**: The same Helm chart and Argo CD setup deploy identically to a real Azure AKS cluster, provisioned via Terraform.

## Security

Every image is scanned with Trivy as part of the CI pipeline. Known-fixable vulnerabilities in application dependencies (e.g. pip, starlette) are patched via version upgrades. Base-OS-level vulnerabilities without an available fix, or in unused components, are documented as accepted risk — reflecting a risk-based approach used in real-world security practice.

## Cost Control

- AKS control plane: Free tier (no charge)
- Single Standard_B2s_v2 worker node
- Entire cloud environment is defined in Terraform and can be destroyed with `terraform destroy` and rebuilt in ~15 minutes with `terraform apply`

## Local Setup

```bash
# 1. Build and test locally on Kind
docker build -t myapi:v1 .
kubectl apply -f deployment.yaml

# 2. Or deploy via Helm
helm install myapi-release myapi-chart

# 3. Point Argo CD at this repo for full GitOps automation
```

## Cloud Deployment (Azure AKS)

```bash
cd terraform
terraform init
terraform plan
terraform apply

az aks get-credentials --resource-group gitops-demo-rg --name gitops-aks
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## Author

Saroj Prajapat — MCA student specializing in Cloud & DevOps, built as a portfolio project targeting Cloud/DevOps engineering roles.
