FROM alpine:3.20 AS builder

WORKDIR /opt/monero

COPY monerod_docker.pub SHA256.sig /opt/monero/

RUN apk add --no-cache curl tar bzip2 signify \
  && curl -L -o monero-linux-x64-v0.18.3.4.tar.bz2 https://downloads.getmonero.org/cli/linux64 \
  && signify -C -p monerod_docker.pub -x SHA256.sig monero-linux-x64-v0.18.3.4.tar.bz2 \
  && tar xjf monero-linux-x64-v0.18.3.4.tar.bz2 monero-x86_64-linux-gnu-v0.18.3.4/monerod --strip 1

FROM alpine:3.20

RUN apk add --no-cache gcompat

RUN adduser -D -u 1000 monero \
  && mkdir -p /data && chown monero:monero /data

ENV HOME=/data

COPY --from=builder /opt/monero/monerod /usr/local/bin/monerod

USER monero

WORKDIR /data


# main
EXPOSE 18080 18081 18082 18083

# test
EXPOSE 28080 28081 28082 28083

# stage
EXPOSE 38080 38081 38082 38083

VOLUME [ "/data" ]

ENTRYPOINT [ "/usr/local/bin/monerod" ]
CMD [ "--non-interactive", "--rpc-bind-ip=0.0.0.0", "--rpc-bind-port=18081", "--confirm-external-bind", "--no-igd", "--restricted-rpc", "--disable-rpc-ban", "--no-zmq" ]
