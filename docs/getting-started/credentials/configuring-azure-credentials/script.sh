#!/bin/bash
set -e

echo '== Setup'

### Select a subscription

SUBSCRIPTIONS=$(az account list)

echo 'Available subscriptions: '
echo "$SUBSCRIPTIONS" | jq -r '(["ID","NAME", "IS_DEFAULT"] | (., map(length*"-"))), (.[] | [.id, .name, .isDefault]) | @tsv' | column -ts $'\t'
echo

while true; do
  echo -n 'Enter subscription id: '
  read -r SELECTED_SUBSCRIPTION_ID

  SELECTED_SUBSCRIPTION=$(echo "$SUBSCRIPTIONS" | jq -r --arg id "$SELECTED_SUBSCRIPTION_ID" '.[]|select(.id==$id)')

  if [[ $SELECTED_SUBSCRIPTION ]]; then
    break
  fi
done

echo "Press enter to continue.."
read -r REPLY

### Import CAST.AI image gallery app

echo '== Importing CAST.AI image gallery'
CASTAI_APP_ID=4cd32c25-7f26-45a5-a86b-d396e1d864ed

CASTAI_APP_SP=$(az ad sp list --query "[?appId=='$CASTAI_APP_ID']" --all | jq -r 'first(.[])')
if [[ $CASTAI_APP_SP == "" ]]; then
  echo '. Creating service principal'
  az ad sp create --id "$CASTAI_APP_ID" -o none
else
  echo ". Using existing service principal"
fi

### Create app registration and assign roles

echo '== Registering app'
echo '. Creating app registration'
APP_ID=$(az ad app create --display-name 'CAST.AI' --only-show-errors | jq -r '.appId')
APP_SECRET=$(az ad app credential reset --id "$APP_ID" --years 1000 --only-show-errors | jq -r '.password')

APP_SP=$(az ad sp list --query "[?appId=='$APP_ID']" --all | jq -r 'first(.[])')
if [[ $APP_SP == "" ]]; then
  echo '. Creating service principal'
  az ad sp create --id "$APP_ID" -o none
else
  echo ". Using existing service principal"
fi

# assign roles to the apps
echo '== Assigning roles to the app'
sleep 8s # a new service principal is not usable for role assignment instantly, neither after couple of seconds.. :)

echo '. Assigning Contributor role to CAST.AI app'
az role assignment create --assignee "$CASTAI_APP_ID" --role 'Contributor' -o none

echo '. Assigning Contributor role to CAST.AI shared images app'
az role assignment create --assignee "$APP_ID" --role 'Contributor' -o none

### Print results

echo "--------------------------------------------------------------------------------"
echo "Save and use the following json to onboard credentials into CAST.AI"
cat << EOF
{
  "subscriptionId": "$SELECTED_SUBSCRIPTION_ID",
  "tenantId": "$(echo "$SELECTED_SUBSCRIPTION" | jq -r '.tenantId')",
  "clientId": "$APP_ID",
  "clientSecret": "$APP_SECRET"
}
EOF
