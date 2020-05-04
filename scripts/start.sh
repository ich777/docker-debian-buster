#!/bin/bash
echo "---Checking if UID: ${UID} matches user---"
usermod -u ${UID} ${USER}
echo "---Checking if GID: ${GID} matches user---"
usermod -g ${GID} ${USER}
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "root:${ROOT_PWD}" | chpasswd

echo "---Checking for optional scripts---"
if [ -f /opt/scripts/user.sh ]; then
	echo "---Found optional script, executing---"
    chmod +x /opt/scripts/user.sh
    /opt/scripts/user.sh
else
	echo "---No optional script found, continuing---"
fi

if [ -z "${DFP_NR}" ]; then
	echo "------------------------------------------------------"
	echo "-------'DFP_NR' is empty please make sure that--------"
	echo "---you've connected a monitor to the Graphics Card----"
	echo "---otherwise the container will not properly start!---"
	echo "------------------------------------------------------"
	sleep 10
fi

if [ -z "${PCI_ADDR}" ]; then
echo "---Trying to get Nvidia device address---"
export PCI_ADDR="$(nvidia-smi | grep 0000 | cut -d '|' -f3 | cut -d ':' -f2,3 | cut -d ' ' -f1)"
	if [ -z "${PCI_ADDR}" ]; then
		echo "---Something went wrong, can't get device address, putting server into sleep mode---"
		sleep infinity
	else
		echo "---Successfully got device ID: ${PCI_ADDR}---"
	fi
PCI_ADDR=PCI:"${PCI_ADDR/./:}"
fi

if [ -z "${NV_DRV_V}" ]; then
echo "---Trying to get Nvidia driver version---"
export NV_DRV_V="$(nvidia-smi | grep NVIDIA-SMI | cut -d ' ' -f3)"
	if [ -z "${NV_DRV_V}" ]; then
		echo "---Something went wrong, can't get driver version, putting server into sleep mode---"
		sleep infinity
	else
		echo "---Successfully got driver version: ${NV_DRV_V}---"
	fi
fi

echo "---Checking Xwrapper.config---"
if grep -rq 'allowed_users=anybody' /etc/X11/Xwrapper.config; then
	echo "---Xwrapper.config properly configured---"
else
	echo "---Configuring Xwrapper.config---"
	sed -i '/allowed_users=/c\allowed_users=anybody' /etc/X11/Xwrapper.config
fi

INSTALL_V="$(find ${DATA_DIR} -name NVIDIA_*\.run | cut -d '_' -f 2 | cut -d '.' -f 1,2)"

if [ ! -z "$INSTALL_V" ]; then
	if [ "$INSTALL_V" != "${NV_DRV_V}" ]; then
		echo "---Version missmatch, deleting local Nvidia Driver v$INSTALL_V---"
		rm ${DATA_DIR}/NVIDIA_$INSTALL_V.run
	fi
fi

if [ ! -f /usr/bin/nvidia-settings ]; then
	if [ -f ${DATA_DIR}/NVIDIA_${NV_DRV_V}.run ]; then
		echo "---Found NVIDIA Driver v${NV_DRV_V} localy, installing...---"
		${DATA_DIR}/NVIDIA_${NV_DRV_V}.run ${NVIDIA_BUILD_OPTS} > /dev/null 2>&1
	else
		echo "---Downloading and installing Nvidia Driver v${NV_DRV_V}---"
		wget -q --show-progress --progress=bar:force:noscroll -O /tmp/NVIDIA.run http://download.nvidia.com/XFree86/Linux-x86_64/${NV_DRV_V}/NVIDIA-Linux-x86_64-${NV_DRV_V}.run && \
		chmod +x /tmp/NVIDIA.run && \
		/tmp/NVIDIA.run ${NVIDIA_BUILD_OPTS} > /dev/null 2>&1 && \
		mv /tmp/NVIDIA.run ${DATA_DIR}/NVIDIA_${NV_DRV_V}.run
	fi
fi

sed -i "/BusID/c\\\tBusID\t\"${PCI_ADDR}\"" /etc/X11/xorg.conf

if [ ! -z "${DFP_NR}" ]; then
	sed -i "/Option\\t\"ConnectedMonitor\"/c\\\tOption\t\"ConnectedMonitor\" \"DFP-${DFP_NR}\"" /etc/X11/xorg.conf
	sed -i "/Option\\t\"CustomEDID\"/c\\\tOption\t\"CustomEDID\" \"DFP${DFP_NR}:${DATA_DIR}/edid.txt\"" /etc/X11/xorg.conf
else
	sed -i "/Option\\t\"ConnectedMonitor\"/c\\\tOption\t\"ConnectedMonitor\"" /etc/X11/xorg.conf
	sed -i "/Option\\t\"CustomEDID\"/c\\\tOption\t\"CustomEDID\"" /etc/X11/xorg.conf
fi

if [ ! -d /tmp/xdg ]; then
	mkdir -p /tmp/xdg
fi

echo "---Configuring Locales to: ${USER_LOCALES}---"
LOCALE_GEN=$(head -n 1 /etc/locale.gen)
export LOCALE_USR=$(echo ${USER_LOCALES} | cut -d ' ' -f 1)

if [ "$LOCALE_GEN" != "${USER_LOCALES}" ]; then
	rm /etc/locale.gen
	echo "${USER_LOCALES}" > "/etc/locale.gen"
	export LANGUAGE="$LOCALE_USR"
	export LANG="$LOCALE_USR"
	export LC_ALL="$LOCALE_USR" 2> /dev/null
	sleep 2
	locale-gen
	update-locale LC_ALL="$LOCALE_USR"
else
	echo "---Locales set correctly, continuing---"
fi

echo "---Starting...---"
rm -R ${DATA_DIR}/.dbus/session-bus/* 2> /dev/null
chown -R ${UID}:${GID} /opt/scripts
if [ ! -f ${DATA_DIR}/edid.txt ]; then
	cp /tmp/edid.txt ${DATA_DIR}/edid.txt
fi
chown -R ${UID}:${GID} /tmp/xdg
chmod -R 0700 /tmp/xdg
dbus-uuidgen > /var/lib/dbus/machine-id
rm -R /tmp/.* 2> /dev/null
mkdir -p /tmp/.ICE-unix
chown root:root /tmp/.ICE-unix/ 
chown -R ${UID}:${GID} ${DATA_DIR}
chown -R ${UID}:${GID} /tmp/config
killpid=0 >/dev/null
term_handler() {
        if [ $killpid -ne 0 ]; then
                su ${USER} -c "xfce4-session-logout --halt"                
                kill -SIGTERM "$killpid"
                wait "$killpid"
        fi
        exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM
su ${USER} -c "/opt/scripts/start-server.sh" &
killpid="$!"
while true
do
        if ! pgrep -f start-server.sh >/dev/null ; then
                exit 0
        fi
        sleep 2
done