# These variables are accessible in the Jinja (j2) templates in files/ folder.
# Create file local-config.bash to overwrite values from this defaults file.

export HOSTNAME=blackbox-1

IP_PREFIX="192.168.2"
export ROUTER_IP="${IP_PREFIX}.1"
export BULLET_IP="${IP_PREFIX}.2"
export BULLET_MAC="E0:63:DA:DC:8F:2E"
export SEPTENTRIO_IP="${IP_PREFIX}.3"
export SEPTENTRIO_MAC="56:1D:69:EA:93:F1"
export DHCP_SUBNET_SIZE=24
export DHCP_START=60
export DHCP_LIMIT=194
export DHCP_LEASE_TIME=345600

export NTP_SERVER="ntp.nic.cz"

export WIFI_COUNTRY=CZ
export WIFI_AP_SSID=TRADR-CTU
export WIFI_AP_PASSWORD=you_want_to_overwrite_this
export WIFI_24_CHANNEL=3
export WIFI_5_CHANNEL=36

export WIREGUARD_LOCAL_IP=192.168.140.101/24
export WIREGUARD_LOCAL_PRIVATE_KEY=secret
export WIREGUARD_REMOTE_DESCRIPTION=Karel
export WIREGUARD_REMOTE_IP=i.p.a.d
export WIREGUARD_REMOTE_ALLOWED_IPS=192.168.140.1/24
export WIREGUARD_REMOTE_PUBLIC_KEY=public

OPKG_PACKAGES=()
export OPKG_PACKAGES
OPKG_PACKAGES+=("kmod-ebtables-ipv4")
OPKG_PACKAGES+=("git")
OPKG_PACKAGES+=("screen")
OPKG_PACKAGES+=("tmux")
OPKG_PACKAGES+=("luci-app-vnstat2")
OPKG_PACKAGES+=("dev-detect")
OPKG_PACKAGES+=("kmod-usb-net-cdc-ether")
OPKG_PACKAGES+=("kmod-usb-net-rndis")
OPKG_PACKAGES+=("kmod-nf-nat6")
OPKG_PACKAGES+=("iftop")
OPKG_PACKAGES+=("git-http")
OPKG_PACKAGES+=("coreutils-install")
OPKG_PACKAGES+=("ntp-utils")