FROM ich777/novnc-baseimage

LABEL maintainer="admin@minenet.at"

RUN export TZ=Europe/Rome && \
	apt-get update && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
	DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends man-db hdparm udev whiptail reportbug init vim-common iproute2 nano gdbm-l10n less iputils-ping netcat-traditional perl bzip2 gettext-base manpages file liblockfile-bin python3-reportbug libnss-systemd isc-dhcp-common systemd-sysv xz-utils perl-modules-5.28 debian-faq wamerican bsdmainutils systemd cpio logrotate traceroute dbus kmod isc-dhcp-client telnet krb5-locales lsof debconf-i18n cron ncurses-term iptables ifupdown procps rsyslog apt-utils netbase pciutils bash-completion vim-tiny groff-base apt-listchanges bind9-host doc-debian libpam-systemd openssh-client xfce4 xorg dbus-x11 sudo gvfs-backends gvfs-common gvfs-fuse gvfs firefox-esr && \
	rm -rf /var/lib/apt/lists/* && \
	sed -i '/    document.title =/c\    document.title = "DebianBuster - noVNC";' /usr/share/novnc/app/ui.js

ENV DATA_DIR=/userhome
ENV FORCE_UPDATE=""
ENV CUSTOM_RES_W=1280
ENV CUSTOM_RES_H=720
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="debian"
ENV ROOT_PWD="Docker!"

RUN mkdir $DATA_DIR	&& \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]