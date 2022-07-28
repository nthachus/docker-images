ARG  TAG=latest
FROM alpine:${TAG}

ENV LANG=C.UTF-8

RUN apk add --no-cache nodejs npm yarn \
 && rm -rf /var/cache/apk/* /tmp/* \
 && mkdir -p /usr/etc \
 && echo 'update-notifier=false' >> /usr/etc/npmrc \
 && echo 'disable-self-update-check true' >> /usr/etc/yarnrc

CMD ["node", "-v"]
