#!/bin/bash

nohup X -ac :9 tty1 >/dev/null &
export DISPLAY=:9

sleep 2

xset -dpms
xset s off

xloadimage -onroot -center -fullscreen /opt/script/background/background.png -geometry  1920x1080

