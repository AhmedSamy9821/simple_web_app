# System Architecture

## Architecture Overview

The system is a simple, container-based web application deployed on **Google Cloud Run**, fronted by an **HTTP Load Balancer**, and integrated with **Cloud Storage** for asset uploads and **logging sinks**. Monitoring and alerting are managed via **Cloud Monitoring**. A **VPC** is provisioned for future integration with Cloud SQL or other private services.

CI/CD pipelines are implemented using **GitHub Actions** and **Terraform**, with **Workload Identity Federation (WIF)** for secure authentication without long-lived service account keys.

Cloud Run and the HTTP Load Balancer scale automatically based on demand, minimizing operational overhead for capacity planning.

### High-Level Design

```text
                                ┌───────────────┐ 
                                │    Users      │ 
                                │ (Web / Mobile)│ 
                                └───────┬───────┘ 
                                        │ HTTP Requests 
                                        ▼ 
                        ┌───────────────────────────────┐ 
                        │ Google Cloud Load Balancer    │ 
                        │   (Global HTTP LB)            │ 
                        └─────────────┬─────────────────┘ 
                                      │ Routes Traffic 
                                      ▼ 
                        ┌───────────────────────────────┐ 
                        │ Cloud Run Service             │ 
                        │ "simple-web-app"              │ 
                        │ (Stateless, Auto-Scaling)     │ 
                        │ Blue-Green Deployment         │ 
                        │ (100% traffic to new revision)│ 
                        └─────────────┬─────────────────┘ 
                                      │ 
        ┌─────────────────────────────┼─────────────────────────────┐ 
        │                             │                             │ 
        ▼                             ▼                             ▼ 
┌───────────────┐             ┌─────────────────┐            ┌───────────────────┐ 
│ Cloud Storage │             │ Cloud Logging   │            │ Cloud Monitoring	 │ 
│   "assets"    │             │ Sink → Bucket   │            │ Custom Dashboards │ 
│(Uploaded Files)│            │ "logging"       │            │ & Metrics         │ 
└───────────────┘             └─────────────────┘            └─────────┬─────────┘ 
                                                                       │ 
                                                                       ▼ 
                                                           ┌────────────────┐ 
                                                           │ Alert Policies │ 
                                                           │  (Email Notifs)│ 
                                                           └────────────────┘ 
```

---

### Infrastructure Management Layer

```text
  ┌─────────────────────────────────────────────────────────────┐ 
  │ GitHub Actions - Infra Pipeline                               │ 
  │ (Provision / Manage GCP Infrastructure via Terraform)        │ 
  └─────────────┬───────────────────────────────────────────────┘ 
                │ Step 1: Authenticate via Workload Identity Federation 
                │ Step 2: Terraform applies infrastructure config 
                │ Step 3: Provision: 
                │       - Cloud Run Service 
                │       - Cloud Storage Buckets (assets, logging) 
                │       - Logging Sink 
                │       - Monitoring Dashboards & Alerts 
                │       - VPC + Subnet (future Cloud SQL connectivity) 
                ▼ 
  ┌─────────────────────────────────────────────────────────────┐ 
  │ Terraform Service Account (Least Privilege)                 │ 
  │ - Only permissions required for provisioning infra          │ 
  │ - Ensures secure and auditable infra changes                │ 
  └─────────────────────────────────────────────────────────────┘ 
```

---

### CI/CD Management Layer

```text
  ┌─────────────────────────────────────────────────────────────┐ 
  │ GitHub Actions - CI/CD Pipeline                               │ 
  │ (Build & Deploy App)                                         │ 
  └─────────────┬───────────────────────────────────────────────┘ 
                │ Step 1: Authenticate via Workload Identity Federation 
                │ Step 2: Build Docker Image of App 
                │ Step 3: Push Image to Artifact Registry ("simple-web-app") 
                │ Step 4: Deploy new revision to Cloud Run 
                │ Step 5: Switch 100% of traffic to new revision (Blue-Green) 
                │ Step 6: Keep old revision available for rollback 
                ▼ 
  ┌─────────────────────────────────────────────────────────────┐ 
  │ CI/CD Service Account (Least Privilege)                     │ 
  │ - Build & push images                                       │ 
  │ - Update Cloud Run revision with Blue-Green switch          │ 
  └─────────────────────────────────────────────────────────────┘ 
```

---

### Notes

- **Security:** Both pipelines use Workload Identity Federation with least-privilege service accounts.  
- **Scalability:** Cloud Run and Cloud Storage scale automatically.  
- **Reliability:** Blue-Green deployment strategy ensures safe rollbacks.  
- **Future Expansion:** VPC + Subnet provisioned for potential secure connection to Cloud SQL.

## Component Descriptions

* **HTTP Load Balancer** → Provides a global, managed entry point for users, distributes traffic to Cloud Run. Scales automatically based on traffic demand.
* **Cloud Run Service** → Runs the containerized application. Handles three endpoints:

  * `/` → Returns “Hello World” with timestamp.
  * `/health` → Returns JSON health status.
  * `/upload` → Accepts file uploads and stores directly into Cloud Storage.
* **Cloud Storage** →

  * **Assets Bucket (STANDARD)** → Frequently accessed bucket for uploads. Scales automatically with usage.
  * **Logging Bucket (NEARLINE)** → Rarely accessed bucket for audit/compliance logs.
* **Logging Sink** → Exports Cloud Run logs into the logging bucket.
* **Cloud Monitoring Dashboard** → Displays metrics for latency, request volume, error rates, CPU/memory usage.
* **Alerting Policies** → Configured to send alerts via **email** on latency, error rates, CPU/memory utilization, and max instances usage.
* **VPC** → Configured for future use with a Serverless VPC Connector, enabling secure access to Cloud SQL or other internal resources.

