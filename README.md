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

