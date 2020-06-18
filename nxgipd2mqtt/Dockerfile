ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

ENV NXGIPD2MQTT_VERSION=0.1.0
ENV ARCHIVE=nxgipd2mqtt-$NXGIPD2MQTT_VERSION
ENV MXML_VERSION=2.9
ENV MXML_ARCHIVE=mxml-${MXML_VERSION}

RUN apk add --update --no-cache socat make build-base git mosquitto-clients ca-certificates && \
  curl -sL -o "/${MXML_ARCHIVE}.tar.gz" \
  "https://github.com/michaelrsweet/mxml/releases/download/release-${MXML_VERSION}/mxml-${MXML_VERSION}.tar.gz" && \
  tar xzvf "/${MXML_ARCHIVE}.tar.gz" && \
  cd "/${MXML_ARCHIVE}" && \
  ./configure && \
  make && \
  make install && \
  mkdir -p /nxgipd2mqtt && \
  git clone https://github.com/orgjvr/nxgipd && \
  cd /nxgipd && \
  ./configure && \
  make && \
  make strip && \
  make install && \
  cp nxgipd.conf.def /etc/nxgipd.conf && \
  apk del make build-base && \
  rm -rf docs test images scripts data docker LICENSE README.md update.sh

COPY run.sh "/run.sh"
COPY socat.sh "/socat.sh"
WORKDIR /

RUN ["chmod", "a+x", "./socat.sh"]
RUN ["chmod", "a+x", "./run.sh"]
CMD [ "run.sh" ]
