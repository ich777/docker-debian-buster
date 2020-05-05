#!/bin/bash
while true
do
		if ! pgrep Xorg >/dev/null ; then
				kill "$(pidof x11vnc)"
				pkill [w]ebsockify
				exit 0
		fi
		sleep 5
done