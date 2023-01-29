FROM ghcr.io/imagegenius/baseimage-alpine:3.17

# set version label
ARG BUILD_DATE
ARG VERSION
ARG PENPOT_VERSION
LABEL build_version="ImageGenius Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="hydazz"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    g++ \  
    make \
    vips-dev && \  
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    ca-certificates \
    curl \
    fontconfig \
    fontforge-git \
    ghostscript \
    imagemagick \
    libc-dev \
    libcairo \
    libcups \
    libdbus \
    libexpat \
    libfontconfig \
    libgcc \
    libgdk-pixbuf \
    libglib \
    libgtk-3 \
    libnss \
    libpango \
    libx11 \
    libxcb \
    libxcomposite \
    libxcursor \
    libxdamage \
    libxext \
    libxfixes \
    libxi \
    libxrandr \
    libxrender \
    libxtst \
    liberation-fonts \
    netpbm \
    poppler-utils \
    potrace \
    python3 \
    tzdata \
    webp \
    woff2 \
    libgbm &&
  echo "**** download penpot ****" && \
  mkdir -p \
    /tmp/penpot && \
  if [ -z ${PENPOT_VERSION} ]; then \
    PENPOT_VERSION=$(curl -sL https://api.github.com/repos/penpot/penpot/releases/latest | \
      jq -r '.tag_name'); \
  fi && \
  curl -o \
    /tmp/penpot.tar.gz -L \
    "https://github.com/penpot-app/penpot/archive/${PENPOT_VERSION}.tar.gz" && \
  tar xf \
    /tmp/penpot.tar.gz -C \
    /tmp/penpot --strip-components=1

# environment settings
ENV NODE_ENV="production" \
    penpot_MACHINE_LEARNING_URL=false

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8080
VOLUME /config /uploads
