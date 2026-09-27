# Django E-Commerce API DevOps Pipeline

A production-grade deployment pipeline and infrastructure setup for a modular Django REST API e-commerce platform. The project emphasizes automated CI/CD, immutable container deployments via Git SHA image tags, container orchestration with healthchecks, and infrastructure provisioned through Terraform on AWS EC2.

---

## Technology Stack

### Application Layer
- **Django**: Core web framework.
- **Django REST Framework (DRF)**: Scalable RESTful API development.
- **PostgreSQL**: Production relational database for transactional consistency.
- **Redis**: In-memory message broker and caching layer.
- **Celery**: Distributed task queue for asynchronous job execution (emails, order processing, background webhooks).

### DevOps & Infrastructure Layer
- **Linux (Ubuntu)**: Base host operating system.
- **Docker**: Application containerization.
- **Docker Compose**: Multi-container service definition, healthcheck orchestration, and networking.
- **Nginx**: Reverse proxy handling client ingress, TLS termination, and static asset delivery.
- **Gunicorn**: WSGI HTTP production application server.
- **Terraform**: Infrastructure as Code (IaC) provisioning AWS cloud resources.
- **AWS EC2**: Virtual cloud compute host.
- **GitHub Actions**: Automated continuous integration and continuous deployment (CI/CD) pipelines.
- **Docker Hub**: Container registry storing immutable SHA-tagged artifacts.

---

## CI/CD Architecture & Workflow

Every deployment is immutable and automated through GitHub Actions upon pushing changes to the `main` branch.

```text
Developer pushes to main
        ↓
GitHub Actions starts
        ↓
Docker images are built
        ↓
Images tagged with Git SHA
        ↓
Images pushed to Docker Hub
        ↓
GitHub Actions connects to EC2
        ↓
EC2 pulls exact image version
        ↓
Docker Compose recreates services
        ↓
Application becomes available
```

### Why Git SHA Tagging Matters
Instead of relying on mutable tags such as `:latest`, every build outputs images tagged directly with the corresponding Git commit SHA (e.g., `web:a1b2c3d`). This guarantees:
1. **Traceability**: An exact 1-to-1 match between the running container artifact and source code commit.
2. **Determinism**: EC2 always pulls the exact immutable image target without caching ambiguities.
3. **Instant Rollback**: Immediate zero-build rollbacks by targeting any previously verified SHA.

---

## Deployment & Verification Commands

### Manual Service Deployment

Deploy the stack on the remote EC2 instance using the production configuration:

```bash
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
```

### Container Status Verification

Verify that all service healthchecks pass and containers are in a running state:

```bash
docker compose -f docker-compose.prod.yml ps
```

### Real-time Service Logs

Tail application logs:
```bash
docker compose -f docker-compose.prod.yml logs -f web
```

Tail reverse proxy logs:
```bash
docker compose -f docker-compose.prod.yml logs -f nginx
```

Tail background worker logs:
```bash
docker compose -f docker-compose.prod.yml logs -f celery
```

---

## Rollback Procedure

Docker images are tagged using the Git commit SHA, allowing deployments to reference a specific application version and roll back to a previously known-good release without rebuilding:

1. Identify the target Git commit SHA of the last stable build.
2. Export the version variable on the host:
   ```bash
   export IMAGE_TAG=<previous-git-sha>
   ```
3. Pull the specific historical artifacts and restart the services:
   ```bash
   docker compose -f docker-compose.prod.yml pull
   docker compose -f docker-compose.prod.yml up -d
   ```

---

## Troubleshooting & Resolutions

Practical issues encountered and resolved during pipeline implementation:

### 1. PostgreSQL Unavailable / Startup Race Conditions
* **Issue**:
  ```text
  nc: getaddrinfo for host "db"
  ```
  Web containers started before PostgreSQL was completely initialized and accepting connections.
* **Resolution**:
  Configured Docker Compose service DNS networking alongside rigorous service healthchecks (`pg_isready`) and coupled dependent services using:
  ```yaml
  depends_on:
    db:
      condition: service_healthy
  ```

### 2. Django DisallowedHost
* **Issue**:
  ```text
  Invalid HTTP_HOST header: 'ec2-xx-xxx-xxx-xx.compute.amazonaws.com'. You may need to add this to ALLOWED_HOSTS.
  ```
* **Resolution**:
  Exposed `ALLOWED_HOSTS` dynamically through environment variables in `docker-compose.prod.yml`, ensuring instance public IPs and custom domain names are read at container startup.

### 3. Missing Required Environment Variables
* **Issue**:
  ```text
  KeyError: 'STRIPE_WEBHOOK_SECRET not found'
  ```
* **Resolution**:
  Established a verified production `.env` template on the EC2 host containing all required third-party API credentials, webhook secrets, and database connection strings before container execution.

### 4. Docker Hub Image Pull / Build Failures
* **Issue**:
  Authentication drops or failed image pulls on remote EC2 runner during deployment steps.
* **Resolution**:
  Configured secure `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets in GitHub Actions and validated image tags against Docker Hub registry before triggering the remote SSH rollout.

---

## Project Structure

```text
django-ecommerce-api-devops/
│
├── config/                  # Django project root settings and routing
├── orders/                  # Order management application
├── payment/                 # Payment processing & webhook integrations
├── products/                # Product catalog & inventory APIs
├── users/                   # Authentication & user profile endpoints
│
├── nginx/
│   ├── Dockerfile           # Custom Nginx container build
│   └── nginx.conf           # Reverse proxy, caching, and upstream routing
│
├── terraform/
│   ├── main.tf              # AWS provider, VPC, security groups, & EC2 instances
│   ├── variables.tf         # Input variable definitions
│   ├── outputs.tf           # Provisioned infrastructure outputs (IPs, DNS)
│   └── user_data.sh         # EC2 bootstrap script (Docker & Compose setup)
│
├── .github/
│   └── workflows/
│       └── deploy.yml       # GitHub Actions CI/CD automation pipeline
│
├── Dockerfile               # Production multi-stage Django application image
├── docker-compose.yml       # Local development orchestration
├── docker-compose.prod.yml  # Production deployment stack with healthchecks
├── entrypoint.sh            # Container init script (migrations, collectstatic)
├── requirements.txt         # Pinned Python package dependencies
└── README.md                # Project documentation
```