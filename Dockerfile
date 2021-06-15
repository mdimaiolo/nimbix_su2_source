FROM ubuntu:18.04
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y \
    python3-dev \
    pkg-config \
    python3-pip \
    git \
    build-essential \
    gcc \
    g++ \
    python3-setuptools \
    libopenmpi-dev \
    openmpi-bin \
    python3-mpi4py \
    swig \
    python3-numpy \
    python3-scipy
	
RUN apt remove -y mpich

# Copy from nimbix/image-common
RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install curl && \
    curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/image-common/master/install-nimbix.sh \
        | bash

# Expose port 22 for local JARVICE emulation in docker
EXPOSE 22

# Change working directory
WORKDIR /usr/local

# Create a directory to compile SU2 - this will later have a symbolic link created to it
RUN mkdir -p /usr/local/SU2
RUN mkdir -p /usr/local/nimbix_su2

# Add all source files to the newly created directory
ADD --chown=root:root ./ /usr/local/SU2

# Ensure full access
RUN sudo chmod -R 0777 /usr/local/SU2
RUN sudo chmod -R 0777 /usr/local/nimbix_su2

# Save Nimbix AppDef
COPY ./NAE/AppDef.json /etc/NAE/AppDef.json

# This is a marker - the actual init.sh call is in AppDef.json
CMD /usr/local/SU2/init/init.sh
