FROM debian:stable AS builder

WORKDIR /opt/monero

COPY monerod_docker.pub SHA256.sig /opt/monero/

RUN apt-get update && apt-get install -y tar curl bzip2 signify-openbsd
RUN curl -L -o monero-linux-x64-v0.18.3.4.tar.bz2 https://downloads.getmonero.org/cli/linux64
RUN signify-openbsd -C -p monerod_docker.pub -x SHA256.sig monero-linux-x64-v0.18.3.4.tar.bz2
RUN tar xjf monero-linux-x64-v0.18.3.4.tar.bz2 monero-x86_64-linux-gnu-v0.18.3.4/monerod --strip 1

WORKDIR /data

FROM debian:stable-slim

COPY --from=builder /opt/monero/monerod /usr/local/bin/monerod
ENTRYPOINT [ "/usr/local/bin/monerod" ]
CMD [ "--non-interactive", "--rpc-bind-ip=0.0.0.0", "--rpc-bind-port=18081", "--confirm-external-bind", "--no-igd", "--restricted-rpc", "--disable-rpc-ban", "--no-zmq" ]

# main
EXPOSE 18080
EXPOSE 18081
EXPOSE 18082
EXPOSE 18083

# test
EXPOSE 28080
EXPOSE 28081
EXPOSE 28082
EXPOSE 28083

# stage
EXPOSE 38080
EXPOSE 38081
EXPOSE 38082
EXPOSE 38083
