![banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# PROMETHEUS
![size](https://img.shields.io/docker/image-size/11notes/prometheus/3.6.0?color=0eb305)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![version](https://img.shields.io/docker/v/11notes/prometheus/3.6.0?color=eb7a09)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![pulls](https://img.shields.io/docker/pulls/11notes/prometheus?color=2b75d6)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)[<img src="https://img.shields.io/github/issues/11notes/docker-PROMETHEUS?color=7842f5">](https://github.com/11notes/docker-PROMETHEUS/issues)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxyZWN0IHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgZmlsbD0idHJhbnNwYXJlbnQiLz4KICA8cGF0aCBkPSJtMTMgNmg2djdoN3Y2aC03djdoLTZ2LTdoLTd2LTZoN3oiIGZpbGw9IiNmZmYiLz4KPC9zdmc+)

Run prometheus rootless and distroless.

# INTRODUCTION 📢

Prometheus, a Cloud Native Computing Foundation project, is a systems and service monitoring system. It collects metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts when specified conditions are observed.

![GRAPH](https://github.com/11notes/docker-prometheus/blob/master/img/Graph.png?raw=true)

# SYNOPSIS 📖
**What can I do with this?** This image will run Prometheus [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) and [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md), for maximum security and performance. You can either provide your own config file or configure Prometheus directly inline in your compose. If you run the compose example, you can open the following [URL](http://localhost:3000/query?g0.expr=histogram_quantile%280.9%2C+sum+by+%28le%29+%28rate%28dnspyre_dns_requests_duration_seconds_bucket%5B1m%5D%29%29%29&g0.show_tree=0&g0.tab=graph&g0.range_input=1m&g0.res_type=auto&g0.res_density=medium&g0.display_mode=lines&g0.show_exemplars=0) to see the statistics of your DNS benchmark just like in the screenshot.

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! Because ...

> [!IMPORTANT]
>* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
>* ... this image has no shell since it is [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)
>* ... this image is auto updated to the latest version via CI/CD
>* ... this image has a health check
>* ... this image runs read-only
>* ... this image is automatically scanned for CVEs before and after publishing
>* ... this image is created via a secure and pinned CI/CD process
>* ... this image is very small

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

# COMPARISON 🏁
Below you find a comparison between this image and the most used or original one.

| **image** | **size on disk** | **init default as** | **[distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)** | supported architectures
| ---: | ---: | :---: | :---: | :---: |
| prom/prometheus | 313MB | 65534:65534 | ❌ | amd64, arm64, armv7, ppc64le, s390x |

# DEFAULT CONFIG 📑
```yaml
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:3000"]
```

# VOLUMES 📁
* **/prometheus/etc** - Directory of your config
* **/prometheus/var** - Directory of all dynamic data and database

# COMPOSE ✂️
```yaml
name: "monitoring"
services:
  prometheus:
    depends_on:
      adguard:
        condition: "service_healthy"
        restart: true
    image: "11notes/prometheus:3.6.0"
    read_only: true
    environment:
      TZ: "Europe/Zurich"
      PROMETHEUS_CONFIG: |-
        global:
          scrape_interval: 1s

        scrape_configs:
          - job_name: "dnspyre"
            static_configs:
              - targets: ["dnspyre:3000"]
    volumes:
      - "prometheus.etc:/prometheus/etc"
      - "prometheus.var:/prometheus/var"
    ports:
      - "3000:3000/tcp"
    networks:
      frontend:
    restart: "always"

  # this image will execute 100k (10 x 10000) queries against adguard to fill your Prometheus with some data
  dnspyre:
    depends_on:
      prometheus:
        condition: "service_healthy"
        restart: true
    image: "11notes/distroless:dnspyre"
    command: "--server adguard -c 10 -n 3 -t A --prometheus ':3000' https://raw.githubusercontent.com/11notes/static/refs/heads/main/src/benchmarks/dns/fqdn/10000"
    read_only: true
    environment:
      TZ: "Europe/Zurich"
    networks:
      frontend:

  adguard:
    image: "11notes/adguard:0.107.64"
    read_only: true
    environment:
      TZ: "Europe/Zurich"
    volumes:
      - "adguard.etc:/adguard/etc"
      - "adguard.var:/adguard/var"
    tmpfs:
      # tmpfs volume because of read_only: true
      - "/adguard/run:uid=1000,gid=1000"
    ports:
      - "53:53/udp"
      - "53:53/tcp"
      - "3010:3000/tcp"
    networks:
      frontend:
    sysctls:
      # allow rootless container to access ports < 1024
      net.ipv4.ip_unprivileged_port_start: 53
    restart: "always"

volumes:
  prometheus.etc:
  prometheus.var:
  adguard.etc:
  adguard.var:

networks:
  frontend:
```
To find out how you can change the default UID/GID of this container image, consult the [how-to.changeUIDGID](https://github.com/11notes/RTFM/blob/main/linux/container/image/11notes/how-to.changeUIDGID.md#change-uidgid-the-correct-way) section of my [RTFM](https://github.com/11notes/RTFM)

# DEFAULT SETTINGS 🗃️
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user name |
| `uid` | 1000 | [user identifier](https://en.wikipedia.org/wiki/User_identifier) |
| `gid` | 1000 | [group identifier](https://en.wikipedia.org/wiki/Group_identifier) |
| `home` | /prometheus | home directory of user docker |

# ENVIRONMENT 📝
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Will activate debug option for container image and app (if available) | |
| `PROMETHEUS_CONFIG` | If not using a yml file you can provide your config as inline yml directly in your compose | |

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [3.6.0](https://hub.docker.com/r/11notes/prometheus/tags?name=3.6.0)

### There is no latest tag, what am I supposed to do about updates?
It is of my opinion that the ```:latest``` tag is dangerous. Many times, I’ve introduced **breaking** changes to my images. This would have messed up everything for some people. If you don’t want to change the tag to the latest [semver](https://semver.org/), simply use the short versions of [semver](https://semver.org/). Instead of using ```:3.6.0``` you can use ```:3``` or ```:3.6```. Since on each new version these tags are updated to the latest version of the software, using them is identical to using ```:latest``` but at least fixed to a major or minor version.

If you still insist on having the bleeding edge release of this app, simply use the ```:rolling``` tag, but be warned! You will get the latest version of the app instantly, regardless of breaking changes or security issues or what so ever. You do this at your own risk!

# REGISTRIES ☁️
```
docker pull 11notes/prometheus:3.6.0
docker pull ghcr.io/11notes/prometheus:3.6.0
docker pull quay.io/11notes/prometheus:3.6.0
```

# SOURCE 💾
* [11notes/prometheus](https://github.com/11notes/docker-PROMETHEUS)

# PARENT IMAGE 🏛️
> [!IMPORTANT]
>This image is not based on another image but uses [scratch](https://hub.docker.com/_/scratch) as the starting layer.
>The image consists of the following distroless layers that were added:
>* [11notes/distroless](https://github.com/11notes/docker-distroless/blob/master/arch.dockerfile) - contains users, timezones and Root CA certificates, nothing else
>* [11notes/distroless:curl](https://github.com/11notes/docker-distroless/blob/master/curl.dockerfile) - app to execute HTTP requests

# BUILT WITH 🧰
* [prometheus](https://github.com/prometheus/prometheus)

# GENERAL TIPS 📌
> [!TIP]
>* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
>* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-prometheus/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-prometheus/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-prometheus/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 23.09.2025, 07:20:03 (CET)*