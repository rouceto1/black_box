# These variables are accessible in the Jinja (j2) templates in files/ folder.
# Create file local-config.bash to overwrite values from this defaults file.

HOSTNAME=blackbox-1

IP_PREFIX="192.168.2"
ROUTER_IP="${IP_PREFIX}.1"
BULLET_IP="${IP_PREFIX}.2"
BULLET_MAC="E0:63:DA:DC:8F:2E"
SEPTENTRIO_IP="${IP_PREFIX}.3"
SEPTENTRIO_MAC="56:1D:69:EA:93:F1"
DHCP_SUBNET_SIZE=24
DHCP_START=60
DHCP_LIMIT=194
DHCP_LEASE_TIME=345600

NTP_SERVER="ntp.nic.cz"

GSM_APN=internet
GSM_PIN=1234

WIFI_COUNTRY=CZ
WIFI_AP_SSID=TRADR-CTU
WIFI_AP_PASSWORD=you_want_to_overwrite_this
WIFI_24_CHANNEL=3
WIFI_5_CHANNEL=36

WIREGUARD_LOCAL_IP=192.168.140.101/24
WIREGUARD_LOCAL_PRIVATE_KEY=secret
WIREGUARD_REMOTE_DESCRIPTION=Karel
WIREGUARD_REMOTE_IP=i.p.a.d
WIREGUARD_REMOTE_ALLOWED_IPS=192.168.140.1/24
WIREGUARD_REMOTE_PUBLIC_KEY=public

OPKG_PACKAGES=()
OPKG_PACKAGES+=("kmod-ebtables-ipv4")
OPKG_PACKAGES+=("git")
OPKG_PACKAGES+=("screen")
OPKG_PACKAGES+=("tmux")
OPKG_PACKAGES+=("libqmi")
OPKG_PACKAGES+=("qmi-utils")
OPKG_PACKAGES+=("luci-app-vnstat2")
OPKG_PACKAGES+=("dev-detect")
OPKG_PACKAGES+=("kmod-usb-net-cdc-ether")
OPKG_PACKAGES+=("kmod-usb-net-rndis")
OPKG_PACKAGES+=("kmod-ipt-nat6")
OPKG_PACKAGES+=("iftop")
OPKG_PACKAGES+=("git-http")
OPKG_PACKAGES+=("coreutils-install")