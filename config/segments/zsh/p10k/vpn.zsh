# segment: vpn
# description: Shows VPN connection name when active
# elements: vpn_ip
typeset -g POWERLEVEL9K_VPN_IP_FOREGROUND=81
typeset -g POWERLEVEL9K_VPN_IP_CONTENT_EXPANSION='${P9K_IP_VPN0_IP//\/*}'
typeset -g POWERLEVEL9K_VPN_IP_VISUAL_IDENTIFIER_EXPANSION='##ICON##'
