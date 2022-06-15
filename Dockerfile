
# build it with: docker build . -t vodafone-station-exporter
# run it with: docker run --rm -d --restart unless-stopped -p 9420:9420 -e VF_STATION_PASS=<password> -e VF_STATION_URL=http://192.168.0.1 vodafone-station-exporter
# or with: docker run --rm -it -p 9420:9420 --env-file .ENV-PW vodafone-station-exporter

FROM golang:1.18-alpine as builder
ADD . /go/vodafone-station-exporter
WORKDIR /go/vodafone-station-exporter
# -ldflags="-s -w" for Shrinking Go executables, https://itnext.io/shrinking-go-executable-9e9c17b47a41
RUN go build -ldflags="-s -w"

FROM alpine:latest
WORKDIR /app
COPY --from=builder /go/vodafone-station-exporter/vodafone-station-exporter .
CMD /app/vodafone-station-exporter -vodafone.station-password=$VF_STATION_PASS -vodafone.station-url=$VF_STATION_URL
EXPOSE 9420
