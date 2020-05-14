#!/bin/bash
while true
do
	tail --pid=$killpid -f /dev/null
	if [ "${ENABLE_VNC_SRV}" == "true" ]; then
		kill "$(pidof x11vnc)"
		pkill [w]ebsockify
	fi
	kill "$(pidof tail)"
	exit 0
done