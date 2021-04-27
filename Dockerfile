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
#
# See https://dexvis.wordpress.com/2016/04/04/running-javafx-in-a-docker-container/
##########################################################################################

FROM ubuntu:18.04
LABEL Description="Image for buiding arm project with mcuxpresso"
WORKDIR /work

ENV SDK_VERSION 2.8.0
ENV SDK SDK_${SDK_VERSION}_LPC845.zip
ENV IDE_VERSION 11.3.0_5222
ENV IDE mcuxpressoide-${IDE_VERSION}.x86_64 
ENV JLINK_PKG JLink_Linux_x86_64.deb
COPY ./${IDE}.deb.bin /work
COPY ./${SDK} /work

# Install any needed packages specified in requirements.txt
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
# Development files
      whiptail \
      build-essential \
      bzip2 \
      libswt-gtk-3-jni \
      libswt-gtk-3-java \
      wget && \
    apt clean

# install mcuxpresso
RUN chmod a+x ${IDE}.deb.bin &&\
  # Extract the installer to a deb package
  ./${IDE}.deb.bin --noexec --target mcu &&\
  cd mcu &&\
  dpkg --add-architecture i386 && apt-get update &&\
  apt-get install -y libusb-1.0-0-dev dfu-util libwebkit2gtk-4.0-37 libncurses5:i386 udev &&\
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

RUN rm ${IDE}.deb.bin
RUN rm -rf mcu
