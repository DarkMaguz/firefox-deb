#!/bin/sh -e

docker build -t darkmagus/build-firefox-deb .

docker run -it --rm -v $(pwd)/:/build darkmagus/build-firefox-deb
