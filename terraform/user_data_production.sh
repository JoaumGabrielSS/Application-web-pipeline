#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting minimal infrastructure setup..."

yum update -y

amazon-linux-extras install docker -y
systemctl enable docker
systemctl start docker

usermod -a -G docker ec2-user

curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

yum install -y git curl wget unzip htop tree firewall-cmd

systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-port=22/tcp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=3000/tcp
firewall-cmd --permanent --add-port=3306/tcp
firewall-cmd --reload

mkdir -p /opt/game-app
chown ec2-user:ec2-user /opt/game-app

cat > /usr/local/bin/health-check.sh << 'EOF'
#!/bin/bash
echo "=== SYSTEM HEALTH CHECK ==="
echo "Date: $(date)"
echo "Uptime: $(uptime)"
echo "Docker: $(systemctl is-active docker)"
echo "Disk: $(df -h / | tail -1)"
echo "Memory: $(free -h | grep Mem)"
echo "=========================="
EOF
chmod +x /usr/local/bin/health-check.sh

echo "Infrastructure setup completed at $(date)"
echo "Ready for application deployment via Jenkins"