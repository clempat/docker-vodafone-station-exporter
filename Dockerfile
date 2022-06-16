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

FROM golang:1.18-alpine as builder
ADD . /go/vodafone-station-exporter
WORKDIR /go/vodafone-station-exporter

RUN apk add file #

# -ldflags="-s -w" for Shrinking Go executables, https://itnext.io/shrinking-go-executable-9e9c17b47a41
RUN --mount=type=cache,id=gomod,sharing=locked,mode=0775,target=/go/pkg/mod \
    --mount=type=cache,id=gobuild,sharing=locked,mode=0775,target=/root/.cache/go-build \
    go env GOCACHE && \
    du -hd0 $(go env GOCACHE) && \
    go mod download && \
    du -hd0 $(go env GOCACHE)
RUN --mount=type=cache,id=gomod,sharing=locked,mode=0775,target=/go/pkg/mod \
    --mount=type=cache,id=gobuild,sharing=locked,mode=0775,target=/root/.cache/go-build \
    go env GOCACHE && \
    du -hd0 $(go env GOCACHE) && \
    GODEBUG=gocachehash=1 go build -v -ldflags="-s -w" && \
    du -hd0 $(go env GOCACHE)
   # go build -ldflags="-s -w"

FROM alpine:3.16
WORKDIR /app
#RUN apk --no-cache add file ldd
RUN apk add file scanelf elfutils patchelf
COPY --from=builder /go/vodafone-station-exporter/vodafone-station-exporter .
CMD /app/vodafone-station-exporter -vodafone.station-password=$VF_STATION_PASS -vodafone.station-url=$VF_STATION_URL
EXPOSE 9420
