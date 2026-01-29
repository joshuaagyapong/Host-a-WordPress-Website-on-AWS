# Hosting a WordPress Website on AWS

Deploy a highly available, secure, and scalable WordPress application on AWS using a production-style multi-tier architecture.

![Architecture Diagram](Host_a_WordPress_Website_on_AWS.png)

---

## Project Summary

This project demonstrates how WordPress is deployed in a real-world AWS environment with a focus on availability, security, and scalability.  
The architecture follows common enterprise design patterns rather than a single-server setup.

---

## Architecture Overview

The solution uses a three-tier architecture:

- **Presentation Tier** – Handles incoming user traffic
- **Application Tier** – Runs WordPress on scalable compute
- **Data Tier** – Stores persistent data and shared files

Each tier is isolated using private networking and controlled access.

---

## AWS Services Used (and Why)

- **Amazon VPC** – Network isolation and routing control
- **Public & Private Subnets** – Separate internet-facing and internal resources
- **Internet Gateway** – Allows inbound traffic to the load balancer
- **NAT Gateway** – Enables private instances to access the internet securely
- **Application Load Balancer (ALB)** – Distributes traffic and performs health checks
- **Auto Scaling Group (ASG)** – Maintains availability and replaces unhealthy instances
- **Launch Template** – Ensures consistent EC2 configuration
- **Amazon EC2** – Runs the WordPress application
- **Amazon RDS (MySQL)** – Managed relational database for WordPress
- **Amazon EFS** – Shared file storage across multiple EC2 instances
- **EC2 Instance Connect Endpoint** – Secure administrative access without public SSH
- **AWS Certificate Manager (ACM)** – SSL/TLS certificate management
- **Amazon SNS** – Auto Scaling notifications
- **Amazon Route 53 (Optional)** – DNS and domain management

---

## Network Design

- **VPC:** Spans two Availability Zones
- **Public Subnets:**
  - Application Load Balancer
  - NAT Gateway
- **Private Application Subnets:**
  - WordPress EC2 instances (Auto Scaling Group)
- **Private Data Subnets:**
  - Amazon RDS
  - Amazon EFS mount targets

---

## Traffic Flow


Internet
↓
Application Load Balancer (Public Subnets)
↓
WordPress EC2 Instances (Private App Subnets)
↓
Amazon RDS (Database)
↓
Amazon EFS (Shared File Storage)



---

## Security Design

- The Application Load Balancer is the **only public entry point**
- EC2 instances have **no public IP addresses**
- Database and file storage are isolated in private subnets
- Security Groups enforce **least-privilege, tier-to-tier access**
- Administrative access is handled through **EC2 Instance Connect Endpoint**
- No direct internet access to application or data tiers

---

## Deployment Scripts

### WordPress Installation Script (Initial Setup)

## Script 1 — Manual WordPress Installation (One-Time Setup)

> ⚠️ **DO NOT use this script in Auto Scaling or Launch Templates**
>
> This script is used only for:
> - Initial WordPress setup
> - Manual validation
> - Troubleshooting on a single EC2 instance

---

### Purpose
- Mount Amazon EFS manually
- Install WordPress files
- Validate Apache and PHP configuration
- Confirm file permissions

---

### Manual Installation Script

```bash
sudo su
sudo yum update -y
sudo mkdir -p /var/www/html

EFS_DNS_NAME=fs-064e9505819af10a4.efs.us-east-1.amazonaws.com

sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport \
"$EFS_DNS_NAME":/ /var/www/html

sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd

sudo dnf install -y \
php php-cli php-cgi php-curl php-mbstring php-gd php-mysqlnd \
php-gettext php-json php-xml php-fpm php-intl php-zip php-bcmath \
php-ctype php-fileinfo php-openssl php-pdo php-tokenizer

wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/

sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

sudo systemctl restart httpd


## Script 2 — Auto Scaling Group User Data Script (Production)
✅ THIS is the only script used by the Auto Scaling Group

This script is attached to the Launch Template and runs automatically
whenever a new EC2 instance is launched.

Purpose
Bootstrap EC2 instances automatically

Install Apache and PHP dependencies

Mount Amazon EFS on launch

Ensure stateless, repeatable configuration

User Data Script (Launch Template)
#!/bin/bash

sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd

sudo dnf install -y \
php php-cli php-cgi php-curl php-mbstring php-gd php-mysqlnd \
php-gettext php-json php-xml php-fpm php-intl php-zip php-bcmath \
php-ctype php-fileinfo php-openssl php-pdo php-tokenizer

EFS_DNS_NAME=fs-02d3268559aa2a318.efs.us-east-1.amazonaws.com

echo "$EFS_DNS_NAME:/ /var/www/html nfs4 defaults,_netdev 0 0" >> /etc/fstab
mount -a

sudo chown -R apache:apache /var/www/html
sudo systemctl restart httpd


## Validation and Testing

---

### Application Validation
- Application accessed successfully via the Application Load Balancer DNS name  
- Load balancer health checks configured and stable  

---

### Resilience Validation
- EC2 instances terminated manually  
- Auto Scaling replaced instances automatically  
- Application remained accessible during replacement  

---

### Persistence Validation
- WordPress files persisted across instance replacements using Amazon EFS  
- Database access restricted to the application tier only  

---

## Key Design Decisions

---

- **Stateless compute layer**  
  EC2 instances are disposable and replaced automatically by Auto Scaling.

- **Shared file storage**  
  WordPress files stored in Amazon EFS to support horizontal scaling.

- **Isolated database tier**  
  Database deployed in private subnets with no public access.

- **Health check tuning**  
  Load balancer health checks adjusted to handle WordPress redirects.

- **Optional domain configuration**  
  Custom domain intentionally optional to focus on infrastructure
