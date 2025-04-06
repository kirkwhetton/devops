sudo apt update
sudo apt install net-tools
sudo apt upgrade
sudo chmod 777 /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf
sudo iptables -t nat -A POSTROUTING -d 10.0.0.0/8 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -d 172.16.0.0/12 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -d 192.168.0.0/16 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -j ACCEPT
sudo ifconfig eth0 mtu 4000
sudo ufw disable

tunnel_internal_vni=800
tunnel_internal_port=10800
tunnel_external_vni=801
tunnel_external_port=10801
gateway_lb_ip=10.1.2.5

sudo ip link add vxlan${tunnel_internal_vni} type vxlan id ${tunnel_internal_vni} remote ${gateway_lb_ip} dstport ${tunnel_internal_port} nolearning
sudo ip link set vxlan${tunnel_internal_vni} up
sudo ip link add vxlan${tunnel_external_vni} type vxlan id ${tunnel_external_vni} remote ${gateway_lb_ip} dstport ${tunnel_external_port} nolearning
sudo ip link set vxlan${tunnel_external_vni} up
sudo ip link add br-tunnel type bridge
sudo ip link set vxlan${tunnel_internal_vni} master br-tunnel
sudo ip link set vxlan${tunnel_external_vni} master br-tunnel
sudo ip link set br-tunnel up
ip a
sysctl net.ipv4.ip_forward
ifconfig vxlan${tunnel_internal_vni}
ip -d link show vxlan${tunnel_internal_vni}
ip -d link show vxlan${tunnel_external_vni}
route -n