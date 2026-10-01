#!/bin/bash

msgunfmt /usr/share/locale/zh_CN/LC_MESSAGES/wget.mo -o - | sed 's/eta(英国中部时间)/ETA/' | msgfmt - -o /tmp/zh_CN.mo

sudo cp /tmp/zh_CN.mo /usr/share/locale/zh_CN/LC_MESSAGES/wget.mo