## Design Decisions

* **Containerized Application (Cloud Run)** → Chosen for simplicity, autoscaling, high availability, and serverless model. **Autoscaling minimizes operational overhead**.

* **CI/CD Integration (GitHub Actions + OIDC)** →

  * Integration with GitHub, using OIDC for authentication with clear documentation.
  * Workflows can request short-lived OIDC tokens instead of storing long-lived secrets.

* **Workload Identity Federation (WIF) for Terraform)** →

  * Used instead of service account keys to access Google Cloud resources directly.
  * **Reasons & Benefits:**

    1. **Security**: Service account keys are powerful credentials and can present a security risk. WIF provides short-lived OIDC tokens.
    2. **Granular authN/authZ**: Use cloud provider authentication and authorization tools to control workflow access.
    3. **Rotating credentials**: Tokens expire automatically after a single job.
    4. **Restricted pool**: You can restrict the WIF pool to a single workflow for better security.

* **Terraform State Storage (Cloud Storage)** → Centralized, regional for cost optimization, with versioning enabled to ensure safe collaborative infrastructure management.

* **Region Selection** → All resources are in the same region for fast connectivity and better performance.

* **Cloud Storage Buckets** →

  * **Assets (STANDARD)** → Frequently accessed bucket for uploads.
  * **Logging (NEARLINE)** → Rarely accessed bucket for audit/compliance logs.

* **Cloud Run Settings** →

  * **Min instances**: 0 on Dev/Test to reduce cost; 1 on Prod/Stage to prevent cold start.
  * **Lifecycle block**: Ignore changes on image and traffic to control updates via CI/CD pipelines.
  * **Deployment strategy**: Blue-green deployment ensures **zero downtime**. Rolling updates are also possible using traffic splitting (start with 10% to the new revision, monitor metrics/logs, then gradually increase).

## Security Considerations

* **IAM Principles** → Strict least-privilege policies applied.

  * **Terraform Pipeline Service Account** → `roles/editor`, `roles/run.admin` for infrastructure management.
  * **CI/CD Service Account** → `roles/artifactregistry.writer`, `roles/run.developer`, `roles/iam.serviceAccountUser`, `roles/logging.configWriter`.
  * **Cloud Run Execution Service Account** → `roles/storage.objectCreator` on assets bucket only.

* **Workload Identity Federation (WIF)** → Used for pipelines, restricted per workflow with attribute conditions to enhance security. **WIF removes the need for long-lived credentials**, improving security.

* **Secrets Management** → Sensitive values are stored in **GitHub Actions secrets**, ensuring secure access during CI/CD workflows.

## Monitoring & Alerting

* **Dashboard** → Unified Cloud Monitoring dashboard with charts for latency (P50, P90, P99), request counts, error rates, CPU/memory usage.
* **Alerts** →

  * **Latency High** → Trigger at 99th percentile > 500ms for 5 minutes.
  * **Error Rate High** → Trigger if 5xx > 5% of requests for 5 minutes.
  * **CPU Utilization** → Alert if > 80% for 10 minutes.
  * **Memory Utilization** → Alert if > 80% for 10 minutes.
  * **Instance Scaling** → Alert if active instances ≥ 75% of max configured.
* **Notification Channel** → Email.

## Scalability

* **Cloud Run** → Autoscaling between min and max instances per environment to handle varying traffic.
* **Cloud Storage** → Fully managed and scales automatically with object count and size.
* **HTTP Load Balancer** → Scales globally to accommodate incoming traffic without manual intervention.
* **Future-proofing** → VPC/Subnet + Serverless VPC Connector allow future connection to private services, ensuring scalability for additional resources or services.

## Cost Estimation

Costs depend on usage and environment. Approximate monthly costs are calculated based on assumed traffic per environment.

**Traffic and usage assumptions:**

* **Dev** → Low traffic: 1,000 requests/day, 1GB asset uploads, min instances 0
* **UAT** → Medium traffic: 5,000 requests/day, 2GB asset uploads, min instances 0
* **Prod** → High traffic: 50,000 requests/day, 20GB asset uploads, min instances 1
* **Stage** → Medium traffic: 10,000 requests/day, 5GB asset uploads, min instances 1
* Avg. response size = 100KB
* Logs ~5% of request data

**Estimated monthly costs per environment:**

| Environment | Cloud Run | Load Balancer | Cloud Storage (Assets) | Cloud Storage (Logs) | Monitoring/Logging | **Total**  |
| ----------- | --------- | ------------- | ---------------------- | -------------------- | ------------------ | ---------- |
| Dev         | $2        | $5            | $0.10                  | $0.05                | $1                 | **$8.15**  |
| UAT         | $10       | $10           | $0.20                  | $0.10                | $3                 | **$23.30** |
| Prod        | $50       | $18           | $4                     | $0.50                | $10                | **$82.50** |
| Stage       | $20       | $10           | $1                     | $0.20                | $5                 | **$36.20** |

**Grand Total (All Environments)** → **$150.15 / month**

**Note:** Actual costs may vary based on egress, additional storage, or higher request volume.

## Improvements / Future Enhancements

1. Implement a **custom domain** with managed SSL for the application.
2. Create **separate WIF pools per environment** to enforce stricter access control.
3. Use **isolated projects for Prod and Stage** to improve security and resource separation.
4. Configure **dedicated branches & pipelines per environment**, with automated testing for feature branches.
