# syntax=docker/dockerfile:1.3

# https://github.com/tonistiigi/xx
FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

#FROM golang:1.18-alpine as builder
FROM --platform=$BUILDPLATFORM golang:1.18-alpine as builder
# copy xx scripts to your build stage
COPY --from=xx / /
ARG BUILDPLATFORM TARGETOS TARGETARCH TARGETPLATFORM
#ARG TARGETARCH
#ARG TARGETPLATFORM
#ARG BUILDPLATFORM
# you can now call xx-* commands
RUN xx-info env
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"
# --platform=$BUILDPLATFORM see https://www.docker.com/blog/faster-multi-platform-builds-dockerfile-cross-compilation-guide/
ADD . /go/vodafone-station-exporter
WORKDIR /go/vodafone-station-exporter

RUN apk add file #


# Building Go can be achieved with the xx-go wrapper that automatically sets up values for GOOS, GOARCH, GOARM etc. It also sets up pkg-config and C compiler if building with CGo. Note that by default, CGo is enabled in Go when compiling for native architecture and disabled when cross-compiling. This can easily produce unexpected results; therefore, you should always define either CGO_ENABLED=1 or CGO_ENABLED=0 depending on if you expect your compilation to use CGo or not. https://github.com/tonistiigi/xx
#ENV CGO_ENABLED=1
ENV CGO_ENABLED=0

RUN --mount=type=cache,id=gomod,sharing=locked,mode=0775,target=/go/pkg/mod \
	--mount=type=cache,id=gobuild,sharing=locked,mode=0775,target=/root/.cache/go-build \
	set -x && \
	go build -v "fmt" && \
	go env GOCACHE && \
	du -hd0 $(go env GOCACHE) && \
	go env GOMODCACHE && \
	du -hd0 $(go env GOMODCACHE) && \
	GOOS=$TARGETOS GOARCH=$TARGETARCH go mod download && \
	du -hd0 $(go env GOCACHE) && \
	du -hd0 $(go env GOMODCACHE)

RUN    set -x && \
	go build -v "fmt" && \
	go env GOCACHE && \
	du -hd0 $(go env GOCACHE) && \
	go env GOMODCACHE && \
	du -hd0 $(go env GOMODCACHE) && \
	GOOS=$TARGETOS GOARCH=$TARGETARCH go build -v -ldflags="-extldflags=-static -s -w -X main.version={{.Version}} -X main.commit={{.Commit}} -X main.date={{.Date}}" && \
	du -hd0 $(go env GOCACHE) && \
	du -hd0 $(go env GOMODCACHE)

RUN    XX_DEBUG_VERIFY=foo xx-verify vodafone-station-exporter

FROM alpine:3.16
WORKDIR /app
RUN apk add file scanelf elfutils patchelf
COPY --from=builder /go/vodafone-station-exporter/vodafone-station-exporter .

ENV logLevel=${logLevel:-debug} \
	vodafoneStationPassword={vodafoneStationPassword:-FIXME} \
	vodafoneStationUrl=${vodafoneStationUrl:-http://192.168.0.1} \
	listenAddress=${listenAddress:-[::]:9420} \
	metricsPath=${metricsPath:-/metrics}

COPY --chmod=755 vodafone-station-exporter-entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 9420
ENV PATH="$PATH:/apt" 
USER nobody
ENTRYPOINT ["entrypoint.sh"]
CMD ["vodafone-station-exporter"]


