#!/bin/bash
# NAT Instance user data script
# Configures Amazon Linux 2023 as a NAT instance

set -e

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# Configure iptables for NAT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
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
yum install -y amazon-cloudwatch-agent
%{ endif }

# Harden SSH configuration
cat >> /etc/ssh/sshd_config <<'SSHCONFIG'
# Security hardening
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
SSHCONFIG

systemctl restart sshd

# Install fail2ban for SSH protection
yum install -y fail2ban

# Configure fail2ban for SSH
cat > /etc/fail2ban/jail.local <<'FAIL2BAN'
[sshd]
enabled = true
port = 22
maxretry = 3
findtime = 600
bantime = 3600
FAIL2BAN

systemctl enable fail2ban
systemctl start fail2ban

# System updates
yum update -y

# Optimize system for NAT performance (free)
cat >> /etc/sysctl.conf <<'SYSCTL'
# Network optimizations for NAT
net.ipv4.netfilter.ip_conntrack_max = 65536
net.netfilter.nf_conntrack_max = 65536
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_max_syn_backlog = 2048
SYSCTL
sysctl -p

# Health check script (free monitoring)
cat > /usr/local/bin/nat-health-check.sh <<'HEALTHCHECK'
#!/bin/bash
# NAT instance health check and auto-recovery

LOG_FILE="/var/log/nat-health-check.log"
MAX_FAILURES=3
FAILURE_COUNT=0

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

check_internet() {
    # Test connectivity to multiple endpoints
    if curl -s --max-time 5 https://www.google.com > /dev/null && \
       curl -s --max-time 5 https://aws.amazon.com > /dev/null; then
        return 0
    else
        return 1
    fi
}

check_nat_rules() {
    # Verify iptables NAT rules exist
    if iptables -t nat -L POSTROUTING | grep -q MASQUERADE; then
        return 0
    else
        return 1
    fi
}

recover() {
    log "ERROR: Health check failed $FAILURE_COUNT times, attempting recovery"
    
    # Restore iptables rules
    if [ -f /etc/iptables.rules ]; then
        iptables-restore < /etc/iptables.rules
        log "INFO: Restored iptables rules"
    fi
    
    # Restart networking if needed
    systemctl restart NetworkManager
    log "INFO: Restarted network services"
}

# Main health check
if ! check_internet; then
    log "WARNING: Internet connectivity check failed"
    FAILURE_COUNT=$((FAILURE_COUNT + 1))
fi

if ! check_nat_rules; then
    log "ERROR: NAT rules missing"
    FAILURE_COUNT=$((FAILURE_COUNT + 1))
fi

if [ $FAILURE_COUNT -ge $MAX_FAILURES ]; then
    recover
else
    log "INFO: Health check passed (failures: $FAILURE_COUNT)"
fi
HEALTHCHECK

chmod +x /usr/local/bin/nat-health-check.sh

# Schedule health check every 5 minutes
cat > /etc/cron.d/nat-health-check <<'CRON'
*/5 * * * * root /usr/local/bin/nat-health-check.sh
CRON

# NAT traffic statistics script (free monitoring)
cat > /usr/local/bin/nat-stats.sh <<'NATSTATS'
#!/bin/bash
# Display NAT instance traffic statistics

echo "=== NAT Instance Statistics ==="
echo
echo "Active Connections:"
cat /proc/net/nf_conntrack | wc -l

echo
echo "Network Interface Stats:"
ip -s link show eth0

echo
echo "Top 10 Source IPs by Connection Count:"
cat /proc/net/nf_conntrack | awk '{print $5}' | cut -d= -f2 | sort | uniq -c | sort -rn | head -10

echo
echo "NAT Table Rules:"
iptables -t nat -L -n -v

echo
echo "Recent Traffic (last 5 minutes):"
journalctl -u iptables-restore --since "5 minutes ago" | tail -20
NATSTATS

chmod +x /usr/local/bin/nat-stats.sh

# Admin helper script (free tools)
cat > /usr/local/bin/nat-admin.sh <<'NATADMIN'
#!/bin/bash
# NAT instance administration helper

case "$1" in
    stats)
        /usr/local/bin/nat-stats.sh
        ;;
    connections)
        echo "Active connections by destination:"
        cat /proc/net/nf_conntrack | awk '{print $6}' | cut -d= -f2 | sort | uniq -c | sort -rn | head -20
        ;;
    block)
        if [ -z "$2" ]; then
            echo "Usage: nat-admin.sh block <IP>"
            exit 1
        fi
        iptables -I FORWARD -s $2 -j DROP
        echo "Blocked traffic from $2"
        ;;
    unblock)
        if [ -z "$2" ]; then
            echo "Usage: nat-admin.sh unblock <IP>"
            exit 1
        fi
        iptables -D FORWARD -s $2 -j DROP
        echo "Unblocked traffic from $2"
        ;;
    health)
        /usr/local/bin/nat-health-check.sh
        tail -20 /var/log/nat-health-check.log
        ;;
    *)
        echo "NAT Instance Admin Tool"
        echo "Usage: nat-admin.sh {stats|connections|block|unblock|health}"
        echo
        echo "Commands:"
        echo "  stats       - Show NAT statistics"
        echo "  connections - Show active connections by destination"
        echo "  block <IP>  - Block traffic from specific IP"
        echo "  unblock <IP>- Unblock traffic from specific IP"
        echo "  health      - Run health check and show logs"
        ;;
esac
NATADMIN

chmod +x /usr/local/bin/nat-admin.sh

# Create initial health check log
touch /var/log/nat-health-check.log
/usr/local/bin/nat-health-check.sh

echo "NAT Instance configuration complete with monitoring and admin tools"
echo "Use 'nat-admin.sh' for management, 'nat-stats.sh' for statistics"
