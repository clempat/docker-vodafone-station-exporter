#!/bin/sh
# Note: I've written this using sh so it works in the busybox container too

# https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash/16596104
[ -z ${DEBUG+x} ] || set -vx

set -eu

# USE the trap if you need to also do manual cleanup after the service is stopped,
#     or need to start multiple services in the one container
trap "echo TRAPed signal" HUP INT QUIT TERM

### ## start service in background here
### /usr/sbin/apachectl start
/app/vodafone-station-exporter -log.level="$logLevel" -vodafone.station-password="$vodafoneStationPassword" -vodafone.station-url="$vodafoneStationUrl" -web.listen-address="$listenAddress" -web.telemetry-path="$metricsPath"

### echo "[hit enter key to exit] or run 'docker stop <container>'"
### read

### # stop service and clean up here
### echo "stopping apache"
### /usr/sbin/apachectl stop

echo "exited $0"
