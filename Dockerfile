FROM ubuntu:22.04

RUN apt-get update && apt-get upgrade -y && apt-get install -y lsb-release gpg wget jq python3 python3-pip python3.10-venv && apt-get clean
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
RUN apt-get update && apt-get install --reinstall -y vault

COPY src/entrypoint.sh /home/vault/entrypoint.sh
RUN chown -R vault:vault /home/vault

USER vault
RUN python3 -m venv /home/vault/environment && . /home/vault/environment/bin/activate && pip3 install awscli
ENTRYPOINT ["/usr/bin/bash", "/home/vault/entrypoint.sh"]