
. .setup

TIME=time


if [ "$1" = "-a" ];then
    CMD="$TIME gcloud container clusters delete --zone=$ZONE $NAMESPACE"
    echo $CMD
    eval $CMD
    exit 0
fi

echo
echo "Use option -a to delete also the gcloud cluster"
echo

CMD="$TIME helm delete --purge $RELEASE"
echo $CMD
eval $CMD


CMD="$TIME kubectl --namespace=$NAMESPACE delete pods --all"
echo $CMD
eval $CMD




