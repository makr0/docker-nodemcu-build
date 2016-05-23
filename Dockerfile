FROM ubuntu
MAINTAINER makr0

# If you want to tinker with this Dockerfile on your machine do as follows:
# - git clone https://github.com/marcelstoer/docker-nodemcu-build
# - vim docker-nodemcu-build/Dockerfile
# - docker build -t docker-nodemcu-build docker-nodemcu-build
# - cd <nodemcu-firmware>
# - docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware docker-nodemcu-build

RUN apt-get update -y && apt-get install -y wget unzip git make python-serial srecord bc
RUN mkdir /opt/nodemcu-firmware
WORKDIR /opt/nodemcu-firmware

# Config options you may pass via Docker like so 'docker run -e "<option>=<value>"':
# - IMAGE_NAME=<name>, define a static name for your .bin files
# - INTEGER_ONLY=1, if you want the integer firmware
# - FLOAT_ONLY=1, if you want the floating point firmware
#
# What the commands do:
# - store the Git branch in 'BRANCH'
# - unpack esp-open-sdk.tar.gz in a directory that is NOT the bound mount directory (i.e. inside the Docker image)
# - remove all files in <firmware-dir>/bin
# - make a float build if !only-integer
# - copy and rename the mapfile to bin/
# - make an integer build
# - copy and rename the mapfile to bin/
ADD runbuild.sh /home
RUN chmod +x /home/runbuild.sh
CMD '/home/runbuild.sh'
