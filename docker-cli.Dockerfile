ARG  TAG=latest
FROM alpine:${TAG}

RUN apk update -q \
 && apk add --no-cache docker-cli \
 && rm -rf /var/cache/apk/* /tmp/*

CMD ["docker", "-v"]
