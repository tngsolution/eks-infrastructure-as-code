#!/bin/bash
# NAT Instance user data script (fusion dynamique)
# Configure Amazon Linux 2023 as a NAT instance
set -e

# Enable IP forwarding
 echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
 sysctl -p

# Configure iptables for NAT (dynamique pour chaque subnet privé)
%{ for cidr in private_subnet_cidrs ~}
iptables -t nat -A POSTROUTING -s ${cidr} -o eth0 -j MASQUERADE
%{ endfor ~}

# Autoriser le forwarding
iptables -A FORWARD -i eth0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT

# Save iptables rules
iptables-save > /etc/iptables.rules

# Create service to restore iptables on boot
cat > /etc/systemd/system/iptables-restore.service <<'EOF'
[Unit]
Description=Restore iptables rules
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/iptables-restore /etc/iptables.rules
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable iptables-restore.service

# Install network diagnostic tools
yum install -y bind-utils traceroute telnet nc tcpdump net-tools

# Install CloudWatch agent if monitoring enabled
%{ if enable_monitoring }
# ... (ajoute ici la logique d'installation CloudWatch si besoin)
%{ endif }
