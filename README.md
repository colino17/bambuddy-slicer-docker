# Bambuddy Slicer
A fork of https://github.com/AFKFelix/orca-slicer-api for use with Bambuddy.

The container includes both Bambu Studio and Orca Slicer, although only one can be used at one time. To switch between the two you can change the port mapping (3001 for Bambu Studio or 3003 for Orca Slicer) and the ORCASLICER_PATH variable ("/app/bambu/AppRun" or "/app/orca/AppRun").

## Compose
```yaml
  bambuddy-slicer:
    image: ghcr.io/colino17/bambuddy-slicer-docker:latest
    container_name: bambuddy-slicer
    restart: always
    volumes:
      - /path/to/data/folder:/app/data
    environment:
      - ORCASLICER_PATH=/app/bambu/AppRun
    ports:
      - 3001:3000
```
