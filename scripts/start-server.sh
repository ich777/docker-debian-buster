#!/bin/bash
export DISPLAY=${DISPLAY}
export XDG_RUNTIME_DIR=/tmp/xdg
export LANGUAGE="$LOCALE_USR"
export LANG="$LOCALE_USR"

echo "---Preparing Server---"
if [ ! -d ${DATA_DIR}/.config/xfce4/xfconf/xfce-perchannel-xml/ ]; then
	mkdir -p ${DATA_DIR}/.config/xfce4/xfconf/xfce-perchannel-xml/
fi
if [ ! -f ${DATA_DIR}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml ]; then
	cp /tmp/config/xfce4-desktop.xml ${DATA_DIR}/.config/xfce4/xfconf/xfce-perchannel-xml/
fi
if [ ! -f ${DATA_DIR}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
	cp /tmp/config/xsettings.xml ${DATA_DIR}/.config/xfce4/xfconf/xfce-perchannel-xml/
fi
if [ ! -d ${DATA_DIR}/.logs ]; then
	mkdir ${DATA_DIR}/.logs
fi
if [ ! -d ${DATA_DIR}/.local/share/applications ]; then
	mkdir -p ${DATA_DIR}/.local/share/applications
fi
if [ ! -f ${DATA_DIR}/.local/share/applications/x11vnc.desktop  ]; then
	cp /usr/share/applications/x11vnc.desktop ${DATA_DIR}/.local/share/applications/
	echo "Hidden=true" >> ${DATA_DIR}/.local/share/applications/x11vnc.desktop
fi

echo "---Checking for old logfiles---"
find ${DATA_DIR}/.logs -name "startxLog.*" -exec rm -f {} \;
find ${DATA_DIR}/.logs -name "x11vncLog.*" -exec rm -f {} \;
echo "---Checking for old lock files---"
find /tmp -name ".X99*" -exec rm -f {} \;
chmod -R ${DATA_PERM} ${DATA_DIR}
screen -wipe 2&>/dev/null
find /var/run/dbus -name "pid" -exec rm -f {} \;

echo "---Starting dbus service---"
if dbus-daemon --config-file=/usr/share/dbus-1/system.conf ; then
	echo "---dbus service started---"
else
	echo "---Couldn't start dbus service---"
	sleep infinity
fi
sleep 2

echo "---Starting Xfce4---"
screen -S startx -L -Logfile ${DATA_DIR}/.logs/startxLog.0 -d -m /opt/scripts/start-startx.sh
sleep 2

if [ "${ENABLE_VNC_SRV}" == "true" ]; then
	echo "---Starting x11vnc server---"
	screen -S x11vnc -L -Logfile ${DATA_DIR}/.logs/x11vncLog.0 -d -m /opt/scripts/start-x11.sh
	sleep 2

	echo "---Starting noVNC server---"
	websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem ${NOVNC_PORT} localhost:${RFB_PORT}
	sleep 2
fi

echo "---Starting Pulseaudio server---"
pulseaudio --start

echo -e "----------------------------------------------------------------------------------------------------\nListing possible outputs and screen modes:\n\n '$(xrandr -q)'\n----------------------------------------------------------------------------------------------------"

echo -e "\n\n\n---Looks like your highest possible output on: '$(xrandr -q | grep -w "connected" | cut -d ' ' -f1)' is: '$(xrandr -q | grep -w "connected" -A 2 | tail -1 | cut -d ' ' -f4)'---\n\n\n"

if [ ! -f ${DATA_DIR}/.config/container.cfg ]; then
	echo "---Trying to set the resolution to: '$(xrandr -q | grep -w "connected" -A 2 | tail -1 | cut -d ' ' -f4)' on output: '$(xrandr -q | grep -w "connected" | cut -d ' ' -f1)'---"
	xrandr -d ${DISPLAY} --output $(xrandr -q | grep -w "connected" | cut -d ' ' -f1) --mode $(xrandr -q | grep -w "connected" -A 2 | tail -1 | cut -d ' ' -f4)
	echo
	echo "-------------------------------------------------------------------------------"
	echo "--------If you want to set the resolution manually please create a file--------"
	echo "---------in /debian/.config/container.cfg with the following contents:---------"
	echo "-------------------------------------------------------------------------------"
	echo "Resolution: 1920x1080"
	echo "Output: HDMI-0"
	echo "--------------------------------------------------------------------------------"
	echo "---Change the resolution and output to your specific configuration/preference---"
	echo "--------------------------------------------------------------------------------"
	echo
else
	echo "---Setting resolution to: $(grep "Resolution:" ${DATA_DIR}/.config/container.cfg | cut -d ' ' -f 2) on output: $(grep "Output:" ${DATA_DIR}/.config/container.cfg | cut -d ' ' -f 2)---"
	xrandr -d ${DISPLAY} --output $(grep "Output:" ${DATA_DIR}/.config/container.cfg | cut -d ' ' -f 2) --mode $(grep "Resolution:" ${DATA_DIR}/.config/container.cfg | cut -d ' ' -f 2)
	echo
fi
screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
sleep 5
tail -f ${DATA_DIR}/.logs/startxLog.0