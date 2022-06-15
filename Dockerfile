
# build it with: docker build . -t vodafone-station-exporter
# run it with: docker run -d --restart unless-stopped -p 9420:9420 -e VF_STATION_PASS=<password> -e VF_STATION_URL=http://192.168.0.1 vodafone-station-exporter
# or with: docker run -d --restart unless-stopped -p 9420:9420 --env-file .ENV-PW vodafone-station-exporter

FROM golang:latest as builder
ADD . /go/vodafone-station-exporter
WORKDIR /go/vodafone-station-exporter
RUN go build

FROM busybox:latest
WORKDIR /app
COPY --from=builder /go/vodafone-station-exporter/vodafone-station-exporter .
CMD ./vodafone-station-exporter -vodafone.station-password=$VF_STATION_PASS -vodafone.station-url=$VF_STATION_URL
EXPOSE 9420
