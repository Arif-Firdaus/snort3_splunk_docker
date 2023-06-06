#!/bin/sh

crond && snort -c /usr/local/etc/snort/snort.lua -s 65535 -k none -Q -l /var/log/snort -D -m 0x1b --create-pidfile --plugin-path=/usr/local/etc/so_rules/ --plugin-path=/usr/local/lib/snort