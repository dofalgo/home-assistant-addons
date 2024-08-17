#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: GandiDns
#
# GandiDNS add-on for Hass.io.
# This add-on update public IP on Gandi API.
# ==============================================================================

get_current_ip() {
    echo "$(curl -s ifconfig.me)"
}

get_gandi_ip() {
    domain=$1
    reccord=$2
    api_auth_scheme=$3
    api_key=$4
    
    bashio::log.debug "[Gandi] - Get data for - ${domain} - ${reccord}"
    echo "$(curl -s -H "Authorization: ${api_auth_scheme} ${api_key}" https://api.gandi.net/v5/livedns/domains/${domain}/records/${reccord} | jq -r '.[].rrset_values[0]')"
}

update_gandi_ip() {
    domain=$1
    reccord=$2
    api_auth_scheme=$3
    api_key=$4
    ip=$5
    payload='{"items": [{"rrset_type": "A","rrset_values": ["'"${ip}"'"],"rrset_ttl": 300}]}'
    bashio::log.debug "[Gandi] - Update reccord - ${domain} - ${reccord}"
    echo "$(curl -s -g -X PUT -H "Content-Type: application/json" -d "${payload}" -H "Authorization: ${api_auth_scheme} ${api_key}" https://api.gandi.net/v5/livedns/domains/${domain}/records/${reccord})"

}
# ==============================================================================
# RUN LOGIC
# ------------------------------------------------------------------------------
main() {
    local domain
    local reccords
    local api_auth_scheme
    local api_key
    local current_ip
    local gandi_ip


    domain=$(bashio::config 'domain')
    reccords=$(bashio::config 'reccords')
    api_auth_scheme=$(bashio::config 'api_auth_scheme')
    api_key=$(bashio::config 'api_key')

    bashio::log.trace "${FUNCNAME[0]}"
    bashio::log.info "Updater Started"
    while true; do
        current_ip=$(get_current_ip)
        bashio::log.debug "Current ip is ${current_ip}"

        gandi_ip=$(get_gandi_ip "${domain}" "${reccords[0]}" "${api_auth_scheme}" "${api_key}")
        bashio::log.debug "Gandi ip is ${gandi_ip}"

        if [ "${current_ip}" = "${gandi_ip}" ]; then
            bashio::log.debug "IP's are correct"
            sleep 600
        else
            bashio::log.debug "Ip did not match, need an update"
            for reccord in ${reccords}
            do
                bashio::log.debug "Updating reccord ${reccord}"
                res=$(update_gandi_ip "${domain}" "${reccord}" "${api_auth_scheme}" "${api_key}" "${current_ip}")
                bashio::log.debug "Reccord ${res}"
                bashio::log.info "[GandiDns] - Domain ${reccord}.${domain} updated with IP ${current_ip}"
            done
        sleep 600
        fi
    done
    
}
main "$@"
