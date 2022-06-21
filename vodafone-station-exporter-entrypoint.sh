#!/bin/sh
# Note: I've written this using sh so it works in the busybox container too

# https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash/16596104
[ -z ${DEBUG+x} ] || set -vx

set -e

# USE the trap if you need to also do manual cleanup after the service is stopped,
#     or need to start multiple services in the one container
trap "echo TRAPed signal" HUP INT QUIT TERM

# allow the container to be started with `--user`
# FIXME # if [[ "$*" == vodafone-station-exporter* ]] && [ "$(id -u)" = '0' ]; then
if [ "$*" = vodafone-station-exporter ] && [ "$(id -u)" = '0' ]; then
	#### find "$GHOST_CONTENT" \! -user node -exec chown node '{}' +
	exec su-exec sh "$BASH_SOURCE" "$@" -log.level="$logLevel" -vodafone.station-password="$vodafoneStationPassword" -vodafone.station-url="$vodafoneStationUrl" -web.listen-address="$listenAddress" -web.telemetry-path="$metricsPath"
elif [ "$*" = vodafone-station-exporter ]; then
	exec "$@" -log.level="$logLevel" -vodafone.station-password="$vodafoneStationPassword" -vodafone.station-url="$vodafoneStationUrl" -web.listen-address="$listenAddress" -web.telemetry-path="$metricsPath"
fi

#if [[ "$*" == vodafone-station-exporter* ]]; then
#else
#  exec "$@"
#fi

exec "$@"
