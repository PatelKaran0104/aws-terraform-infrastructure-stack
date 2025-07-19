#!/bin/bash
yum update -y
yum install httpd stress amazon-efs-utils nfs-utils -y
# Start the httpd service
systemctl start httpd
systemctl enable httpd
# Ensure the directory exists and set permissions
mkdir -p /var/www/html/
chmod 755 /var/www/html
# Create a mount point for EFS
mkdir /mnt/efs
mount -t efs ${efs_file_system_id}:/ /mnt/efs
echo '${efs_file_system_id}:/ /mnt/efs efs defaults,_netdev 0 0' >> /etc/fstab
# Fetch the hostname of the instance
hostname=$(hostname)
echo "<html><head><title>AWS Educate Demo</title></head><body><h1>🎉 Welcome to AWS!</h1><h2>Server: $hostname</h2><p>This server is running on AWS with Terraform!</p><p>EFS Mount: $(ls /mnt/efs 2>/dev/null || echo 'Mounting...')</p><p>Time: $(date)</p></body></html>" > /var/www/html/index.html
# Create a health check endpoint
echo "OK" > /var/www/html/health.html
chkconfig httpd on
# Force restart to ensure everything is working
systemctl restart httpd