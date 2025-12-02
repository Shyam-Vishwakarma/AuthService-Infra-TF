# SV-DevOps-TF-AWS

## Overview

This project provisions AWS infrastructure including:
- VPC with public and private subnets
- EC2 instances
- RDS database
- Application Load Balancer
- Security groups and networking

## Prerequisites

### Required Tools
- **Terraform** >= 1.0.0
- **Ansible** >= 2.9
- **AWS CLI** configured with appropriate credentials
- **Python** >= 3.8 (for Ansible)
- **pywinrm** (for Windows remote management)

- AWS account with appropriate permissions
- S3 bucket for Terraform state (configured in backend.tf)
- AWS credentials configured (`aws configure`)

For Ansible to manage Windows hosts:
```bash
pip install pywinrm
```

## Terraform Setup

### 1. Configure Backend (if required)

Update the S3 backend configuration in `terraform/environments/dev/backend.tf`:


### 3. Initialize Terraform

```bash
cd terraform/environments/dev
terraform init
```

### 4. Plan

```bash
terraform plan
```

### 5. Apply

```bash
terraform apply
```

### 6. Get Outputs

```bash
terraform output
```

This will output important information like EC2 instance IPs, RDS endpoints, and ALB DNS names.

## 🔧 Ansible Setup

### 1. Configure Inventory

Update `ansible/inventory.ini` with the EC2 instance IP from Terraform output:

```ini
[servers]
<server-ip>

[servers:vars]
ansible_port=5985
ansible_user=Administrator
ansible_password=<your-windows-admin-password>
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore
```

### 2. Test Connectivity

Verify Ansible can connect to the Windows host:

```bash
cd ansible
ansible servers -i inventory.ini -m win_ping
```

Expected output:
```
<server-ip> | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### 4. Update Playbook Variables

Edit `ansible/playbook.yaml` to customize your application deployment:

### 5. Run Playbooks

Execute the main playbook:

```bash
ansible-playbook -i inventory.ini playbook.yaml
```
