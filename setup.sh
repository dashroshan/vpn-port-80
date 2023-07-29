# Open ports
ufw allow 80
ufw allow 443
echo "Ports 80, 443 opened, ensure they are open on VM hosting service too."

# Create 1GB swap memory
mkdir -p /var/swapmemory
cd /var/swapmemory
dd if=/dev/zero of=swapfile bs=1M count=1000
mkswap swapfile
swapon swapfile
chmod 600 swapfile
free -m
echo "Swap memory created."

# Boost network performance
sysctl -w net.core.rmem_max=26214400
sysctl -w net.core.rmem_default=26214400
echo "Network performance boosted."

# Install python, pip, and screen
apt update
apt install python3 python3-pip screen
echo "Installed python, pip, and screen."

# Setup the web admin panel
cd
git clone https://github.com/dashroshan/vpn-port-80 vpn
cd vpn
python3 -m pip install -r requirements.txt
echo "Web admin panel cloned and packages installed."

# Create the configWireguard.py
read -p "Enter 'wireguard' or 'openvpn' as needed: " vpntype
if [ "$vpntype" == "wireguard" ]; then
read -p "Enter 'True' or 'False' for AdBlock: " adblock
cat << EOF > configWireguard.py
wireGuardBlockAds = $adblock
EOF
echo "configureWireguard.py file created for AdBlock settings."
fi

# Create the config.py
read -p "Web admin panel username: " adminuser
read -p "Web admin panel password: " adminpass

passwordhash=$(echo -n $adminpass | sha256sum | cut -d" " -f1)

cat << EOF > config.py
import $vpntype as vpn
creds = {
    "username": "$adminuser",
    "password": "$passwordhash",
}
EOF
echo "config.py file created for web admin panel."

# Download vpn setup script
cd
if [ "$vpntype" == "wireguard" ]; then
wget https://raw.githubusercontent.com/Nyr/wireguard-install/master/wireguard-install.sh -O vpn-install.sh
else
wget https://raw.githubusercontent.com/Nyr/openvpn-install/master/openvpn-install.sh -O vpn-install.sh
fi
echo "VPN setup script downloaded."

# Setup vpn
chmod +x vpn-install.sh
bash vpn-install.sh
echo "VPN service installed."

# Run web admin portal
cd vpn
screen -dmS vpn bash -c 'python3 main.py; bash'
echo "Web admin portal started at $admindomain"
echo "Done!"