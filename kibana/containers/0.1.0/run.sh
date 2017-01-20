#!/bin/bash

set -e
PLUGIN_TXT=${PLUGIN_TXT:-/data/confd/plugins.txt}

while [ ! -f "/usr/share/kibana/config/kibana.yml" ]; do
    sleep 1
done

if [ -f "$PLUGIN_TXT" ]; then
    for plugin in $(<"${PLUGIN_TXT}"); do
        /usr/share/kibana/bin/kibana-plugin install $plugin
    done
    rm $PLUGIN_TXT
fi

mkdir -p /usr/share/kibana/config/x-pack/
cp /usr/share/elasticsearch/config/x-pack/system_key /usr/share/kibana/config/x-pack/system_key
chown -R kibana:kibana /usr/share/kibana/config/x-pack/

exec /docker-entrypoint.sh kibana
