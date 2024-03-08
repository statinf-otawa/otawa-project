FROM ubuntu:22.04

# To run obviews, you may need to install the following (and libgtk-3-dev)
# add-apt-repository --yes ppa:mozillateam/ppa && \
# apt update  && \
# apt install -y firefox-esr && \
# update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox-esr 10 && \

RUN apt update && apt upgrade -y && apt install -y software-properties-common && \
    DEBIAN_FRONTEND=noninteractive apt -y --no-install-recommends install \
    libxml2-dev libxslt1-dev libtinfo5 sudo vim-nox g++ ocaml flex bison cmake build-essential perl graphviz dbus-x11 git  python3.10-dev python3-pip && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    useradd -m statinf && \
    echo statinf:statinf | chpasswd && \
    cp /etc/sudoers /etc/sudoers.bak && \
    echo 'statinf  ALL=(root) NOPASSWD: ALL' >> /etc/sudoers

ARG OTAWA_INSTALL_DIR=/tmp/otawa-install

ENV DISPLAY=:0
ENV PATH="$PATH:$OTAWA_INSTALL_DIR/bin"

# git equivalent: RUN git clone --branch=aarch64 --recursive https://github.com/jordr/otawa-project otawa-project
USER statinf
WORKDIR /home/statinf
# also works, but with less caching:
COPY --chown=statinf:statinf . /home/statinf/otawa-project/
WORKDIR /home/statinf/otawa-project

# Install OTAWA core
RUN cd ./elm             && cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR . && make install -j4
RUN cd ./gel             && cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR . && make install -j4
RUN cd ./gelpp           && cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR . && make install -j4
RUN cd ./otawa           && cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR . && make install -j4

# Install an ILP solver
RUN cd ./lp_solve5       && cmake . && make 
RUN cd ./otawa-lp_solve5 && cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR . -DOTAWA_CONFIG=$OTAWA_INSTALL_DIR/bin/otawa-config . && make && make install
# Install CFG visualiser
RUN cd ./obviews         && cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR . && make install
# Install stuffs for Xilinx platform support
RUN cd ./otawa-clp      && cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR . && make install
RUN cd ./otawa-dcache      && cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR . && make install

# Install some archs
RUN cd ./archs/gliss2    && make
RUN cd ./archs/armv5t;  make; cd ..;\
    cd armv7t;  make WITH_FAST_STATE=1;\
    cd ../otawa-arm; cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR -DOTAWA_CONFIG=$OTAWA_INSTALL_DIR/bin/otawa-config . && make install
RUN cd aarch64-armv8v9 ; make; cd ..;\
    cd otawa-aarch64 ; cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR -DOTAWA_CONFIG=$OTAWA_INSTALL_DIR/bin/otawa-config . && make install
RUN cd ./archs/ppc;     make WITH_DYNLIB=1;     cd ../otawa-ppc;     cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR -DOTAWA_CONFIG=$OTAWA_INSTALL_DIR/bin/otawa-config . && make install
RUN cd ./archs/riscv;   make WITH_DYNLIB=1;     cd ../otawa-riscv;   cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR -DOTAWA_CONFIG=$OTAWA_INSTALL_DIR/bin/otawa-config . && make install
RUN cd ./archs/tricore; make WITH_DYNLIB=1 ; cd ../otawa-tricore; cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR -DOTAWA_CONFIG=$OTAWA_INSTALL_DIR/bin/otawa-config . && make install
#RUN cd ./archs/tms;     make WITH_DYNLIB=1; cd ../otawa-tms;     cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR -DOTAWA_CONFIG=$OTAWA_INSTALL_DIR/bin/otawa-config . && make install

RUN cd ./archs/otawa-xilinx ; cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR . && make install

