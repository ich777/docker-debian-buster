#!/bin/bash
while true
do
        if pgrep Xorg >/dev/null ; then
        else
                if [ "${ENABLE_VNC_SRV}" == "true" ]; then
                        kill "$(pidof x11vnc)"
                        pkill [w]ebsockify
                fi
                kill "$(pidof tail)"
                exit 0
        fi
        sleep 5
done