# MCUXpresso Docker
# Building Image
docker build -t mcuxpresso -f mcuxpresso_Dockerfile
docker build -t lpc845 -f lpc845_Dockerfile
# Running
docker run --rm -it -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY mcuxpresso mcuxpressoide

# References
- https://somatorio.org/en/post/running-gui-apps-with-docker/
