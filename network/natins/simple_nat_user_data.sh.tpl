#!/bin/bash
set -e

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Ajouter les règles MASQUERADE pour chaque CIDR passé en variable
for cidr in ${private_subnet_cidrs}; do
  iptables -t nat -A POSTROUTING -s "$cidr" -o eth0 -j MASQUERADE
done

# (Optionnel) Rendre les règles persistantes
iptables-save > /etc/iptables.rules
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
