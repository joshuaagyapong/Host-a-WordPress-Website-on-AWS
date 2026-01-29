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

### WordPress Installation Script

This script is used for the initial setup of the WordPress application on an EC2 instance. It includes steps for installing Apache, PHP, MySQL, and mounting the Amazon EFS to the instance.

```bash
# create to root user
sudo su

# update the software packages on the ec2 instance 
sudo yum update -y

# create an html directory 
sudo mkdir -p /var/www/html

# environment variable
EFS_DNS_NAME=fs-0205fad1440578044.efs.us-east-1.amazonaws.com

# mount the efs to the html directory 
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport "$EFS_DNS_NAME":/ /var/www/html

# install the apache web server, enable it to start on boot, and then start the server immediately
sudo yum install -y httpd
sudo systemctl enable httpd 
sudo systemctl start httpd

# install php 8 along with several necessary extensions for wordpress to run
sudo dnf install -y \
php \
php-cli \
php-cgi \
php-curl \
php-mbstring \
php-gd \
php-mysqlnd \
php-gettext \
php-json \
php-xml \
php-fpm \
php-intl \
php-zip \
php-bcmath \
php-ctype \
php-fileinfo \
php-openssl \
php-pdo \
php-tokenizer

# install the mysql version 8 community repository
sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm 
#
# install the mysql server
sudo dnf install -y mysql80-community-release-el9-1.noarch.rpm 
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
sudo dnf repolist enabled | grep "mysql.*-community.*"
sudo dnf install -y mysql-community-server 
#
# start and enable the mysql server
sudo systemctl start mysqld
sudo systemctl enable mysqld

# set permissions
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
sudo find /var/www -type f -exec sudo chmod 0664 {} \;
chown apache:apache -R /var/www/html 

# download wordpress filesx	
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/

# create the wp-config.php file
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# edit the wp-config.php file
sudo vi /var/www/html/wp-config.php

# restart the webserver
sudo service httpd restart
```

### Auto Scaling Group Launch Template Script

This script is included in the launch template for the Auto Scaling Group, ensuring that new instances are configured correctly with the necessary software and settings.

```bash
#!/bin/bash
# update the software packages on the ec2 instance 
sudo yum update -y

# install the apache web server, enable it to start on boot, and then start the server immediately
sudo yum install -y http

sudo systemctl enable httpd 
sudo systemctl start httpd

# install php 8 along with several necessary extensions for wordpress to run
sudo dnf install -y \
php \
php-cli \
php-cgi \
php-curl \
php-mbstring \
php-gd \
php-mysqlnd \
php-gettext \
php-json \
php-xml \
php-fpm \
php-intl \
php-zip \
php-bcmath \
php-ctype \
php-fileinfo \
php-openssl \
php-pdo \
php-tokenizer

# install the mysql version 8 community repository
sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm 
#
# install the mysql server
sudo dnf install -y mysql80-community-release-el9-1.noarch.rpm 
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
sudo dnf repolist enabled | grep "mysql.*-community.*"
sudo dnf install -y mysql-community-server 
#
# start and enable the mysql server
sudo systemctl start mysqld
sudo systemctl enable mysqld

# environment variable
EFS_DNS_NAME=fs-0205fad1440578044.efs.us-east-1.amazonaws.com

# mount the efs to the html directory 
echo "$EFS_DNS_NAME:/ /var/www/html nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab
mount -a

# set permissions
chown apache:apache -R /var/www/html

# restart the webserver
sudo service httpd restart
```

## Validation and Testing

- Application reachable via Application Load Balancer DNS  
- ALB health checks stable  
- EC2 instances terminated and replaced automatically by Auto Scaling  
- WordPress files persisted using Amazon EFS  
- Database access limited to application tier  

---

## Key Design Decisions

- Stateless EC2 instances  
- Shared file storage with Amazon EFS  
- Database isolated in private subnets  
- ALB health checks tuned to accept `200–399`  
- Custom domain optional  

---

## What This Project Demonstrates

- Production-style AWS architecture  
- Secure tier isolation  
- Correct Auto Scaling behavior  
- Real-world ALB health check troubleshooting  
