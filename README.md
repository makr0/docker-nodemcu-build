# Docker NodeMCU build

What is this?

Clone and edit the [NodeMCU firmware](https://github.com/nodemcu/nodemcu-firmware) locally on your platform.

Then use this image to build the binary which you then can [flash to the ESP8266](http://nodemcu.readthedocs.org/en/dev/en/flash/).

## Usage
### Install Docker
Follow the instructions at [https://docs.docker.com/](https://docs.docker.com/) → 'Get Started' (orange button top right).

### Clone the NodeMCU firmware repository
`git clone https://github.com/nodemcu/nodemcu-firmware.git`

### build the Docker image
Start Docker and change to the directory of this README. Then run:
``docker build -t nodemcu-build .``
You need to do this every time you change the settings in runbuild.sh

### Run this image with Docker
Start Docker and change to the NodeMCU firmware directory (in the Docker console). Then run:
``docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware nodemcu-build``

Depending on the performance of your system it takes 1-3min until the compilation finishes. The first time you run this it takes longer because Docker needs to download the image and create a container.

#### Output
The two firmware files (integer and float) are created in the `bin` sub folder of your NodeMCU root directory. You will also find a mapfile in the `bin` folder with the same name as the firmware file but with a `.map` ending.

#### Options
You can pass the following optional parameters to the Docker build like so `docker run -e "<parameter>=value" -e ...`.

- `IMAGE_NAME` The default firmware file names are `nodemcu_float|integer_<branch>_<timestamp>.bin`. If you define an image name it replaces the `<branch>_<timestamp>` suffix and the full image names become `nodemcu_float|integer_<image_name>.bin`.
- `INTEGER_ONLY` Set this to 1 if you don't need NodeMCU with floating support, cuts the build time in half.
- `FLOAT_ONLY` Set this to 1 if you only need NodeMCU with floating support, cuts the build time in half.
- `X_MODULES` list of modules to compile. if omitted adc,bit,cjson,file,gpio,http,i2c,mqtt,net,node,ow,pwm,rtctime,spi,tmr,uart,wifi,ws2812 are compiled

### Flashing the built binary
There are several [tools to flash the firmware](http://nodemcu.readthedocs.org/en/dev/en/flash/) to the ESP8266. If you were to use [esptool](https://github.com/themadinventor/esptool) (like I do) you'd run:

`esptool.py --port <USB-port-with-ESP8266> write_flash 0x00000 <NodeMCU-firmware-directory>/bin/nodemcu_[integer|float]_<Git-branch>.bin `

## Support
Don't leave comments on Docker Hub that are intended to be support requests. First, Docker Hub doesn't notify me when you write them, second I can't properly reply and third even if I could often it doesn't make much sense to keep them around forever and a day. Instead ask a question on [StackOverflow](http://stackoverflow.com/) and assign the `nodemcu` and `docker` tags.

For bugs and improvement suggestions create an issue at [https://github.com/marcelstoer/docker-nodemcu-build/issues](https://github.com/marcelstoer/docker-nodemcu-build/issues).

## Credits
Thanks to [Paul Sokolovsky](http://pfalcon-oe.blogspot.com/) who created and maintains [esp-open-sdk](https://github.com/pfalcon/esp-open-sdk).

## Author
[http://frightanic.com](http://frightanic.com)
