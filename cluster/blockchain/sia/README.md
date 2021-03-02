|env variable | Purpose|
|--------|-------|
|SIA_DIR | nothing? |
|SIA_DATA_DIR| api password + siac (client) files |
|SIAD_DATA_DIR| blockchain,wallet,everything |


echo "net.ipv4.conf.all.route_localnet=1" >> /etc/sysctl.conf
sudo iptables -t nat -A OUTPUT -m addrtype --src-type LOCAL --dst-type LOCAL -p tcp --dport 9980 -j DNAT --to-destination SIA_IP:9980
sudo iptables -t nat -A POSTROUTING -m addrtype --src-type LOCAL --dst-type UNICAST -j MASQUERADE
