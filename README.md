# Hosting a WordPress Website on AWS

Deploy a **highly available, secure, and scalable WordPress application** on AWS using a production-style, multi-tier architecture.

![WordPress on AWS Architecture](Host_a_WordPress_Website_on_AWS.png)

---

## Project Overview

This project demonstrates how to deploy WordPress on AWS following **real-world infrastructure patterns**, with a focus on availability, security, and scalability.

The architecture separates **networking, compute, storage, and data**, and is designed to survive instance failures without service interruption.

---

## Architecture Summary

### Core Design Goals

- High availability across multiple Availability Zones  
- No public access to application or database servers  
- Stateless compute with shared storage  
- Managed database with private network isolation  
- Load-balanced traffic with health monitoring  

---

## AWS Services Used

- Amazon VPC  
- Internet Gateway  
- NAT Gateway  
- Application Load Balancer (ALB)  
- Amazon EC2 (Auto Scaling Group)  
- Launch Template  
- Amazon RDS (MySQL)  
- Amazon EFS  
- EC2 Instance Connect Endpoint  
- AWS Certificate Manager (ACM)  
- Amazon SNS  
- Amazon Route 53 (optional)  

---

## Network Design

- **VPC**
  - Single VPC spanning two Availability Zones

- **Public Subnets**
  - Application Load Balancer
  - NAT Gateways

- **Private Application Subnets**
  - WordPress EC2 instances (Auto Scaling Group)

- **Private Data Subnets**
  - Amazon RDS (MySQL)

---

## Traffic Flow

