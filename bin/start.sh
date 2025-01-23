#!/bin/sh

cd /home/hez/homebridge_extra_devices
. bin/config.sh
_build/prod/rel/homebridge_extra_devices/bin/homebridge_extra_devices start
