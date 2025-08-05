# 🔐 IAM Policy Generator

This project is a cloud-native web application that allows users to generate AWS IAM policies in natural language using the OpenAI API. It features a full-stack, multi-tier architecture with a FastAPI backend hosted in a private VPC, an RDS database for storing prompt history, and a secure, scalable frontend hosted with AWS Amplify.

---

## 🌐 Video Demo

Video demo to be added

---

## 🧩 Overview

The IAM Policy Generator translates user-provided descriptions (e.g., “Allow full S3 access for logs bucket”) into valid AWS IAM policies using OpenAI's API. It also stores prompt history if users are logged in with their Google account, and allows users to revisit past queries via a scrollable UI.

---

## 🏗️ Architecture

Architecture diagram to be added

**Key AWS Components:**
- **Amplify** – Hosts the frontend
- **ACM + Route 53** – SSL + domain management
- **Application Load Balancer (ALB)** – Routes HTTPS traffic to the backend
- **EC2 (FastAPI)** – Backend API hosted in a private subnet
- **RDS (PostgreSQL)** – Stores user prompt history securely
- **Secrets Manager** – Manages OpenAI API keys without using env files
- **Terraform** – Infrastructure-as-code for full reproducibility

---

## 🚀 Features

- 🌐 Natural language to IAM policy generation (via OpenAI)
- 📜 Syntax-highlighted JSON viewer
- 🧠 History panel for past prompts (persisted in RDS)
- 🔒 End-to-end encryption with HTTPS
- 🧩 Modular architecture (frontend, backend, database)
- 🧰 Fully built and managed using Terraform
- 📄 ALB + private EC2 for backend security

---

## 🧰 Tech Stack

| Layer        | Tech/Service                         |
|--------------|--------------------------------------|
| Frontend     | HTML, CSS, JavaScript                |
| Backend      | FastAPI, Python                      |
| AI API       | OpenAI (GPT-4)                       |
| Infrastructure | Terraform                          |
| Hosting      | AWS Amplify (frontend), EC2 (backend)|
| Database     | Amazon RDS (PostgreSQL)              |
| Networking   | VPC, Private/Public Subnets, ALB     |
| Secrets Mgmt | AWS Secrets Manager                  |
| CI/CD        | GitHub Actions                       |

---

## 🔐 Security Highlights

- **No environment variables stored in code** – all secrets (e.g., OpenAI API key, DB credentials) are stored in **AWS Secrets Manager**.
- **Private subnet for EC2 backend** – inaccessible from the internet.
- **Application Load Balancer** – terminates HTTPS traffic securely and forwards requests to the backend.
- **Least privilege IAM policies** – tightly scoped permissions for Terraform and GitHub Actions.
- **HTTPS everywhere** – using an ACM-provided certificate and Route 53 for domain management.

---

## 🔄 CI/CD Workflow

### Frontend – Amplify
- Triggered on pushes to the `main` branch
- Amplify rebuilds and redeploys the static frontend
- Route 53 + ACM ensure domain and HTTPS remain stable

### Backend – Terraform + GitHub Actions
- GitHub Actions deploys infrastructure changes using Terraform
- Secrets and config parameters are pulled dynamically from Terraform outputs and Secrets Manager
- Changes to backend code are deployed to EC2 instances via SSH or future pipeline improvements (e.g., CodeDeploy)

---

