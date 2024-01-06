## Credit: https://github.com/mtoensing/Docker-Minecraft-PaperMC-Server/blob/latest/Dockerfile
FROM eclipse-temurin:20-jre AS build
RUN apt-get update -y && apt-get install -y curl jq

LABEL Habanero <habanerospices.com>

ARG paper_version=1.20.4

## Download paper
WORKDIR /opt/minecraft
COPY ./get-mcpaper.sh /
RUN chmod +x /get-mcpaper.sh && /get-mcpaper.sh ${paper_version}

## Run Environment
FROM eclipse-temurin:20-jre AS runtime
ARG TARGETARCH

# Install Gosu
RUN apt-get update && apt-get install -y gosu

WORKDIR /data

# Get server jar from build job
COPY --from=build /opt/minecraft/paperclip.jar /opt/minecraft/paper.jar

ARG rcon_cli_version=1.6.0
# Implement checksom check
ADD https://github.com/itzg/rcon-cli/releases/download/${rcon_cli_version}/rcon-cli_${rcon_cli_version}_linux_${TARGETARCH}.tar.gz /tmp/rcon-cli.tgz
RUN tar -x -C /usr/local/bin -f /tmp/rcon-cli.tgz rcon-cli && \
  rm /tmp/rcon-cli.tgz

# External volume for server data.
VOLUME [ "/data" ]

# Exposing default minecraft ports
EXPOSE 25565/tcp
EXPOSE 25565/udp

# Set Jvm memory
ARG memory_size=1G
ENV MEMORY_SIZE=${memory_size}

# Set Jvm flags
ARG java_flags="-Dlog4j2.formatMsgNoLookups=true -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=mcflags.emc.gs -Dcom.mojang.eula.agree=true"
ENV JAVA_FLAGS=${java_flags}

# Set Paper flags.
ARG paper_flags="--nojline"
ENV PAPER_FLAGS=${paper_flags}

WORKDIR /data

# Entrypoint
COPY /entrypoint.sh /opt/minecraft/
RUN chmod +x /opt/minecraft/entrypoint.sh

ENTRYPOINT [ "/opt/minecraft/entrypoint.sh" ]

