##########################################################################################
# mcuxpresso Dockerfile installation:
#
# build:
#
# docker build -t mcuxpresso .
#
# run:
#
# docker run -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY mcuxpresso
# if running dockerd as superuser, you need to first run xhost +local:root to run the GUI.
=======
#
# See https://dexvis.wordpress.com/2016/04/04/running-javafx-in-a-docker-container/
##########################################################################################

FROM ubuntu:18.04
LABEL Description="Image for buiding arm project with mcuxpresso"
WORKDIR /work
# Pull base image.

ENV SDK_VERSION 2.8.0
ENV TARGET LPC845
ENV IDE_VERSION 11.3.0_5222
ENV JLINK_PKG JLink_Linux_x86_64.deb

LABEL Description="Image for buiding arm project with mcuxpresso"
WORKDIR /work
Run apt update


ENV SDK SDK_${SDK_VERSION}_${TARGET}.zip
ENV BASENAME mcuxpressoide-${IDE_VERSION}
ENV IDE ${BASENAME}.x86_64 
COPY ./${IDE}.deb.bin /work
COPY ./${SDK} /work


RUN apt install -y \
# Development files
      whiptail \
      build-essential \
      bzip2 \
      libswt-gtk-3-jni \
      libswt-gtk-3-java \
      wget && \
    apt clean

#dpkg --add-architecture i386 && apt-get update &&\
#RUN apt-get install -y libusb-1.0-0-dev dfu-util 
#RUN apt-get install libwebkit2gtk-4.0-37
RUN apt-get install libwebkitgtk-1.0-0
RUN apt-get install lsbutils
  #apt-get install libncurses5:i386 udev &&\

# install mcuxpresso
RUN chmod a+x ${IDE}.deb.bin
  # Extract the installer to a deb package
RUN ./${IDE}.deb.bin --noexec --target mcu &&\
    cd mcu &&\
    dpkg --add-architecture i386 && apt-get update &&\
    apt-get install -y libusb-1.0-0-dev dfu-util libncurses5:i386 udev &&\
    dpkg -i --force-depends ${JLINK_PKG} &&\
    # manually install mcuxpressoide - post install script fails
    dpkg --unpack ${IDE}.deb &&\
    rm /var/lib/dpkg/info/mcuxpressoide.postinst -f &&\
    dpkg --configure mcuxpressoide &&\
    apt-get install -yf &&\
    # manually run the postinstall script
    mkdir -p /usr/share/NXPLPCXpresso &&\
    chmod a+w /usr/share/NXPLPCXpresso &&\
    ln -s /usr/local/mcuxpressoide-${IDE_VERSION} /usr/local/mcuxpressoide

ENV TOOLCHAIN_PATH /usr/local/mcuxpressoide/ide/tools/bin
ENV PATH $TOOLCHAIN_PATH:$PATH

# add the sdk package
RUN mkdir -p /root/mcuxpresso/01/SDKPackages &&\
  mv ${SDK} /root/mcuxpresso/01/SDKPackages

RUN ln -s /usr/local/${BASENAME}/ide/mcuxpressoide /bin/mcuxpressoide
RUN rm ${IDE}.deb.bin
RUN rm -rf mcu
