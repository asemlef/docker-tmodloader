FROM debian:10-slim

# app versions to use
ARG TMOD_VERSION=0.11.6.2
ARG TERRARIA_VERSION=1353
ARG WRAPPER_VERSION=1.0.0

# run updates
RUN apt-get -y update \
    && apt-get -y install wget unzip jq file \
    && apt-get -y clean

# install game-docker-wrapper for graceful exiting
RUN wget -P /usr/local/bin "https://github.com/iagox86/game-docker-wrapper/releases/download/${WRAPPER_VERSION}/game-docker-wrapper" \
    && chmod 755 /usr/local/bin/game-docker-wrapper

# install tmodloader here
WORKDIR /terraria-server

# download and unpack the vanilla terraria server
RUN wget "https://terraria.org/server/terraria-server-${TERRARIA_VERSION}.zip" \
    && unzip terraria-server-${TERRARIA_VERSION}.zip \
    && mv ${TERRARIA_VERSION}/Linux/* . \
    && rm -rf ${TERRARIA_VERSION} \
    && rm terraria-server-${TERRARIA_VERSION}.zip

# download and unpack tmodloader
RUN wget "https://github.com/tModLoader/tModLoader/releases/download/v${TMOD_VERSION}/tModLoader.Linux.v${TMOD_VERSION}.tar.gz" \
    && tar -xvzf tModLoader.Linux.v${TMOD_VERSION}.tar.gz \
    && chmod u+x Terraria TerrariaServer.* \
    && rm tModLoader.Linux.v${TMOD_VERSION}.tar.gz

# copy files
COPY serverconfig.tmpl .
COPY startup.sh /

# Environment variables for server config
ENV TERRARIA_SERVER_PASSWORD="" \
    TERRARIA_SERVER_MAXPLAYERS=8 \
    TERRARIA_SERVER_MOTD="Please don't cut the purple trees!" \
    TERRARIA_SERVER_LANGUAGE="en/US" \
    TERRARIA_SERVER_SECURE=0 \
    TERRARIA_WORLD_NAME="World" \
    TERRARIA_WORLD_SIZE=3 \
    TERRARIA_WORLD_DIFFICULTY=0 \
    TERRARIA_WORLD_SEED="" \
    TERRARIA_MODS_LIST="" \
    TERRARIA_MODS_REDOWNLOAD=0

# ports used
EXPOSE 7777

# volume for persistent data
Volume ["/terraria"]

# start server
ENTRYPOINT ["/startup.sh"]
