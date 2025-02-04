#!/bin/bash

VAULT_SHUTDOWN=0
VAULT_RECOVER_INDEX=1
VAULT_INIT_FILE=$HOME/init

GCLOUD_PROJECT=${GCLOUD_PROJECT-project}
GCLOUD_LOCATION=${GCLOUD_LOCATION-location}
GCLOUD_ACCOUNT=${GCLOUD_ACCOUNT-email}
GCLOUD_CONFIGS=$HOME/.config/gcloud/configurations

mkdir -p $GCLOUD_CONFIGS

cat > $GCLOUD_CONFIGS/config_default <<EOF
[core]
account = $GCLOUD_ACCOUNT
project = $GCLOUD_PROJECT
disable_usage_reporting = True
EOF

gcloud kms keyrings list --project=$GCLOUD_PROJECT --location=$GCLOUD_LOCATION






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

    vault operator init > $VAULT_INIT_FILE

    VAULT_TOKEN="$(grep 'Initial Root Token' $VAULT_INIT_FILE | awk -F: '{print $NF}' | tr -d ' ')"
    VAULT_SECRET_VALUE=$(printf '"root": "%s"' "$VAULT_TOKEN")

    for VAULT_RECOVER_KEY in $(grep 'Recovery Key' $VAULT_INIT_FILE | awk '{print $NF}' | tr -d ' ')
    do
        VAULT_SECRET_VALUE=$(printf '%s, "recovery-%d": "%s"' "$VAULT_SECRET_VALUE" "$VAULT_RECOVER_INDEX" "$VAULT_RECOVER_KEY")
        VAULT_RECOVER_INDEX=$((VAULT_RECOVER_INDEX+1))
    done

    printf "VAULT_SECRET_VALUE: [%s]\n" "$VAULT_SECRET_VALUE"

done

exit 0
