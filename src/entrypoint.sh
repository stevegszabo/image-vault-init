#!/bin/bash

VAULT_SHUTDOWN=0
VAULT_RECOVER_INDEX=1
VAULT_INIT_FILE=$HOME/init
VAULT_SEAL_FILE=$VAULT_INIT_FILE.json

GCLOUD_PROJECT=${GCLOUD_PROJECT-project}
GCLOUD_LOCATIONS=${GCLOUD_LOCATIONS-locations}
GCLOUD_ACCOUNT=${GCLOUD_ACCOUNT-email}
GCLOUD_SECRET=${GCLOUD_SECRET-secret}
GCLOUD_CONFIGS=$HOME/.config/gcloud/configurations

mkdir -p $GCLOUD_CONFIGS

cat > $GCLOUD_CONFIGS/config_default <<EOF
[core]
account = $GCLOUD_ACCOUNT
project = $GCLOUD_PROJECT
disable_usage_reporting = True
EOF

GCLOUD_PROJECT_ID=$(gcloud projects describe $GCLOUD_PROJECT --format=json | jq -r .projectNumber)
GCLOUD_SECRET_ID=projects/$GCLOUD_PROJECT_ID/secrets/$GCLOUD_SECRET
GCLOUD_SECRET_FILTER=$(printf '.[]|select(.name == "%s")' $GCLOUD_SECRET_ID)

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

    printf "Update secret: [%s][%s]\n" "$GCLOUD_SECRET" "$VAULT_SECRET_VALUE"

    echo $VAULT_SECRET_VALUE > $VAULT_SEAL_FILE

    if [ -z "$(gcloud secrets list --project=$GCLOUD_PROJECT --format=json | jq -r "$GCLOUD_SECRET_FILTER")" ]; then
        gcloud secrets create $GCLOUD_SECRET --data-file=$VAULT_SEAL_FILE --project=$GCLOUD_PROJECT --replication-policy=user-managed --locations=$GCLOUD_LOCATIONS
    else
        gcloud secrets versions add $GCLOUD_SECRET --data-file=$VAULT_SEAL_FILE --project=$GCLOUD_PROJECT
    fi

done

exit 0
