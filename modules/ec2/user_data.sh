#!/bin/bash

# Update and install essential packages
yum update -y
amazon-linux-extras enable php8.1 -y
yum clean metadata
yum install -y unzip curl wget git httpd php php-mysqlnd php-cli php-pdo php-common amazon-ssm-agent

# Install MySQL CLI (MariaDB client)
yum install -y mariadb

# Enable and start Apache
systemctl enable httpd
systemctl start httpd

# Ensure Apache serves index.php before index.html
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' /etc/httpd/conf/httpd.conf
systemctl restart httpd

# Create web root and deploy app
mkdir -p /var/www/html
cd /var/www/html
git clone https://github.com/mr-robertamoah/simple-lamp-stack.git
cp -r simple-lamp-stack/php_application/* .

# Inject database credentials
cat <<EOF > .env
DB_HOST=${rds_endpoint}
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
EOF

# Set correct permissions
chown -R apache:apache /var/www/html
chmod 640 .env
rm -rf /var/www/html/simple-lamp-stack

# Wait and run DB setup script via Apache
sleep 5
curl -s http://localhost/db_setup.php

# Install CloudWatch Agent
cd /tmp
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Create PHP-FPM log file (for CloudWatch consistency)
mkdir -p /var/log/php-fpm
touch /var/log/php-fpm/error.log
chown apache:apache /var/log/php-fpm/error.log

# Create CloudWatch Agent config
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "/lamp/apache/access",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/httpd/error_log",
            "log_group_name": "/lamp/apache/error",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/php-fpm/error.log",
            "log_group_name": "/lamp/php/error",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_idle", "cpu_usage_user", "cpu_usage_system"],
        "metrics_collection_interval": 60
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

# Enable and start SSM Agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
