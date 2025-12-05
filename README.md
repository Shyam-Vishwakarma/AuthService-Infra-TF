# SV-DevOps-TF-AWS

### Overview

This project provisions AWS infrastructure including:
- VPC with public and private subnets
- EC2 instances
- RDS database
- Application Load Balancer
- Security groups and networking

### Prerequisites

- Required Tools
- Terraform >= 1.0.0
- Ansible >= 2.0
- Python >= 3.8 (for Ansible)
- Docker desktop configured for windows container and linux container
- Jenkins installed and pipeline configured with aws credentials, plugins

For Ansible to manage Windows hosts:
```
pip install pywinrm
```

### Terraform Setup

- Initialize Terraform

```
cd terraform/environments/dev
terraform init
```

- Plan

```
terraform plan
```

- Apply

```
terraform apply
```

### Ansible Setup

- Test Connectivity with instance

Verify Ansible can connect to the Windows host:

```
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

- Update Playbook Variables

Edit `ansible/playbook.yaml` to customize your application deployment:

- Run Playbooks

Execute the main playbook:

```
ansible-playbook -i inventory.ini playbook.yaml
```

- Run ansible with docker

- Build docker file

```
docker build -t ansible:latest .
```

- Run container
```
docker run --rm -e AWS_ACCESS_KEY_ID=<aws access key id> -e AWS_SECRET_ACCESS_KEY=<aws secret access key> -e AWS_DEFAULT_REGION=<aws region> ansible:latest
```

### Setup Jenkins

- Install jenkins: `https://www.jenkins.io/doc/book/installing/windows/` 
- Plugins needed for pipeline:
    Docker plugin
    Git
    AWS Credentials Plugin
    Pipeline: AWS Steps Plugin

### Diagram

![alt text](<Screenshot 2025-12-05 155719.png>)
