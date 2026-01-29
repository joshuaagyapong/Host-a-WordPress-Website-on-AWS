# Hosting a WordPress Website on AWS

Deploy a highly available, secure, and scalable WordPress application on AWS using a production-style, multi-tier architecture.

![Architecture Diagram](Host_a_WordPress_Website_on_AWS.png)

---

## Project Summary

This project demonstrates a real-world WordPress deployment on AWS with a focus on availability, security, scalability, and operational correctness.

The architecture follows enterprise cloud design patterns rather than a single-server setup.

---

## Architecture Overview

The solution uses a three-tier architecture:

- **Edge / Presentation Layer**  
  Application Load Balancer handling incoming traffic.

- **Application Layer**  
  WordPress running on EC2 instances managed by an Auto Scaling Group.

- **Data & Persistence Layer**  
  Amazon RDS for relational data and Amazon EFS for shared WordPress files.

Each tier is isolated using private networking and controlled access.

---

## AWS Services Used (and Why)

- **Amazon VPC** – Network isolation and routing control  
- **Public & Private Subnets** – Separation of internet-facing and internal resources  
- **Internet Gateway** – Enables inbound access to the load balancer  
- **NAT Gateway** – Allows private instances outbound internet access securely  
- **Application Load Balancer (ALB)** – Traffic distribution and health checks  
- **Auto Scaling Group (ASG)** – Self-healing and high availability  
- **Launch Template** – Consistent EC2 configuration  
- **Amazon EC2** – Runs the WordPress application  
- **Amazon RDS (MySQL)** – Managed relational database  
- **Amazon EFS** – Shared file storage across instances  
- **EC2 Instance Connect Endpoint** – Secure administrative access  
- **AWS Certificate Manager (ACM)** – SSL/TLS management  
- **Amazon SNS** – Auto Scaling notifications  
- **Amazon Route 53 (Optional)** – DNS and domain management  

---

## Network Design

- **VPC:** Spans two Availability Zones  
- **Public Subnets:**  
  - Application Load Balancer  
  - NAT Gateways  
- **Private Application Subnets:**  
  - WordPress EC2 instances (Auto Scaling Group)  
- **Private Data Subnets:**  
  - Amazon RDS  
  - Amazon EFS mount targets  

---

## Traffic Flow

Internet
↓
Application Load Balancer
↓
EC2 Auto Scaling Group
↓
Amazon RDS / Amazon EFS


---

## Security Design

- Application Load Balancer is the only public entry point  
- EC2 instances have no public IP addresses  
- Database and file storage are isolated in private subnets  
- Security Groups enforce least-privilege, tier-to-tier access  
- Administrative access via EC2 Instance Connect Endpoint  
- No direct internet access to application or data tiers  

---

## Deployment Scripts

---

## Script 1 — Manual WordPress Installation (One-Time Setup)

> ⚠️ **DO NOT use this script in Auto Scaling or Launch Templates**  
> Used only for manual setup, validation, and troubleshooting.

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
Script 2 — Auto Scaling Group User Data Script (Production)
✅ This is the ONLY script used by Auto Scaling
Attached to the Launch Template and executed automatically on instance launch.

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
Validation and Testing
Application Validation
Application accessed via the Application Load Balancer DNS name

Load balancer health checks configured and stable

Resilience Validation
EC2 instances terminated manually

Auto Scaling replaced instances automatically

Application remained accessible

Persistence Validation
WordPress files persisted across instance replacements using Amazon EFS

Database access restricted to the application tier only

Key Design Decisions
Stateless EC2 compute layer

Shared file storage using Amazon EFS

Database isolated in private subnets

ALB health checks tuned to accept HTTP success codes 200–399

Custom domain intentionally optional to focus on infrastructure design

What This Project Demonstrates
Production-grade AWS architecture

Secure network and tier isolation

Correct Auto Scaling behavior

Real-world ALB health check troubleshooting

Clear, intentional architectural decision-making
