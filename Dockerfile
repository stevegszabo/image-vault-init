FROM ubuntu:22.04

ENV HASHICORP_URL=https://apt.releases.hashicorp.com
ENV HASHICORP_KEYRING=/usr/share/keyrings/hashicorp-archive-keyring.gpg
ENV HASHICORP_SOURCE=/etc/apt/sources.list.d/hashicorp.list

RUN apt-get update && apt-get upgrade -y && apt-get install -y apt-utils lsb-release gpg wget jq && apt-get clean
RUN wget -O- $HASHICORP_URL/gpg | gpg --dearmor -o $HASHICORP_KEYRING
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=$HASHICORP_KEYRING] $HASHICORP_URL $(lsb_release -cs) main" | tee $HASHICORP_SOURCE
RUN apt-get update && apt-get install --reinstall -y vault

COPY src/entrypoint.sh /home/vault/entrypoint.sh
RUN chown -R vault:vault /home/vault

USER vault
ENTRYPOINT ["/bin/bash", "/home/vault/entrypoint.sh"]