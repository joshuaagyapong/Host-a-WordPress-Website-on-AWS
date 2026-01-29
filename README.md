🌐 Hosting a WordPress Website on AWS: Multi-Tier Production Architecture📖 Project OverviewThis project demonstrates the deployment of a highly available, secure, and scalable WordPress application on AWS. Moving beyond a simple single-server setup, this architecture follows enterprise-grade design patterns, utilizing a three-tier system to ensure fault tolerance and performance at scale.🏗️ Architecture DesignThe solution is built on a robust three-tier foundation:Presentation Tier: Utilizes an Application Load Balancer (ALB) to manage incoming traffic and provide SSL termination.Application Tier: WordPress runs on Amazon EC2 instances within an Auto Scaling Group (ASG), ensuring the site stays online even if an instance fails.Data Tier: Leveraging Amazon RDS (MySQL) for structured data and Amazon EFS for shared file storage across the fleet of web servers.🛠️ AWS Services & Infrastructure StackServicePurposeVPC & SubnetsIsolated networking across two Availability Zones for high availability.ALBDistributes traffic across instances and performs health checks.Auto ScalingAutomatically adjusts capacity to maintain steady performance.Amazon EFSProvides a shared file system so all EC2 instances see the same WordPress media/plugins.Amazon RDSA managed database service for high-performance MySQL hosting.NAT GatewayAllows private instances to download updates without being exposed to the public internet.IAM & Security GroupsImplements the Principle of Least Privilege for service-to-service communication.🔒 Security PostureZero Public Access: No EC2 instances have public IP addresses; they reside entirely in private subnets.Security Groups: Strictly defined ingress/egress rules (e.g., Database only accepts traffic from the App Tier).Encrypted Storage: Data at rest protection for both RDS and EFS.Secure Admin: Using EC2 Instance Connect Endpoint for SSH access, removing the need for a Bastion Host or public SSH keys.📜 Deployment Scripts1. Initial Setup (Manual Validation)Used for the first-time installation and configuration of the WordPress core and EFS mounting.<details><summary>Click to view Manual Setup Script</summary>Bashsudo su
sudo yum update -y
sudo mkdir -p /var/www/html

# Replace with your specific EFS DNS
EFS_DNS_NAME=fs-064e9505819af10a4.efs.us-east-1.amazonaws.com

sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport \
"$EFS_DNS_NAME":/ /var/www/html

sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd

sudo dnf install -y php php-cli php-cgi php-curl php-mbstring php-gd php-mysqlnd \
php-gettext php-json php-xml php-fpm php-intl php-zip php-bcmath \
php-ctype php-fileinfo php-openssl php-pdo php-tokenizer

wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html
sudo systemctl restart httpd
</details>2. Auto Scaling User Data (Production)This script is attached to the Launch Template. It ensures every new instance spawned by Auto Scaling is automatically configured and joined to the cluster.Bash#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd

sudo dnf install -y php php-cli php-cgi php-curl php-mbstring php-gd php-mysqlnd \
php-gettext php-json php-xml php-fpm php-intl php-zip php-bcmath \
php-ctype php-fileinfo php-openssl php-pdo php-tokenizer

EFS_DNS_NAME=fs-02d3268559aa2a318.efs.us-east-1.amazonaws.com

echo "$EFS_DNS_NAME:/ /var/www/html nfs4 defaults,_netdev 0 0" >> /etc/fstab
mount -a

sudo chown -R apache:apache /var/www/html
sudo systemctl restart httpd
✅ Validation & ResilienceSelf-Healing: Manually terminated an EC2 instance; the Auto Scaling Group detected the failure and provisioned a replacement within minutes.State Management: Verified that uploading a media file on one instance made it immediately available on all others via Amazon EFS.Health Checks: Configured ALB to monitor /wp-admin/install.php with success codes 200-399 to account for initial setup redirects.🚀 Key TakeawaysDesigned a Stateless Compute Layer where instances are disposable.Implemented High Availability by distributing resources across multiple Availability Zones.Optimized cost and security using Private Subnets and NAT Gateways.
