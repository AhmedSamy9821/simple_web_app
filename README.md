# Simple Web App on GCP with Cloud Run, Cloud Storage, and CI/CD

## Prerequisites

Before deploying, make sure the following resources and accounts are prepared:

1. **Google Cloud Provider**

   * This project runs on GCP.

2. **Cloud Storage**

   * **Terraform backend bucket** → must exist **before forking the repo**; used to store Terraform state files securely.

3. **Workload Identity Federation (WIF)**

   * Create **two WIF providers** for GitHub Actions:

     * **Terraform WIF** → used by Terraform pipeline
     * **CI/CD WIF** → used by CI/CD pipeline to build and deploy Cloud Run
   * Official documentation: [Workload Identity Federation with Deployment Pipelines](https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines)

4. **Service Accounts and IAM Roles**

| Service Account | Purpose                      | Required Roles                                                                         |
| --------------- | ---------------------------- | -------------------------------------------------------------------------------------- |
| Terraform SA    | Runs Terraform pipeline      | `roles/editor`, `roles/run.admin` , `roles/logging.configWriter`                                                     |
| CI/CD SA        | Runs GitHub Actions pipeline | `roles/artifactregistry.writer`, `roles/run.developer`, `roles/iam.serviceAccountUser` |
| Cloud Run SA    | Runtime of Cloud Run service | `roles/storage.objectCreator` (for uploading files to bucket)                          |

5. **Artifact Registry**

   * Create a Docker repository called `simple-web-app` for your container images.

6. **GitHub Repository**

   * Fork the repo.
   * Add the following GitHub Secrets:

     * `CI_CD_SA`
     * `CI_CD_WORKLOAD_IDENTITY_PROVIDER`
     * `PROJECT_ID`
     * `TERRAFORM_SA`
     * `TERRAFORM_WORKLOAD_IDENTITY_PROVIDER`

---

## Quick Start

Follow these steps to deploy the application:

1. **Select environment**

   * The pipeline uses `workflow_dispatch` to choose one of your environments: `dev`, `uat`, `stage`, or `prod`.

2. **Configure Terraform variables**

   * Each environment has its own `.tfvars` file:

     * `dev.tfvars`, `uat.tfvars`, `stage.tfvars`, `prod.tfvars`
   * Example variables (do **not** include sensitive values):

```hcl
# Global variables
env    = "<environment>"
region = "<region>"

# Buckets
assets_bucket_name   = "<assets-bucket-name>"
assets_bucket_class  = "<assets-bucket-class>"
logging_bucket_name  = "<logging-bucket-name>"
logging_bucket_class = "<logging-bucket-class>"

# VPC (Terraform creates VPC + subnet)
vpc_name           = "<vpc-name>"
first_subnet_name  = "<first-subnet-name>"
first_subnet_range = "<subnet-cidr>"

# Cloud Run
cloud_run_service_name  = "<cloud-run-service-name>"
cloud_run_min_instances = "<min-instances>"
cloud_run_max_instances = "<max-instances>"
cloud_run_started_image = "<started-image>"
cloud_run_port          = "<port>"

# Load Balancer
lb_domain_name = "<domain-name>"
```

> **Note:** The VPC and subnet created by Terraform can be used in the future to connect your Cloud Run service to Cloud Storage privately via **Serverless VPC Access**, enabling secure communication without exposing the traffic to the public internet.
> Terraform will also create an HTTP Load Balancer with the specified domain name that routes traffic to the Cloud Run service.

3. **Deploy infrastructure with Terraform**

   * Trigger the Terraform pipeline in GitHub Actions.
   * Terraform will create:

     * Cloud Run service
     * GCS assets bucket
     * Logging and monitoring resources
     * VPC and subnet for potential private connections
     * HTTP Load Balancer with the specified domain pointing to Cloud Run

4. **Build and deploy app via CI/CD**

   * The CI/CD pipeline will:

     1. Build the Docker image
     2. Push the image to Artifact Registry
     3. Deploy the new image to Cloud Run

> Note: The Cloud Run service is created by Terraform; CI/CD pipeline only updates the image.

---

## Configuration

* **Terraform `.tfvars` files**: Define all environment-specific variables per environment.
* **Cloud Run environment variables**:

  * `ASSETS_BUCKET` → name of the GCS bucket
* **VPC / Serverless VPC Access (future use)**:

  * Cloud Run can attach to the VPC/subnet via **Serverless VPC Connector** for private access to GCS or other resources.
* **Cloud Run instances**:

  * Configure **min/max instances** in `.tfvars` per environment.
* **Load Balancer**:

  * Domain name and routing managed by Terraform, automatically forwarding traffic to Cloud Run.

---

## Testing

1. **Verify endpoints**:

   * Root: `https://<CLOUD_RUN_URL>/` → should return `Hello World! Timestamp: ...`
   * Health: `https://<CLOUD_RUN_URL>/health` → should return `{ "status": "ok" }`

2. **Verify file upload**:

   * Use `/upload` form in the browser.
   * Ensure uploaded files appear in the GCS bucket.

3. **Logs**:

   * Check **Cloud Logging** in GCP for app logs.

---

## Cleanup

To avoid charges:

1. Comment out the contents of `main.tf` and `output.tf`:

```hcl
/*
resource "..." {}
*/
```

2. Trigger the **infrastructure pipeline** (Terraform apply) to destroy resources.

3. **Manually delete images** from Artifact Registry; Terraform does not remove container images automatically.

---

## Troubleshooting

1. **GitHub Actions WIF Errors**

   * Often caused by incorrect **attribute mapping** or **condition** in the WIF provider.
   * Dump OIDC token claims to debug `sub` value:

```bash
set -e
TOKEN=$(curl -sSL \
  -H "Authorization: Bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
  "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=foo")
IDTOKEN=$(echo $TOKEN | jq -r '.value')
echo "Full token: $IDTOKEN"
echo "Decoded claims:"
echo $IDTOKEN | cut -d '.' -f2 | base64 -d 2>/dev/null | jq
```

2. **Permission Denied on CI/CD deploy**

   * Ensure CI/CD SA has:

     * `roles/iam.serviceAccountUser`
     * `roles/run.developer`
     * `roles/artifactregistry.writer`

3. **Terraform pipeline errors**

   * Often caused by **incorrect attribute references** or **YAML syntax errors**.
   * Inspect the **pipeline logs** for details.

4. **Cloud Run Upload Errors**

   * Make sure the **Cloud Run runtime SA** has `roles/storage.objectCreator` for the assets bucket.

5. **CORS issues**

   * If uploading from a browser, enable CORS in Express:

```js
import cors from "cors";
app.use(cors());
```

---
