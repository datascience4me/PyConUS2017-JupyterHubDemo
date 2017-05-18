
. .setup

if [ "$1" = "-a" ];then
    CMD="gcloud container clusters delete --zone=$ZONE $NAMESPACE"
    echo $CMD
    eval $CMD
    exit 0
fi

CMD="helm delete --purge $RELEASE"
echo $CMD
eval $CMD


CMD="kubectl --namespace=$NAMESPACE delete pods --all"
echo $CMD
eval $CMD




