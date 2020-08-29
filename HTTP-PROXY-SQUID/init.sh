#!/bin/bash
#========YOUR SETTINGS========#
#fill in your values before running the script!

#Proxy user's credential
lemonproxie={user}
premiumplan={pass}
#your IP address for SSH access
18.133.230.33={myip}
#=======/YOUR SETTINGS========#

#Install firewall, squid and htpasswd
yum install firewalld squid httpd-tools -y

#config files

#squid config
cat <<EOF > /etc/squid/squid.conf
auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwords
auth_param basic realm proxy
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
http_port 3128
EOF

#yum daily updates + squid restart
cat <<EOF > /etc/cron.daily/update.sh
#!/bin/bash
/usr/bin/yum -y update
systemctl restart squid
EOF

chmod a+x /etc/cron.daily/update.sh

#generate password
htpasswd -nb $USER $PASS >> /etc/squid/passwords

#firewall rules
systemctl stop firewalld

firewall-offline-cmd --zone=public --add-rich-rule="rule family=ipv4 source address=$MYIP accept"
firewall-offline-cmd --zone=public --add-port=3128/tcp
firewall-offline-cmd --remove-service=ssh
firewall-offline-cmd --zone=public --add-interface=eth0

systemctl start firewalld squid
systemctl enable firewalld squid
