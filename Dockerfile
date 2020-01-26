FROM ich777/novnc-baseimage

LABEL maintainer="admin@minenet.at"

RUN export TZ=Europe/Rome && \
	apt-get update && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
	apt-get -y install --no-install-recommends sudo  && \
	rm -rf /var/lib/apt/lists/* && \
	sed -i '/    document.title =/c\    document.title = "DebianBuster - noVNC";' /usr/share/novnc/app/ui.js

ENV DATA_DIR=/userhome
ENV FORCE_UPDATE=""
ENV CUSTOM_RES_W=1280
ENV CUSTOM_RES_H=720
ENV UMASK=000
ENV UID=99
ENV GID=100

RUN mkdir $DATA_DIR	&& \
	useradd -d $DATA_DIR -s /bin/bash --uid $UID --gid $GID debian && \
	chown -R debian $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/ && \
	chown -R debian /opt/scripts/ && \

USER debian

#Server Start
ENTRYPOINT ["/opt/scripts/start-server.sh"]