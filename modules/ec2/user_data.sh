#!/bin/bash
yum update -y
yum install -y unzip curl wget git httpd php php-fpm php-mysqlnd java-1.8.0-openjdk --allowerasing

systemctl enable httpd
systemctl start httpd
systemctl enable php-fpm
systemctl start php-fpm

mkdir -p /var/log/php-fpm
touch /var/log/php-fpm/error.log
chown apache:apache /var/log/php-fpm/error.log

cd /var/www/html
git clone ${github_url} app
cp -r app/* .
cp app/.env.example .env

cat <<EOF > .env
DB_HOST=${rds_endpoint}
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
EOF

chown -R apache:apache /var/www/html
chmod 644 .env
rm -rf app

cd /tmp
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /dev/null <<'EOF'
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

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
