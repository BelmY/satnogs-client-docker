FROM knegge/satnogs-client:latest AS builder
WORKDIR /
USER root

# install build env and required libs etc
RUN apt update && apt install -y swig feh cmake build-essential gnuradio-dev libusb-1.0-0-dev libsoapysdr-dev libpng-dev libsndfile-dev fakeroot psmisc ninja-build autoconf automake libtool patch librtlsdr-dev

# install everything in /target and it will go in to / on destination image. symlink make it easier for builds to find files installed by this.
RUN mkdir -p /target/usr && rm -rf /usr/local && ln -sf /target/usr /usr/local

# install gr-satellites
#RUN git clone -b maint-3.8 --depth=1 https://github.com/daniestevez/gr-satellites.git
#RUN cd gr-satellites &&\
#    cmake -B build -DCMAKE_INSTALL_PREFIX=/target/usr &&\
#    cmake --build build --target install

# install beesat-sdr for mobitex support
RUN git clone -b maint-3.8 --depth=1 https://github.com/daniestevez/beesat-sdr.git
RUN cd beesat-sdr/gr-tnc_nx &&\
    cmake -B build -DCMAKE_INSTALL_PREFIX=/target/usr -DCMAKE_BUILD_TYPE=Release &&\
    cmake --build build --target install

# SSDV with support for DSLWP and JY1SAT modes
RUN git clone --depth=1 https://github.com/daniestevez/ssdv.git
RUN cd ssdv &&\
    make DESTDIR=/target install

# install satnogs_gr-satellites
RUN git clone --depth=1 https://github.com/kng/satnogs_gr-satellites.git
RUN cd satnogs_gr-satellites &&\
    make DESTDIR=/target PREFIX=/usr install

# install mirisdr
RUN git clone https://github.com/ericek111/libmirisdr-5.git
RUN cd libmirisdr-5 &&\
    cmake -B build -DCMAKE_INSTALL_PREFIX=/target/usr -DCMAKE_BUILD_TYPE=Release &&\
    cmake --build build --target install

# install soapymiri
RUN git clone https://github.com/ericek111/SoapyMiri.git
RUN cd SoapyMiri &&\
    cmake -B build -DCMAKE_INSTALL_PREFIX=/target/usr/local -DCMAKE_BUILD_TYPE=Release &&\
    cmake --build build --target install

# install aptdec
RUN git clone --recursive https://github.com/Xerbo/aptdec.git
RUN cd aptdec &&\
    cmake -B build -DCMAKE_INSTALL_PREFIX=/target/usr -DCMAKE_BUILD_TYPE=Release &&\
    cmake --build build --target install

# fpc is a quite big install, build meted
##RUN apt install -y fpc --no-install-recommends
#RUN git clone https://github.com/artlav/meteor_decoder.git
#RUN cd meteor_decoder && mkdir units &&\
#    fpc -CX -XX -O3 -Mdelphi -FUunits -Fualib medet.dpr &&\
#    cp medet /target/usr/bin

# satellite orbit prediction for tle
RUN git clone -b v2.0.0 https://github.com/la1k/libpredict.git
RUN cd libpredict &&\
    cmake -B build -DCMAKE_INSTALL_PREFIX=/target/usr -DCMAKE_BUILD_TYPE=Release &&\
    cmake --build build --target install

# needs qt5 in base image ?
#RUN apt install -y qtbase5-dev libmuparser-dev libshp-dev
#RUN git clone https://github.com/Xerbo/LeanHRPT-Decode.git
#RUN cd LeanHRPT-Decode &&\
#    cmake -B build -DCMAKE_INSTALL_PREFIX=/target/usr &&\
#    cmake --build build --target install

# kalibrate for rtl_sdr
RUN git clone https://github.com/steve-m/kalibrate-rtl.git
RUN cd kalibrate-rtl &&\
    ./bootstrap &&\
    CXXFLAGS='-W -Wall -O3' ./configure &&\
    make &&\
    cp src/kal /target/usr/bin

# rx_fm rx_power rx_sdr
RUN git clone --depth=1 https://github.com/rxseger/rx_tools.git
RUN cd rx_tools &&\
    cmake -B build -DCMAKE_INSTALL_PREFIX=/target/usr -DCMAKE_BUILD_TYPE=Release &&\
    cmake --build build --target install

# rffft from strf
RUN git clone --depth=1 https://github.com/cbassa/strf.git
RUN cd strf && make rffft && cp rffft /target/usr/bin

# test run flowgraph with current settings
COPY test-flowgraph.sh \
     wf2png.py \
     liveupdate-satyaml.sh \
     uhd_images_downloader.py \
     satnogs-post \
     satnogs-pre \
     iq_dump_rename.sh \
     bandscan.sh \
     /target/usr/bin/
COPY --chown=satnogs:satnogs sat.cfg /target/var/lib/satnogs/.gr_satellites/sat.cfg

ENTRYPOINT []
CMD ["bash"]

FROM knegge/satnogs-client:latest
COPY --from=builder /target /

