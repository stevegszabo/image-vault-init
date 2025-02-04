#!/bin/bash

VAULT_SHUTDOWN=0

GCLOUD_PROJECT=${GCLOUD_PROJECT-project}
GCLOUD_ACCOUNT=${GCLOUD_ACCOUNT-email}
GCLOUD_CONFIGS=$HOME/.config/gcloud/configurations

mkdir -p $GCLOUD_CONFIGS

cat > $GCLOUD_CONFIGS/config_default <<EOF
[core]
account = $GCLOUD_ACCOUNT
project = $GCLOUD_PROJECT
disable_usage_reporting = False
EOF

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

    printf "Initializing Vault\n"
    vault operator init

done

exit 0
