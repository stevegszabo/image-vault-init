FROM ubuntu:22.04

ENV APPLICATION_HOME=/home/vault
ENV APPLICATION_USER=vault
ENV APPLICATION_GROUP=vault
ENV APPLICATION_VENV=environment
ENV APPLICATION_KEYRING=/usr/share/keyrings/hashicorp-archive-keyring.gpg
ENV APPLICATION_SOURCE=/etc/apt/sources.list.d/hashicorp.list
ENV APPLICATION_HASHICORP=https://apt.releases.hashicorp.com

RUN apt-get update && apt-get upgrade -y && apt-get install -y lsb-release gpg wget jq python3 python3-pip python3.10-venv && apt-get clean
RUN wget -O- $APPLICATION_HASHICORP/gpg | gpg --dearmor -o $APPLICATION_KEYRING
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=$APPLICATION_KEYRING] $APPLICATION_HASHICORP $(lsb_release -cs) main" | tee $APPLICATION_SOURCE
RUN apt-get update && apt-get install --reinstall -y vault

COPY src/entrypoint.sh $APPLICATION_HOME/entrypoint.sh
RUN chown -R $APPLICATION_USER:$APPLICATION_GROUP $APPLICATION_HOME

USER vault
RUN python3 -m venv $APPLICATION_HOME/$APPLICATION_VENV && . $APPLICATION_HOME/$APPLICATION_VENV/bin/activate && pip3 install awscli
ENTRYPOINT ["/usr/bin/bash", "/home/vault/entrypoint.sh"]