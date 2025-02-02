#!/bin/bash

export VAULT_ADDR=https://127.0.0.1:8200
VAULT_SHUTDOWN=0

trap "VAULT_SHUTDOWN=1" SIGINT SIGTERM

while [ $VAULT_SHUTDOWN -eq 0 ];
do

  VAULT_STATUS_INIT=$(vault status -format=json | jq -r .initialized)

  if [ -z "$VAULT_STATUS_INIT" ]; then
    printf "Unable to determine vault init state: vault service running?\n"
    sleep 5
    continue
  fi

  if [ "$VAULT_STATUS_INIT" = "true" ]; then
    printf "Vault currently initialized: [%s]\n" "$VAULT_STATUS_INIT"
    sleep 5
    continue
  fi

done

exit 0
