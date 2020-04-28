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

if [ ! -d /tmp/xdg ]; then
	mkdir /tmp/xdg
fi

echo "---Configuring Locales to: ${USER_LOCALES}---"
LOCALE_GEN=$(head -n 1 /etc/locale.gen)
LOCALE_USR=$(echo ${USER_LOCALES} | cut -d ' ' -f 1)

if [ "$LOCALE_GEN" != "${USER_LOCALES}" ]; then
	rm /etc/locale.gen
	echo "${USER_LOCALES}" > "/etc/locale.gen"
	export LANGUAGE="$LOCALE_USR"
	export LANG="$LOCALE_USR"
	sleep 2
	locale-gen
	export LC_ALL=${USER_LOCALES}
	update-locale LC_ALL=${USER_LOCALES}
else
	echo "---Locales set correctly, continuing---"
fi

echo "---Starting...---"
rm -R ${DATA_DIR}/.dbus/session-bus/* 2> /dev/null
rm -R ${DATA_DIR}/.cache 2> /dev/null
chown -R ${UID}:${GID} /opt/scripts
chown -R ${UID}:${GID} /tmp/xdg
chmod -R 0700 /tmp/xdg
dbus-uuidgen > /var/lib/dbus/machine-id
rm -R /tmp/.* 2> /dev/null
chown -R ${UID}:${GID} ${DATA_DIR}
chown -R ${UID}:${GID} /tmp/config
su ${USER} -c "/opt/scripts/start-server.sh"