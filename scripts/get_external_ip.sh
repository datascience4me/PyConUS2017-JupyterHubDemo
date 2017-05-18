
. .setup

kubectl --no-headers --namespace=$NAMESPACE get svc proxy-public | awk '{ print $3; }'

