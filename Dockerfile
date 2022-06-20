# syntax=docker/dockerfile:1.3

# testing with https://github.com/moby/buildkit/issues/1673#issuecomment-698361687
# docker rm -f buildx_buildkit_localbuild0 ; docker buildx create --use --name localbuild  && docker buildx inspect localbuild --bootstrap && docker rm -f buildx_buildkit_localbuild0 && docker run --privileged -d --name=buildx_buildkit_localbuild0 -v=/dev/shm/buildkit:/var/lib/buildkit moby/buildkit:buildx-stable-1
## docker buildx create --use --name localbuild
## docker buildx inspect localbuild --bootstrap
# recreate buildkit with host path
## docker rm -f buildx_buildkit_localbuild0
## docker run --privileged -d --name=buildx_buildkit_localbuild0 -v=/tmp/buildkit:/var/lib/buildkit moby/buildkit:buildx-stable-1


# build it with: docker build . -t vodafone-station-exporter
# run it with: docker run --rm -d --restart unless-stopped -p 9420:9420 -e VF_STATION_PASS=<password> -e VF_STATION_URL=http://192.168.0.1 vodafone-station-exporter
# or with: docker run --rm -it -p 9420:9420 --env-file .ENV-PW vodafone-station-exporter

# echo loglevel=debug >> .ENV-PW ; echo station_password=XXXX >> .ENV-PW ;
# docker buildx build . -t vodafone-station-exporter-dev:latest && docker run --rm -it -p 9420:942--env-file .ENV-PW vodafone-station-exporter-dev:latest
# docker buildx build . -t vodafone-station-exporter-dev:test && docker run --rm -it -p 9420:9420 vodafone-station-exporter-dev:test

#FROM golang:1.18-alpine as builder
FROM golang:1.18-alpine as builder
ADD . /go/vodafone-station-exporter
WORKDIR /go/vodafone-station-exporter

RUN apk add file #

# -ldflags="-s -w" for Shrinking Go executables, https://itnext.io/shrinking-go-executable-9e9c17b47a41
RUN --mount=type=cache,id=gomod,sharing=locked,mode=0775,target=/go/pkg/mod \
    --mount=type=cache,id=gobuild,sharing=locked,mode=0775,target=/root/.cache/go-build \
    set -x && \
    go env GOCACHE && \
    du -hd0 $(go env GOCACHE) && \
    go env GOMODCACHE && \
    du -hd0 $(go env GOMODCACHE) && \
    go mod download && \
    du -hd0 $(go env GOCACHE) && \
    du -hd0 $(go env GOMODCACHE)
RUN --mount=type=cache,id=gomod,sharing=locked,mode=0775,target=/go/pkg/mod \
    --mount=type=cache,id=gobuild,sharing=locked,mode=0775,target=/root/.cache/go-build \
    set -x && \
    go env GOCACHE && \
    du -hd0 $(go env GOCACHE) && \
    go env GOMODCACHE && \
    du -hd0 $(go env GOMODCACHE) && \
    go build -v -ldflags="-s -w" && \
    du -hd0 $(go env GOCACHE) && \
    du -hd0 $(go env GOMODCACHE)
## # GODEBUG=gocachehash=1 go build -v -ldflags="-s -w" && \
## # go build -ldflags="-s -w"

FROM alpine:3.16
WORKDIR /app
#RUN apk --no-cache add file ldd
RUN apk add file scanelf elfutils patchelf
COPY --from=builder /go/vodafone-station-exporter/vodafone-station-exporter .

ENV logLevel=${logLevel:-debug} \
	vodafoneStationPassword={vodafoneStationPassword:-FIXME} \
	vodafoneStationUrl=${vodafoneStationUrl:-http://192.168.0.1} \
	listenAddress=${listenAddress:-[::]:9420} \
	metricsPath=${metricsPath:-/metrics}

#CMD "/app/vodafone-station-exporter -log.level ${loglevel} -vodafone.station-password ${station_password} -vodafone.station-url ${station_url} -web.listen-address ${listen_address} -web.telemetry-path ${telemetry_path}"
#CMD ["/app/vodafone-station-exporter","-log.level=${loglevel}","-vodafone.station-password=${station_password}","-vodafone.station-url=${station_url}","-web.listen-address=${listen_address}","-web.telemetry-path=${telemetry_path}"]
#CMD ["/app/vodafone-station-exporter"]
#CMD /bin/sh -vx -c 'env && set && /app/vodafone-station-exporter -log.level=$logLevel -vodafone.station-password=$vodafoneStationPassword -vodafone.station-url=$vodafoneStationUrl -web.listen-address=$listenAddress -web.telemetry-path=$metricsPath '
#CMD /bin/sh -vx -c '/app/vodafone-station-exporter -log.level=$logLevel -vodafone.station-password=$vodafoneStationPassword -vodafone.station-url=$vodafoneStationUrl -web.listen-address=$listenAddress -web.telemetry-path=$metricsPath '

COPY --chmod=755 vodafone-station-exporter-entrypoint.sh /entrypoint.sh
#ENTRYPOINT ["/app/vodafone-station-exporter-entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]
#CMD /app/vodafone-station-exporter-entrypoint.sh


EXPOSE 9420
