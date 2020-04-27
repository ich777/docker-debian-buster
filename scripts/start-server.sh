#!/bin/bash
export LANG=en_US.UTF-8
export DISPLAY=:99
export XDG_RUNTIME_DIR=/tmp

echo "---Preparing Server---"
if [ -d ${DATA_DIR}/.logs ]; then
	mkdir ${DATA_DIR}/.logs
fi
if [ ! -d ${DATA_DIR}/.local/share/applications ]; then
	mkdir -p ${DATA_DIR}/.local/share/applications
fi
if [ ! -f ${DATA_DIR}/.local/share/applications/debian-uxterm.desktop  ]; then
	cp /usr/share/applications/debian-uxterm.desktop ${DATA_DIR}/.local/share/applications/
	echo "Hidden=true" >> ${DATA_DIR}/.local/share/applications/debian-uxterm.desktop
fi
if [ ! -f ${DATA_DIR}/.local/share/applications/x11vnc.desktop  ]; then
	cp /usr/share/applications/x11vnc.desktop ${DATA_DIR}/.local/share/applications/
	echo "Hidden=true" >> ${DATA_DIR}/.local/share/applications/x11vnc.desktop
fi

echo "---Checking for old logfiles---"
find ${DATA_DIR}/.logs -name "XvfbLog.*" -exec rm -f {} \;
find ${DATA_DIR}/.logs -name "x11vncLog.*" -exec rm -f {} \;
echo "---Checking for old lock files---"
find /tmp -name ".X99*" -exec rm -f {} \;
chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Starting Xvfb server---"
screen -S Xvfb -L -Logfile ${DATA_DIR}/.logs/XvfbLog.0 -d -m /opt/scripts/start-Xvfb.sh
sleep 2

echo "---Starting x11vnc server---"
screen -S x11vnc -L -Logfile ${DATA_DIR}/.logs/x11vncLog.0 -d -m /opt/scripts/start-x11.sh
sleep 2

echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem 8080 localhost:5900
sleep 2

echo "---Starting Desktop---"
if [ "${DEV}" == "true" ]; then
	startxfce4
else
	startxfce4 > /dev/null
fi