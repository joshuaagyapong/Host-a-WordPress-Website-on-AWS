# Hosting a WordPress Website on AWS

Deploy a highly available WordPress application on AWS using a multi-tier, production-style architecture.

---

## Project Overview

This project demonstrates how to host WordPress on AWS with:

- High availability across multiple Availability Zones
- Secure network isolation using public and private subnets
- Auto Scaling for resilience
- Managed database and shared file storage
- Application Load Balancer for traffic distribution

---

## Architecture

### AWS Services Used

- Amazon VPC
- Internet Gateway
- NAT Gateway
- Application Load Balancer (ALB)
- EC2 (Auto Scaling Group)
- Launch Template
- Amazon RDS (MySQL)
- Amazon EFS
- EC2 Instance Connect Endpoint
- AWS Certificate Manager (ACM)
- Amazon SNS
- Amazon Route 53 (optional)

---

### Network Design

- **VPC:** Single VPC spanning two Availability Zones
- **Public Subnets:**
  - Application Load Balancer
  - NAT Gateway
- **Private Application Subnets:**
  - WordPress EC2 instances (Auto Scaling Group)
- **Private Data Subnets:**
  - Amazon RDS

---

### Traffic Flow

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

- Load Balancer is the **only public entry point**
- EC2 instances have **no public IPs**
- RDS is isolated in private subnets
- Security Groups enforce **tier-to-tier access**
- SSH access restricted using **EC2 Instance Connect Endpoint**
- No direct database or filesystem access from the internet

---

## Deployment Scripts

### WordPress Installation Script

Used for initial setup and validation.

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




---

## Deployment Scripts

### Auto Scaling User Data Script
 

-Used to configure all instances launched by the Auto Scaling Group

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

---

- Validation and Testing

Access application via ALB DNS name

Verify ALB health checks pass

Terminate EC2 instances to confirm Auto Scaling

Confirm WordPress files persist across instances using EFS

Confirm database access is restricted to application tier

Key Design Decisions

WordPress EC2 instances are stateless

Shared content stored in Amazon EFS

Database isolated in private subnets

Health check success codes adjusted for WordPress redirects

Custom domain intentionally optional



