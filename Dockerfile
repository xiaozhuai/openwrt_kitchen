FROM alpine:latest

RUN apk --no-cache add \
        bash \
        util-linux \
        parted \
        e2fsprogs-extra \
    && mkdir /openwrt_kitchen

VOLUME /openwrt_kitchen
WORKDIR /openwrt_kitchen

ENTRYPOINT ["/openwrt_kitchen/openwrt_kitchen.sh"]
