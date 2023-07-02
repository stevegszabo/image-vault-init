#!/bin/bash

#set -o errexit
#set -o pipefail

VAULT_ENVIRONMENT=${VAULT_ENVIRONMENT-eks-engineering-01}
VAULT_INIT_FILE=$HOME/$VAULT_ENVIRONMENT
VAULT_VIRTUAL=$HOME/environment/bin/activate
VAULT_SECRET_MANAGER=$VAULT_ENVIRONMENT-vault
VAULT_RECOVER_INDEX=1
VAULT_SHUTDOWN=0

[ -f $VAULT_VIRTUAL ] && source $VAULT_VIRTUAL

export VAULT_ADDR=http://localhost:8200/

trap "VAULT_SHUTDOWN=1" SIGINT SIGTERM

while [ $VAULT_SHUTDOWN -eq 0 ];
do

  VAULT_STATUS_INIT=$(vault status -format=json | jq -r .initialized)

  if [ -z "$VAULT_STATUS_INIT" ]; then
    printf "Unable to determine vault state: vault service running?\n"
    sleep 60
    continue
  fi

  if [ "$VAULT_STATUS_INIT" = "true" ]; then
    printf "Vault currently initialized: [%s]\n" "$VAULT_STATUS_INIT"
    sleep 60
    continue
  fi

  vault operator init > $VAULT_INIT_FILE

  VAULT_TOKEN="$(grep 'Initial Root Token' $VAULT_INIT_FILE | awk -F: '{print $NF}' | tr -d ' ')"
  VAULT_SECRET_VALUE=$(printf '"root": "%s"' "$VAULT_TOKEN")

  for VAULT_RECOVER_KEY in $(grep 'Recovery Key' $VAULT_INIT_FILE | awk '{print $NF}' | tr -d ' ')
  do
    VAULT_SECRET_VALUE=$(printf '%s, "recovery-%d": "%s"' "$VAULT_SECRET_VALUE" "$VAULT_RECOVER_INDEX" "$VAULT_RECOVER_KEY")
    VAULT_RECOVER_INDEX=$((VAULT_RECOVER_INDEX+1))
  done

  aws secretsmanager create-secret --name "$VAULT_SECRET_MANAGER" --secret-string "{$VAULT_SECRET_VALUE}"

  if [ $? -ne 0 ]; then
    printf "Unable to store secret in secret manager: [%s]\n" "$VAULT_SECRET_MANAGER"
    printf "Vault recovery keys can be found here: [%s]\n" "$VAULT_INIT_FILE"
  fi

done

exit 0
