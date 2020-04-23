#!/bin/bash
export LANG=en_US.UTF-8
export DISPLAY=:99

echo "---Preparing Server---"
echo "---Checking for old logfiles---"
find $DATA_DIR -name "XvfbLog.*" -exec rm -f {} \;
find $DATA_DIR -name "x11vncLog.*" -exec rm -f {} \;
echo "---Checking for old lock files---"
find /tmp -name ".X99*" -exec rm -f {} \;
find /var/run/dbus -name "pid" -exec rm -f {} \;
chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Starting dbus service---"
if dbus-daemon --config-file=/usr/share/dbus-1/system.conf ; then
	echo "---dbus service started---"
else
	echo "---Couldn't start dbus service---"
	sleep infinity
fi
sleep 2

echo "---Starting Xvfb server---"
screen -S Xvfb -L -Logfile ${DATA_DIR}/XvfbLog.0 -d -m /opt/scripts/start-Xvfb.sh
sleep 2

echo "---Starting x11vnc server---"
screen -S x11vnc -L -Logfile ${DATA_DIR}/x11vncLog.0 -d -m /opt/scripts/start-x11.sh
sleep 2

echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem 8080 localhost:5900
sleep 2

sleep infinity

echo "---Starting Desktop---"
mate-session