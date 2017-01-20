#!/bin/bash

set -e 
PLUGIN_TXT=${PLUGIN_TXT:-/data/confd/plugins.txt}

while [ ! -f "/usr/share/elasticsearch/config/elasticsearch.yml" ]; do
    sleep 1
done

if [ -f "$PLUGIN_TXT" ]; then
    for plugin in $(<"${PLUGIN_TXT}"); do
        /usr/share/elasticsearch/bin/elasticsearch-plugin install $plugin
    done
    rm $PLUGIN_TXT
fi

if [ ! -z $master ] && [ ! -f "/usr/share/elasticsearch/config/x-pack/system_key" ]; then
    mkdir -p /usr/share/elasticsearch/config/x-pack/
    ./bin/x-pack/syskeygen
    chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/config/x-pack/
fi

while [ ! -f "/usr/share/elasticsearch/config/x-pack/system_key" ]; do
    echo "WAITING"
    sleep 2
done

if [ ! -z $master ]; then
    exec /opt/rancher/bin/post-run.sh & /docker-entrypoint.sh elasticsearch
else
    exec /docker-entrypoint.sh elasticsearch
fi
