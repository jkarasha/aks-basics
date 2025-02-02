# pull a test docker image
docker pull alpine:3

# run it in interactive mode
docker run -it alpine:3

# run a container/image in detached mode, forward port 8080 on host to port 80 in container
docker run -d -p 8080:80 nginx
