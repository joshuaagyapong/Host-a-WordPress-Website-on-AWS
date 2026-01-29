# Hosting a WordPress Website on AWS

Deploy a **highly available, secure, and scalable WordPress application** on AWS using a production-style, multi-tier architecture.

![Architecture Diagram](Host_a_WordPress_Website_on_AWS.png)

---

## Project Summary

This project demonstrates how WordPress is deployed in a **real-world AWS environment**, focusing on reliability, security, and scalability rather than a single-server setup.

The design mirrors patterns used in production systems to ensure:
- Fault tolerance
- Secure access boundaries
- Horizontal scalability
- Separation of concerns across tiers

---

## Architecture Overview (High-Level)

The application is deployed using a **three-tier architecture**:

- **Presentation Tier**  
  Handles incoming user traffic via an Application Load Balancer.

- **Application Tier**  
  Runs WordPress on EC2 instances managed by an Auto Scaling Group.

- **Data Tier**  
  Stores persistent data in Amazon RDS and shared files in Amazon EFS.

Each tier is isolated using private networking and controlled access rules.

---

## AWS Services Used and Why

### Amazon VPC  
Provides network isolation and full control over IP addressing, routing, and security boundaries.

### Public and Private Subnets  
- **Public subnets** expose only the load balancer and NAT gateway.
- **Private subnets** protect application and database resources from direct internet access.

### Internet Gateway  
Allows inbound internet traffic to reach the Application Load Balancer only.

### NAT Gateway  
Enables private EC2 instances to access the internet securely for updates and package installs without being publicly reachable.

### Application Load Balancer (ALB)  
Distributes incoming HTTP traffic across multiple EC2 instances and performs health checks to ensure availability.

### Auto Scaling Group (ASG)  
Automatically replaces unhealthy instances and maintains application availability across Availability Zones.

### Launch Template  
Defines a consistent and repeatable configuration for EC2 instances, including user data and security settings.

### Amazon EC2  
Runs the WordPress application in the private application subnets.

### Amazon RDS (MySQL)  
Provides a managed, highly available relational database for WordPress content and metadata.

### Amazon EFS  
Offers shared file storage so multiple EC2 instances can access the same WordPress files (themes, plugins, uploads).

### EC2 Instance Connect Endpoint  
Enables secure administrative access to private EC2 instances without opening SSH to the internet.

### AWS Certificate Manager (ACM)  
Manages SSL/TLS certificates for encrypted traffic termination at the load balancer.

### Amazon SNS  
Used for notifications related to Auto Scaling events.

### Amazon Route 53 (Optional)  
Can be used for DNS management and custom domain routing, though not required for infrastructure validation.

---

## Network Design

- **VPC:** Single VPC spanning two Availability Zones
- **Public Subnets:**
  - Application Load Balancer
  - NAT Gateway
- **Private Application Subnets:**
  - WordPress EC2 instances (Auto Scaling Group)
- **Private Data Subnets:**
  - Amazon RDS
  - Amazon EFS mount targets

This design ensures that only the load balancer is internet-facing.

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

Used for initial setup and validation during early deployment and testing.

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
