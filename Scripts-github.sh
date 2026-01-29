{\rtf1\ansi\ansicpg1252\cocoartf2865
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;\f1\fswiss\fcharset0 Helvetica-Bold;\f2\fnil\fcharset0 Menlo-Regular;
\f3\fnil\fcharset0 Menlo-Bold;}
{\colortbl;\red255\green255\blue255;\red224\green224\blue224;\red25\green29\blue39;\red0\green0\blue0;
\red255\green255\blue255;}
{\*\expandedcolortbl;;\csgenericrgb\c87761\c87761\c87761;\csgenericrgb\c9839\c11388\c15260\c95000;\cssrgb\c0\c0\c0;
\cssrgb\c100000\c100000\c100000;}
\margl1440\margr1440\vieww11520\viewh11380\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 #!/bin/bash\
\
# create to root user\
sudo su\
\
# update the software packages on the ec2 instance \
sudo yum update -y\
\
# create an html directory \
sudo mkdir -p /var/www/html\
\
# environment variable\
EFS_DNS_NAME=fs-0205fad1440578044.efs.us-east-1.amazonaws.com\
\
# mount the efs to the html directory \
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport "$EFS_DNS_NAME":/ /var/www/html\
\

\f1\b #run this command to check if it mounted
\f0\b0 \
df -h\
\
# install the apache web server, enable it to start on boot, and then start the server immediately\
sudo yum install -y httpd\
sudo systemctl enable httpd \
sudo systemctl start httpd\
\
# install php 8 along with several necessary extensions for wordpress to run\
sudo dnf install -y \\\
php \\\
php-cli \\\
php-cgi \\\
php-curl \\\
php-mbstring \\\
php-gd \\\
php-mysqlnd \\\
php-gettext \\\
php-json \\\
php-xml \\\
php-fpm \\\
php-intl \\\
php-zip \\\
php-bcmath \\\
php-ctype \\\
php-fileinfo \\\
php-openssl \\\
php-pdo \\\
php-tokenizer\
\
# install the mysql version 8 community repository\
sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm \
#\
# install the mysql server\
sudo dnf install -y mysql80-community-release-el9-1.noarch.rpm \
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023\
sudo dnf repolist enabled | grep "mysql.*-community.*"\
sudo dnf install -y mysql-community-server \
#\
# start and enable the mysql server\
sudo systemctl start mysqld\
sudo systemctl enable mysqld\
\
# set permissions\
sudo usermod -a -G apache ec2-user\
sudo chown -R ec2-user:apache /var/www\
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 \{\} \\;\
sudo find /var/www -type f -exec sudo chmod 0664 \{\} \\;\
chown apache:apache -R /var/www/html \
\
# download wordpress files\
wget https://wordpress.org/latest.tar.gz\
tar -xzf latest.tar.gz\
sudo cp -r wordpress/* /var/www/html/\
\
#
\f1\b AFTER  check it in the HTML directory\

\f0\b0 cd /var/www/html
\f1\b \

\f0\b0 \
\
# create the wp-config.php file\
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php\
\
# edit the wp-config.php file\
sudo vi /var/www/html/wp-config.php\
\
#We are using VI editor, press I to Insert, use drop down arrow and right key to navigate > change database name (DB NAME), username and password And RDS enpoint in the db_hostname (go to RDS to copy and paste)\
to Close press ESC , and type :wq! to save and exit\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f2 \cf2 \cb3 \CocoaLigature0 #
\f3\b Check the changes you made
\f2\b0 \
\cf4 \cb5 cat /var/www/html/wp-config.php
\f0 \cf0 \cb1 \CocoaLigature1 \
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0
\cf0 \
# restart the webserver\
sudo service httpd restart}