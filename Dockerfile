FROM docker.io/library/ubuntu:22.04

RUN apt-get update && apt-get upgrade -y && apt-get install -y lsb-release gpg wget python3 python3-pip && apt-get clean
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
RUN apt-get update && apt-get install --reinstall -y vault
RUN pip3 install aws
RUN mkdir /app

COPY src/entrypoint.sh /app/entrypoint.sh

USER vault
ENTRYPOINT ["/usr/bin/bash", "/app/entrypoint.sh"]