#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "${SCRIPT_DIR}"/default-config.bash
# Create the local-config.bash file to override the default config value
[ -f "${SCRIPT_DIR}"/local-config.bash ] && source "${SCRIPT_DIR}"/local-config.bash

answer() {
  # answer <question> <default> <override> <success>
  local question="$1"
  local default="$2"
  local override="$3"
  local success="$4"

  local ans="${override}"

  if [ "${ans}" ]; then
    echo "${question} Selected value '${ans}' from override" 1>&2
  fi

  if [ ! "${ans}" ] && [ "${silent}" != 'y' ]; then
    read -rep "$(echo -e "${question}")" ans
    echo "Selected value '${ans}' from user input" 1>&2
  fi
  if [ ! "${ans}" ]; then
    ans="${default}"
  fi

  if [ ! "${override}" ]; then
    if [ "${silent}" == 'y' ]; then
      echo "${question} Selected default value '${ans}' because of silent flag" 1>&2
    fi
  fi

  echo "${ans}"
  # Return 1 if success was specified but not met.
  [ ! "${success}" ] || [ "${ans}" = "${success}" ]
}


function make_sure_no_local_changes() {
  local f_local="/$1"
  [[ $# -gt 1 ]] && f_local="$2"
  if [[ -f "${f_local}" ]]; then
    if ! diff "$1" "${f_local}" 1>/dev/null 2>/dev/null; then
      IFS= ans=$(answer "!!! File ${f_local} has local modifications!\n!!! > is local file content, < is content of file to be installed\n!!! Start of diff follows:\n$(diff --color "$1" "${f_local}" | head -n30)\n!!! Overwite [y/n]? " "n" "$overwrite_local_modified_files")
      if [ "$ans" = "n" ]; then
        echo "Not overwriting local modifications in file ${f_local} . Sync the files manually. The file to write was ${f} ."
        return 1
      fi
    fi
  fi
  return 0
}

function install_files() {
  local dir="${SCRIPT_DIR}"/files
  pushd "$dir" 1>/dev/null
	find -- * -print | while IFS= read -r f; do
		if [[ -d "$f" ]]; then
			[[ ! -d "/$f" ]] && echo "Creating dir /$f..."
			install -C -o root -g root -m "$(stat -c '%a' "$f")" -d "/$f"
		else
			[ "$(basename "$f")" = ".gitkeep" ] && continue

			local f_orig="$f"
			local f_local="/$f"

			if [[ $f = *.j2 ]]; then
				f_local="${f_local%.j2}"
				f="/tmp/$(basename "${f%.j2}")"
				if ! "${SCRIPT_DIR}"/render_jinja <"$f_orig" >"$f"; then
					echo "Failed to render template $f_orig ." >&2
					continue
				fi
			fi

			echo "Installing file ${f_local}..."
			if make_sure_no_local_changes "$f" "$f_local" </dev/tty; then
				install -C -o root -g root -m "$(stat -c '%a' "$f_orig")" "$f" "$f_local"
			fi
		fi
	done

  popd 1>/dev/null
}

function modify_files() {
	# Set bash as the default shell for root
  sed -i 's#root:x:0:0:root:/root:/bin/ash#root:x:0:0:root:/root:/bin/bash#' /etc/passwd
  
  sed -i 's#^.*DatabaseDir.*$#DatabaseDir "/srv/vnstat"#' /etc/vnstat.conf
  
  # Configure base opkg packages
  [ ! -f /etc/updater/conf.d/opkg-auto.lua ] && touch /etc/updater/conf.d/opkg-auto.lua
  for i in ${!OPKG_PACKAGES[@]}; do
    pkg=${OPKG_PACKAGES[$i]}
    if ! grep -q "\"${pkg}\"" /etc/updater/conf.d/opkg-auto.lua; then
    	echo "Install(\"${pkg}\")" >> /etc/updater/conf.d/opkg-auto.lua
  	fi
  done
}

function uci_get_anonymous_section_with_option() {
	local config="$1"
	local section_type="$2"
	local option="$3"
	local value="$4"
	
	local cfg="$("${SCRIPT_DIR}"/uci_get_anonymous_section_with_option "$config" "$section_type" "$option" "$value")"
	if [ -z "$cfg" ]; then
		cfg="$(uci add "$config" "$section_type")"
		uci set "${config}.${cfg}.${option}=$value"
	fi
	
	return "$cfg"
}

function config_packages() {
	"${SCRIPT_DIR}"/uci_ensure_value_in_list pkglists pkglists pkglist datacollect
	"${SCRIPT_DIR}"/uci_ensure_value_in_list pkglists pkglists pkglist luci_controls
	"${SCRIPT_DIR}"/uci_ensure_value_in_list pkglists pkglists pkglist lxc
	"${SCRIPT_DIR}"/uci_ensure_value_in_list pkglists pkglists pkglist net_monitoring
	"${SCRIPT_DIR}"/uci_ensure_value_in_list pkglists pkglists pkglist firmware_update
	
	uci set pkglists.datacollect.dynfw=1
	uci set pkglists.luci_controls.wireguard=1
	uci set pkglists.net_monitoring.librespeed=1
	uci set pkglists.net_monitoring.dev_detect=1
	uci set pkglists.firmware_update.mcu=1
	uci set pkglists.firmware_update.nor=1
	uci set pkglists.firmware_update.factory=1
	
	local ans
	if [ -z "$(uci changes)" ]; then
		ans="n"
	else
		IFS= ans=$(answer "The following UCI changes are proposed:\n$(uci changes)\nPerform the above changes to UCI config? [Y/n]? " "y" "$force_uci_commit")
	fi
	if [ "$ans" = "y" ]; then
		uci commit
	fi
	
	echo "Updating system"
	opkg update && pkgupdate
}

function uci_config() {
	local cfg

	uci set system.@system[0].hostname="$HOSTNAME"
	
	uci set wireless.radio0.path="soc/soc:pcie/pci0000:00/0000:00:01.0/0000:01:00.0"
	uci set wireless.radio0.band=2g
	uci set wireless.radio0.htmode=HE20
	uci set wireless.radio0.disabled=0
	uci set wireless.radio0.country="$WIFI_COUNTRY"
	uci set wireless.radio0.channel="$WIFI_24_CHANNEL"
	uci set wireless.default_radio0.network=lan
	uci set wireless.default_radio0.mode=ap
	uci set wireless.default_radio0.disabled=0
	uci set wireless.default_radio0.ssid="$WIFI_AP_SSID"
	uci set wireless.default_radio0.encryption=sae-mixed
	uci set wireless.default_radio0.key="$WIFI_AP_PASSWORD"
	
	uci set wireless.radio1.path="soc/soc:pcie/pci0000:00/0000:00:01.0/0000:01:00.0+1"
	uci set wireless.radio1.band=5g
	uci set wireless.radio1.htmode=HE40
	uci set wireless.radio1.disabled=0
	uci set wireless.radio1.country="$WIFI_COUNTRY"
	uci set wireless.radio1.channel="$WIFI_5_CHANNEL"
	uci set wireless.default_radio1.network=lan
	uci set wireless.default_radio1.mode=ap
	uci set wireless.default_radio1.disabled=0
	uci set wireless.default_radio1.ssid="$WIFI_AP_SSID"
	uci set wireless.default_radio1.encryption=sae-mixed
	uci set wireless.default_radio1.key="$WIFI_AP_PASSWORD"
	
	uci set wireless.radio2.path="soc/soc:pcie/pci0000:00/0000:00:02.0/0000:02:00.0"
	uci set wireless.radio2.band=2g
	uci set wireless.radio2.htmode=HE40
	uci set wireless.radio2.disabled=0
	uci set wireless.radio2.country="$WIFI_COUNTRY"
	uci set wireless.radio2.channel=auto
	
	cfg="$("${SCRIPT_DIR}"/uci_get_anonymous_section_with_option wireless wifi-iface device radio2)"
	[ -n "$cfg" ] && uci set "wireless.${cfg}.mode=sta"
	[ -n "$cfg" ] && uci set "wireless.${cfg}.network=wwan wwan6"
	
	uci set network.lan.ipaddr="${ROUTER_IP}/${DHCP_SUBNET_SIZE}"
	"${SCRIPT_DIR}"/uci_ensure_value_in_list network br_lan ports usb0

	uci set network.wan.metric=100
	uci set network.wan6.metric=100
	
	! uci -q get network.wwan >/dev/null && uci set network.wwan=interface
	uci set network.wwan.proto=dhcp
	uci set network.wwan.device=wlan2
	uci set network.wwan.metric=150

	! uci -q get network.wwan6 >/dev/null && uci set network.wwan6=interface
	uci set network.wwan6.proto=dhcpv6
	uci set network.wwan6.device=@wwan
	uci set network.wwan6.metric=150
	
	! uci -q get network.gsm >/dev/null && uci set network.gsm=interface
	uci set network.gsm.proto=modemmanager
	uci set network.gsm.device="/sys/devices/platform/soc/soc:internal-regs/f1058000.usb/usb1/1-1"
	uci set network.gsm.apn="${GSM_APN}"
	uci set network.gsm.metric=2048
	uci set network.gsm.iptype=ipv4v6
	uci set network.gsm.pincode="$GSM_PIN"
	
	! uci -q get network.gsm6 >/dev/null && uci set network.gsm6=interface
	uci set network.gsm6.proto=dhcpv6
	uci set network.gsm6.device=@gsm
	uci set network.gsm6.metric=2048
	
	! uci -q get network.wg0 >/dev/null && uci set network.wg0=interface
	uci set network.wg0.proto=wireguard
	uci set network.wg0.delegate=0
	uci set network.wg0.peerdns=0
	uci set network.wg0.defaultroute=0
	uci set network.wg0.private_key="$WIREGUARD_LOCAL_PRIVATE_KEY"
	"${SCRIPT_DIR}"/uci_ensure_value_in_list network wg0 addresses "$WIREGUARD_LOCAL_IP"
	
	! uci -q get network.@wireguard_wg0[0] >/dev/null && uci add network wireguard_wg0
	uci set network.@wireguard_wg0[0].description="$WIREGUARD_REMOTE_DESCRIPTION"
	uci set network.@wireguard_wg0[0].public_key="$WIREGUARD_REMOTE_PUBLIC_KEY"
	uci set network.@wireguard_wg0[0].endpoint_host="$WIREGUARD_REMOTE_IP"
	uci set network.@wireguard_wg0[0].route_allowed_ips=1
	uci set network.@wireguard_wg0[0].persistent_keepalive=20
	cfg="$("${SCRIPT_DIR}"/uci_get_anonymous_section_with_option network wireguard_wg0 description "$WIREGUARD_REMOTE_DESCRIPTION")"
	"${SCRIPT_DIR}"/uci_ensure_value_in_list network "$cfg" allowed_ips "$WIREGUARD_REMOTE_ALLOWED_IPS"
	
	uci set resolver.common.dynamic_domains=1
	uci set dhcp.lan.start="$DHCP_START"
	uci set dhcp.lan.limit="$DHCP_LIMIT"
	uci set dhcp.lan.leasetime="$DHCP_LEASE_TIME"
	"${SCRIPT_DIR}"/uci_ensure_value_in_list dhcp lan dhcp_option "6,$ROUTER_IP"
	uci set dhcp.@dnsmasq[0].leasefile='/srv/dhcp.leases'
	
	cfg="$("${SCRIPT_DIR}"/uci_get_anonymous_section_with_option dhcp host name septentrio)"
	[ -z "$cfg" ] && cfg="$(uci add dhcp host)"
	uci set "dhcp.${cfg}.mac=${SEPTENTRIO_MAC}"
	uci set "dhcp.${cfg}.ip=${SEPTENTRIO_IP}"
	uci set "dhcp.${cfg}.dns=1"
	uci set "dhcp.${cfg}.name=septentrio"
	
	bullet_name="${HOSTNAME}-bullet"
	cfg="$("${SCRIPT_DIR}"/uci_get_anonymous_section_with_option dhcp host name "$bullet_name")"
	[ -z "$cfg" ] && cfg="$(uci add dhcp host)"
	uci set "dhcp.${cfg}.mac=${BULLET_MAC}"
	uci set "dhcp.${cfg}.ip=${BULLET_IP}"
	uci set "dhcp.${cfg}.name=${bullet_name}"

	"${SCRIPT_DIR}"/uci_ensure_value_in_list system ntp server "$NTP_SERVER"
	
	! uci -q get rainbow.wlan_1 >/dev/null && uci set rainbow.wlan_1=led
	uci set rainbow.wlan_1.status=auto
	uci set rainbow.wlan_1.color=FF3300
	! uci -q get rainbow.wlan_2 >/dev/null && uci set rainbow.wlan_2=led
	uci set rainbow.wlan_2.status=auto
	uci set rainbow.wlan_2.color=FF3300
	! uci -q get rainbow.wlan_3 >/dev/null && uci set rainbow.wlan_3=led
	uci set rainbow.wlan_3.status=auto
	uci set rainbow.wlan_3.color=red
	! uci -q get rainbow.wan >/dev/null && uci set rainbow.wan=led
	uci set rainbow.wan.status=auto
	uci set rainbow.wan.color=green
	! uci -q get rainbow.power >/dev/null && uci set rainbow.power=led
	uci set rainbow.power.status=auto
	uci set rainbow.power.color=green
	uci set system.led_pci1.sysfs="rgb:wlan-1"
	uci set system.led_pci2.sysfs="rgb:wlan-2"
	uci set system.led_pci3.sysfs="rgb:wlan-3"
	
	# nat6 is a helper for mwan3 on IPv6
	if ! uci -q get firewall.nat6 >/dev/null; then
		uci set firewall.nat6=include
		uci set firewall.nat6.path=/etc/firewall.nat6
	  uci set firewall.nat6.reload=1
	fi
	
	local ans
	if [ -z "$(uci changes)" ]; then
		ans="n"
	else
		IFS= ans=$(answer "The following UCI changes are proposed:\n$(uci changes)\nPerform the above changes to UCI config? [Y/n]? " "y" "$force_uci_commit")
	fi
	if [ "$ans" = "y" ]; then
		uci commit
	fi
}

[ "$skip_packages" != "1" ] && config_packages

[ "$skip_install" != "1" ] && install_files

[ "$skip_modify" != "1" ] && modify_files

[ "$skip_uci" != "1" ] && uci_config
