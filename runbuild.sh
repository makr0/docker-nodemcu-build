#!/bin/bash
cd app/include;
git checkout user_config.h user_modules.h user_version.h
X_BRANCH="$(git rev-parse --abbrev-ref HEAD)";
X_COMMIT_ID=$(git rev-parse HEAD);
X_SSL_ENABLED=false;

if [ "foo${X_MODULES}" = "foo" ]; then
  X_MODULES=adc,bit,cjson,file,gpio,http,i2c,mqtt,net,node,ow,pwm,rtctime,spi,tmr,uart,wifi,ws2812
fi

sed 's/#define NODE_VERSION[^_].*/#define NODE_VERSION "NodeMCU custom build by crashc0de\\n\\tbranch: '$X_BRANCH'\\n\\tcommit: '$X_COMMIT_ID'\\n\\tSSL: '$X_SSL_ENABLED'\\n\\tmodules: '$X_MODULES'\\n"/g' user_version.h > user_version.h.tmp && mv user_version.h.tmp user_version.h
sed 's/#define BUILD_DATE.*/#define BUILD_DATE "\\tbuilt on: '"$(date "+%Y-%m-%d %H:%M")"'\\n"/g' user_version.h > user_version.h.tmp && mv user_version.h.tmp user_version.h

echo "SSL enabled:" "${X_SSL_ENABLED}";

if [ "${X_SSL_ENABLED}" = "true" ]; then
  echo "Enabling SSL in user_config.h"
  sed -e 's/\/\/ *#define CLIENT_SSL_ENABLE/#define CLIENT_SSL_ENABLE/g' user_config.h > user_config.h.tmp;
else
  echo "Disabling SSL in user_config.h"
  sed -e 's/#define CLIENT_SSL_ENABLE/\/\/ #define CLIENT_SSL_ENABLE/g' user_config.h > user_config.h.tmp;
fi
mv user_config.h.tmp user_config.h;

# replace ',' by newline, make it uppercase and prepend every item with '#define LUA_USE_MODULES_'
export X_MODULES_STRING=$(echo $X_MODULES | tr , '\n' | tr '[a-z]' '[A-Z]' | perl -pe 's/(.*)\n/#define LUA_USE_MODULES_$1\n/g')
# inject the modules string into user_modules.h between '#ifndef LUA_CROSS_COMPILER\n' and '\n#endif  /* LUA_CROSS_COMPILER'
# the 's' flag in '/sg' makes . match newlines
# Perl creates a temp file which is removed right after the manipulation
perl -e 'local $/; $_ = <>; s/(#ifndef LUA_CROSS_COMPILER\n)(.*)(\n#endif.*LUA_CROSS_COMPILER.*)/$1$ENV{"X_MODULES_STRING"}$3/sg; print' user_modules.h > user_modules.h.tmp && mv user_modules.h.tmp user_modules.h

cd ../..;

if [ -z "$IMAGE_NAME" ]; then IMAGE_NAME=${BRANCH}_${BUILD_DATE}; else true; fi
cp tools/esp-open-sdk.tar.gz ../
cd ..
tar -zxvf esp-open-sdk.tar.gz
export PATH=$PATH:$PWD/esp-open-sdk/sdk:$PWD/esp-open-sdk/xtensa-lx106-elf/bin
cd nodemcu-firmware
if [ -z "$INTEGER_ONLY" ]; then
  (make clean all
      cd bin
      srec_cat -output nodemcu_float_"${IMAGE_NAME}".bin -binary 0x00000.bin -binary -fill 0xff 0x00000 0x10000 0x10000.bin -binary -offset 0x10000
      cp ../app/mapfile nodemcu_float_"${IMAGE_NAME}".map
      cd ../);
else true; fi
if [ -z "$FLOAT_ONLY" ]; then
  (make EXTRA_CCFLAGS="-DLUA_NUMBER_INTEGRAL" clean all
  cd bin
  srec_cat -output nodemcu_integer_"${IMAGE_NAME}".bin -binary 0x00000.bin -binary -fill 0xff 0x00000 0x10000 0x10000.bin -binary -offset 0x10000
  cp ../app/mapfile nodemcu_integer_"${IMAGE_NAME}".map);
else true; fi
