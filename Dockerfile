FROM debian:bookworm-slim

# The Terraria Game Version, ignoring periods. For example, version 1.4.4.9 will be a value of 1449 in this variable.
ARG TERRARIA_VERSION=1449

# The shutdown message is broadcast to the game chat when the container was stopped from the host.
ENV TERRARIA_SHUTDOWN_MESSAGE="Server is shutting down NOW!"

# The autosave feature will save the world periodically. The interval is in minutes.
ENV TERRARIA_AUTOSAVE_INTERVAL="10"

# The following environment variables will configure common settings for the Terraria server.
ENV TERRARIA_MOTD="A Terraria server powered by Docker! (https://github.com/JACOBSMILE/terraria1.4). You can change this message with the TERRARIA_MOTD environment variable."
ENV TERRARIA_PASS="docker"
ENV TERRARIA_MAXPLAYERS="8"
ENV TERRARIA_WORLDNAME="Docker"
ENV TERRARIA_WORLDSIZE="3"
ENV TERRARIA_WORLDSEED="Docker"
ENV TERRARIA_DIFFICULTY="2"

# Loading a configuration file expects a proper Terraria config file to be mapped to /root/terraria-server/serverconfig.txt
# Set this to "Yes" if you would rather use a config file instead of the above settings.
ENV TERRARIA_USECONFIGFILE="No"

EXPOSE 7777

RUN apt-get update
RUN apt-get install -y wget unzip tmux bash

RUN useradd -m terraria
	
RUN mkdir -p /home/terraria/server /home/terraria/.local/share/Terraria/Worlds 
RUN echo "difficulty=${TERRARIA_DIFFICULTY}" > /home/terraria/server/config.txt
RUN wget -O /home/terraria/terraria-server-${TERRARIA_VERSION}.zip https://terraria.org/api/download/pc-dedicated-server/terraria-server-${TERRARIA_VERSION}.zip
RUN unzip -o /home/terraria/terraria-server-${TERRARIA_VERSION}.zip -d /home/terraria
RUN ls -la /home/terraria
RUN mv /home/terraria/${TERRARIA_VERSION}/Linux/* /home/terraria/server
RUN rm -rf /home/terraria/terraria-server-${TERRARIA_VERSION}.zip /home/terraria/${TERRARIA_VERSION}
RUN apt-get remove unzip -y \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /home/terraria

COPY entrypoint.sh .
COPY inject.sh /usr/local/bin/inject
COPY autosave.sh .

RUN chmod +x entrypoint.sh /usr/local/bin/inject autosave.sh server/TerrariaServer.bin.x86_64

RUN chown -R terraria:terraria /home/terraria

USER terraria

ENTRYPOINT ["./entrypoint.sh"]