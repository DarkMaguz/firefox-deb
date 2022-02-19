FROM debian:bullseye

RUN apt-get update
RUN apt-get install -y wget libxml2-utils tar bzip2 coreutils grep sed

RUN mkdir -p /build

WORKDIR /build

ENTRYPOINT ["./docker-run.sh"]
