## Vodafone Station Exporter Docker Image

This Dockerfile allows you to build and run a container with the Vodafone Station Exporter, which exports metrics for Vodafone station devices.

### Prerequisites

To build and run the Docker image, you need the following:

1. Docker installed on your system. You can download Docker from the official website: [https://www.docker.com/get-started](https://www.docker.com/get-started)

### Build the Docker Image

1. Clone the repository containing the Dockerfile and other necessary files.
2. Open a terminal and navigate to the cloned directory.
3. Build the Docker image with the following command:

```bash
docker build -t vodafone-station-exporter .
```

This will build the Docker image and tag it as `vodafone-station-exporter`.

### Run the Container

Once you have built the Docker image, you can run the Vodafone Station Exporter container with the following command:

```bash
docker run --rm -d --restart unless-stopped -p 9420:9420 \
	-e vodafoneStationPassword=<password> \
	-e vodafoneStationUrl=http://<ip_address> \
	vodafone-station-exporter
```

Replace `<password>` with your actual Vodafone station password and `<ip_address>` with the IP address of your Vodafone station.

For example, if your Vodafone station password is `my_secret_password` and the IP address of your Vodafone station is `192.168.0.1`, you would run:

```bash
docker run --rm -d --restart unless-stopped -p 9420:9420 \
	-e vodafoneStationPassword=my_secret_password \
	-e vodafoneStationUrl=http://192.168.0.1 \
	vodafone-station-exporter
```

### Access Metrics

The Vodafone Station Exporter exposes metrics at `http://localhost:9420/metrics`. If you are running the Docker container on a remote server or a different machine, replace `localhost` with the IP or hostname of that machine.

### Additional Notes

- The container is configured to automatically remove itself when stopped (`--rm` flag).
- The container restarts automatically unless explicitly stopped (`--restart unless-stopped` flag).
- The metrics are exposed on port 9420 (`-p 9420:9420` flag) and can be accessed from the host machine or other devices on the network.
