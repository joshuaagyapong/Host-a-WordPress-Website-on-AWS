# Host-a-WordPress-Website-on-AWS
Host a WordPress Website on AWS using the management console

# Hosting a WordPress Website on AWS

This project demonstrates how to deploy a **highly available, secure, and scalable WordPress application** on Amazon Web Services (AWS).  
The focus is on **production-style infrastructure**, not just running WordPress on a single server.

---

## Project Goals

- Deploy WordPress using a **multi-tier AWS architecture**
- Enforce **network isolation and least-privilege access**
- Enable **high availability and scaling** with Auto Scaling
- Separate **compute, database, and shared storage**
- Validate application behavior behind an Application Load Balancer

---

## Architecture Overview

The architecture is designed using common enterprise patterns.

### Network Layer
- One **VPC** spanning two Availability Zones
- **Public Subnets**
  - Application Load Balancer
  - NAT Gateway
- **Private Application Subnets**
  - WordPress EC2 instances (Auto Scaling Group)
- **Private Data Subnets**
  - Amazon RDS database
- **Internet Gateway** for inbound public traffic
- **NAT Gateway** for controlled outbound access from private instances

### Security Layer
- Security Groups used for **tier-to-tier trust**
- Load Balancer is the **only public entry point**
- Application servers are **not publicly accessible**
- Database is **never public**
- SSH access restricted using **EC2 Instance Connect Endpoint**

### Compute Layer
- EC2 instances running WordPress
- **Launch Template** defining instance configuration
- **Auto Scaling Group** for fault tolerance and scaling
- **Application Load Balancer** distributing traffic

### Data and Storage Layer
- **Amazon RDS (MySQL)** for persistent relational data
- **Amazon EFS** for shared WordPress files across instances
- Separation of:
  - Stateless compute
  - Persistent database storage
  - Shared file storage

### Supporting Services
- **AWS Certificate Manager (ACM)** for SSL/TLS
- **Amazon SNS** for Auto Scaling notifications
- **Amazon Route 53** (optional) for DNS management

---

## Architecture Flow

Internet
|
v
Application Load Balancer (Public Subnets)
|
v
WordPress EC2 Instances (Private App Subnets - Auto Scaling Group)
| |
v v
Amazon RDS Amazon EFS
(Private Data Subnets)


---

## Deployment Scripts

### WordPress Installation Script (Initial Setup)

Used for initial configuration and validation.  
Installs required packages, mounts Amazon EFS, and prepares WordPress files.

```bash
# switch to root user
sudo su

# update the software packages on the EC2 instance
sudo yum update -y

# create the web root directory
sudo mkdir -p /var/www/html

# environment variable for EFS
EFS_DNS_NAME=fs-064e9505819af10a4.efs.us-east-1.amazonaws.com

# mount the EFS to the web root
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport \
"$EFS_DNS_NAME":/ /var/www/html

# install Apache
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd

# install PHP and required extensions
sudo dnf install -y \
php php-cli php-cgi php-curl php-mbstring php-gd php-mysqlnd \
php-gettext php-json php-xml php-fpm php-intl php-zip php-bcmath \
php-ctype php-fileinfo php-openssl php-pdo php-tokenizer

# download and extract WordPress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/

# configure WordPress
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# set permissions
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

# restart Apache
sudo systemctl restart httpd
Auto Scaling Group Launch Template Script
Embedded in the Launch Template to ensure every new instance is configured identically.

#!/bin/bash

# update system
sudo yum update -y

# install Apache
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd

# install PHP and extensions
sudo dnf install -y \
php php-cli php-cgi php-curl php-mbstring php-gd php-mysqlnd \
php-gettext php-json php-xml php-fpm php-intl php-zip php-bcmath \
php-ctype php-fileinfo php-openssl php-pdo php-tokenizer

# EFS DNS name
EFS_DNS_NAME=fs-02d3268559aa2a318.efs.us-east-1.amazonaws.com

# persist EFS mount
echo "$EFS_DNS_NAME:/ /var/www/html nfs4 defaults,_netdev 0 0" >> /etc/fstab
mount -a

# set permissions
sudo chown -R apache:apache /var/www/html

# restart Apache
sudo systemctl restart httpd
How the System Is Tested
Application accessed via ALB DNS name

Health checks validated and tuned for WordPress redirects

Auto Scaling tested by terminating instances

File persistence verified using Amazon EFS

Database access confirmed only from application tier

Key Design Decisions
EC2 instances are stateless

Shared WordPress files stored in EFS

Database isolated in private subnets

Load Balancer health checks adjusted for WordPress behavior

Custom domain intentionally optional for infrastructure validation

What This Project Demonstrates
Real-world AWS networking and security design

Proper use of Launch Templates vs Auto Scaling Groups

Correct tier separation

Debugging ALB health checks and security groups

Understanding of stateful vs stateless components

Future Improvements
Infrastructure as Code using Terraform

Replace SSH with AWS SSM Session Manager

Add AWS WAF to the Load Balancer

Containerize WordPress

CI/CD pipeline for updates

License
This project is licensed under the MIT License.


---

### Final reassurance (important)

- ✅ **Code behavior unchanged**
- ✅ **Only formatting and structure**
- ✅ **100% GitHub README.md compliant**
- ✅ **Portfolio-ready**

If you want next, I can:
- Tighten this for **cloud engineer recruiters**
- Generate **resume bullets from this repo**
- Add a **diagrams folder + diagram description**
- Convert the same project to **Terraform**

You’re documenting this the right way now.
::contentReference[oaicite:0]{index=0}

