FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

ENV HASHICORP_URL=https://apt.releases.hashicorp.com
ENV HASHICORP_KEYRING=/usr/share/keyrings/hashicorp-archive-keyring.gpg
ENV HASHICORP_SOURCE=/etc/apt/sources.list.d/hashicorp.list

ENV GOOGLE_URL=https://packages.cloud.google.com
ENV GOOGLE_KEYRING=/usr/share/keyrings/cloud.google.gpg
ENV GOOGLE_SOURCE=/etc/apt/sources.list.d/google-cloud-sdk.list

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apt-utils apt-utils apt-transport-https ca-certificates lsb-release gpg curl jq && \
    apt-get clean

RUN curl $HASHICORP_URL/gpg | gpg --dearmor -o $HASHICORP_KEYRING
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=$HASHICORP_KEYRING] $HASHICORP_URL $(lsb_release -cs) main" | tee $HASHICORP_SOURCE
RUN apt-get update && \
    apt-get install -y vault && \
    apt-get clean

RUN curl $GOOGLE_URL/apt/doc/apt-key.gpg | gpg --dearmor -o $GOOGLE_KEYRING && \
    echo "deb [signed-by=$GOOGLE_KEYRING] $GOOGLE_URL/apt cloud-sdk main" | tee -a $GOOGLE_SOURCE && \
    apt-get update && \
    apt-get install -y google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin && \
    apt-get clean

COPY src/entrypoint.sh /home/vault/entrypoint.sh
RUN chown -R vault:vault /home/vault

USER vault
ENTRYPOINT ["/bin/bash", "/home/vault/entrypoint.sh"]