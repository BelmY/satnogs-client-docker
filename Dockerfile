# satnogs-client 1.8
FROM debian:bullseye
MAINTAINER sa2kng <knegge@gmail.com>

RUN apt-get -y update && apt-get -y install wget gnupg lsb-release && rm -rf /var/lib/apt/lists/*
RUN echo "deb http://download.opensuse.org/repositories/home:/librespace:/satnogs/Debian_11/ ./" > /etc/apt/sources.list.d/satnogs.list
RUN echo "deb http://archive.raspberrypi.org/debian/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/raspi.list
RUN wget -qO - http://download.opensuse.org/repositories/home:/librespace:/satnogs/Debian_11/Release.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/satnogs.gpg
RUN wget -qO - http://archive.raspberrypi.org/debian/raspberrypi.gpg.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/raspi.gpg

RUN apt-get -y update && apt -y upgrade && apt-get -y install --no-install-recommends libhamlib-utils vorbis-tools unzip git python3-pip rtl-sdr satnogs-flowgraphs gr-soapy gr-satnogs libhdf5-103 python3-virtualenv virtualenv python3-libhamlib2 python3-six python3-requests soapysdr-module-all soapysdr-tools python3-construct jq soapysdr-module-plutosdr soapysdr-module-airspyhf python3-gps gr-satellites && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 995 satnogs && useradd -g satnogs -G dialout,plugdev -m -d /var/lib/satnogs -s /bin/bash -u 999 satnogs
RUN chown satnogs:satnogs -R /usr/lib/python3/dist-packages/satellites/satyaml

WORKDIR /var/lib/satnogs
USER satnogs
RUN virtualenv -p python3 --system-site-packages . && . bin/activate && pip3 install git+https://gitlab.com/librespacefoundation/satnogs/satnogs-client.git --prefix=/var/lib/satnogs --prefer-binary --extra-index-url https://www.piwheels.org/simple && rm -rf .cache/pip/
RUN mkdir -p .gnuradio/prefs/ && echo -n "gr::vmcircbuf_sysv_shm_factory" > .gnuradio/prefs/vmcircbuf_default_factory
# Alternatively: gr::vmcircbuf_mmap_shm_open_factory

COPY entrypoint.sh /
ENTRYPOINT ["bash", "/entrypoint.sh"]
CMD ["satnogs-client"]

