ARG GOLANG_IMAGE=golang:1.21.12
ARG DEBIAN_IMAGE=debian:stable-slim
ARG BASE=gcr.io/distroless/static-debian11:nonroot
ARG BUILD_VERSION=v1.11.1


FROM ${GOLANG_IMAGE} AS stage1
ARG BUILD_VERSION
RUN git clone --depth 1 --branch ${BUILD_VERSION} https://github.com/coredns/coredns.git /coredns \
    && git clone --depth 1 https://github.com/icyflame/blocker.git /coredns/plugin/blocker \
    && sed -ie '/^forward:forward/i blocker:blocker' /coredns/plugin.cfg \
    && sed -ie '/^root:root/i rrl:github.com/coredns/rrl/plugins/rrl' /coredns/plugin.cfg \
    && sed -ie '/^root:root/i alternate:github.com/coredns/alternate' /coredns/plugin.cfg
WORKDIR /coredns
RUN make


FROM ${DEBIAN_IMAGE} AS stage2
SHELL [ "/bin/sh", "-ec" ]
RUN export DEBCONF_NONINTERACTIVE_SEEN=true \
           DEBIAN_FRONTEND=noninteractive \
           DEBIAN_PRIORITY=critical \
           TERM=linux ; \
    apt-get -qq update ; \
    apt-get -yyqq upgrade ; \
    apt-get -yyqq install ca-certificates libcap2-bin; \
    apt-get clean
COPY --from=stage1 /coredns/coredns /coredns
RUN setcap cap_net_bind_service=+ep /coredns


FROM ${BASE}
COPY --from=stage2 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=stage2 /coredns /coredns
USER nonroot:nonroot

EXPOSE 53 53/udp
VOLUME ["/etc/coredns"]
ENTRYPOINT ["/coredns"]
#CMD ["-conf", "/etc/coredns/Corefile"]
