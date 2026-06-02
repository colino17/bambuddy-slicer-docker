FROM node:22-bookworm AS build

ARG ORCA_RELEASE=https://github.com/OrcaSlicer/OrcaSlicer/releases/download/v2.3.2/OrcaSlicer_Linux_AppImage_Ubuntu2404_V2.3.2.AppImage
ARG BAMBU_RELEASE=https://github.com/bambulab/BambuStudio/releases/download/v02.07.01.57/BambuStudio_ubuntu-24.04-v02.07.01.57-20260601192128.AppImage

WORKDIR /app

# Download Orca Slicer
RUN curl -fL -o orca.AppImage ${ORCA_RELEASE}
RUN chmod +x orca.AppImage
RUN ./orca.AppImage --appimage-extract
RUN rm orca.AppImage
RUN mv squashfs-root orca

# Download Bambu Studio
RUN curl -fL -o bambu.AppImage ${BAMBU_RELEASE}
RUN chmod +x bambu.AppImage
RUN ./bambu.AppImage --appimage-extract
RUN rm bambu.AppImage
RUN mv squashfs-root bambu

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build

FROM ubuntu:24.04

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y --no-install-recommends \
	curl ca-certificates gnupg \
	&& mkdir -p /etc/apt/keyrings \
	&& curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
	&& echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
	nodejs \
	libgl1 libgl1-mesa-dri libegl1 \
	libgtk-3-0 \
	libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 \
	libwebkit2gtk-4.1-0 \
	&& update-ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=build /app/dist/src /app/dist
COPY --from=build /app/node_modules /app/node_modules
COPY --from=build /app/bambu /app/bambu
COPY --from=build /app/orca /app/orca

ENV PORT=3000
ENV ORCASLICER_PATH=/app/bambu/AppRun
ENV DATA_PATH=/app/data
ENV NODE_ENV=production

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
	CMD curl -f http://localhost:3000/health || exit 1

CMD ["node", "app/dist/index.js"]
