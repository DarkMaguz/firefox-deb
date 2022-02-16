FROM debian:bullseye

RUN apt-get update
RUN apt-get install -y wget libxml2-utils tar bzip2 coreutils grep sed

RUN mkdir -p /build
RUN groupadd -r --gid 1000 cpos
RUN useradd -r --uid 1000 -g cpos cpos
USER cpos

WORKDIR /build

ENTRYPOINT ["./docker-run.sh"]
