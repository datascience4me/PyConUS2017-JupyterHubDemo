

DO_STEPS=1

. .setup

## -- Functions: ---------------------------------------------
function die {
    echo "die: $0 - $*" >&2
    exit 1
}

function DO_STEP {
    CMD=$*

    yellow $CMD; echo
    [ $DO_STEPS -ne 0 ] && eval $CMD
}

function INITIAL_SETUP {
    ## -- STEP: create gcloud namespace:
    demo_header "First we create a new namespace (called $(hl $NAMESPACE)) $(green in our Google Cloud account)"
    
    TIMER_start
    DO_STEP "gcloud container clusters create $NAMESPACE \
    	    --num-nodes=3 \
    	        --machine-type=n1-highmem-2 \
    		    --zone=$ZONE"
    TIMER_quieter_time_taken
    
    ## -- STEP: download and install helm:
    demo_header "Download and install the $(hl helm) $(green utility)"
    
    if [ -z "$(which helm 2>/dev/null)" ];then
        DO_STEP curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
    else
        yellow "Helm is already installed"; echo
    fi
    
    ## -- STEP: Perform helm init
    demo_header "Perform $(hl helm init) $(green )"
    DO_STEP helm init
    
    ## -- STEP: Generate SSL keys
    demo_header "Generate $(hl SSL keys) $(green )"
    
    SSL_COOKIE=$(openssl rand -hex 32)
    SSL_PROXY=$(openssl rand -hex 32)
    
    DO_STEP SSL_COOKIE=$SSL_COOKIE
    DO_STEP SSL_PROXY=$SSL_PROXY
    
    ## -- STEP: Add SSL keys to config.yaml template
    demo_header "Generate $(hl config.yaml) $(green with SSL keys, from template)"
    
    DO_STEP "cat config.yaml.template"
    
    DO_STEP "sed -e 's/SSL_COOKIE/$SSL_COOKIE/' -e 's/SSL_PROXY/$SSL_PROXY/' < config.yaml.template > config.yaml"
    
    DO_STEP "cat config.yaml"
    
    ## -- STEP: Perform initial helm install:
    
    HELM_CHART_URL="https://github.com/jupyterhub/helm-chart/releases/download/v0.3/jupyterhub-v0.3.tgz"
    
    DO_STEP "helm install $HELM_CHART_URL
    	        --name=$RELEASE \
    		--namespace=$NAMESPACE \
    		-f config.yaml"

    cp -a config.yaml .config.yaml.1

    ## -- STEP: Get public ip of our service:

    DO_STEP kubectl --namespace=$NAMESPACE get svc proxy-public

    kubectl --no-headers --namespace=$NAMESPACE get svc proxy-public | awk '{ print $3; }'
}

function UPGRADE_DEPLOY {
    ## -- STEP: Build new docker image
    demo_header "We create a Dockerfile to build an image derived
        FROM $(hl jupyter/base-notebook)
	$(green with the git repo) $(hl ipython/ipython-in-depth) $(green included)"

    cp -a .config.yaml.1 config.yaml

    DO_STEP cat MyImageDir/Dockerfile

    demo_header "Now we build our new docker image"
    NB_IMAGE=my-notebook
    NB_TAG=latest

    DO_STEP docker build MyImageDir -t $DH_USER/$NB_IMAGE:$NB_TAG

    demo_header "... pushing our new image to docker hub"

    docker login -u $DH_USER -p $DH_PASSWD
    DO_STEP docker push $DH_USER/$NB_IMAGE:$NB_TAG

    demo_header "Now we add a new section to our yaml file using the $(hl config.yaml.template2) $(green file)"

    DO_STEP "sed -e \"s/IMAGE/$DH_USER\\\/$NB_IMAGE/\" \
	        -e \"s/TAG/$NB_TAG/\" \
                config.yaml.template2 | tee -a config.yaml"

    DO_STEP cat config.yaml

    demo_header "... and upgrade our helm deployment with this new
        $(hl config.yaml.template2) $(green file)"

    DO_STEP helm upgrade $RELEASE jupyterhub-v0.3.tgz -f config.yaml

}

function UPGRADE_DEPLOY_LARGER {
    ## -- STEP: Build new docker image
    demo_header "Let's now try to use a more complete notebook image, $(hl minimal-notebook)"

    cp -a .config.yaml.1 config.yaml

    DO_STEP cat MyImageDir/Dockerfile.minimal-notebook

    demo_header "Now we build our new docker image"
    NB_IMAGE=my-min-notebook
    NB_TAG=latest

    DO_STEP docker build MyImageDir -t $DH_USER/$NB_IMAGE:$NB_TAG -f MyImageDir/Dockerfile.minimal-notebook

    demo_header "... pushing our new image to docker hub"

    docker login -u $DH_USER -p $DH_PASSWD
    DO_STEP docker push $DH_USER/$NB_IMAGE:$NB_TAG

    demo_header "Now we add a new section to our yaml file using the $(hl config.yaml.template2) $(green file)"

    DO_STEP "sed -e \"s/IMAGE/$DH_USER\\\/$NB_IMAGE/\" \
	        -e \"s/TAG/$NB_TAG/\" \
                config.yaml.template2 | tee -a config.yaml"

    DO_STEP cat config.yaml

    demo_header "... and upgrade our helm deployment with this new
        $(hl config.yaml.template2) $(green file)"

    DO_STEP helm upgrade $RELEASE jupyterhub-v0.3.tgz -f config.yaml
}

####################
# timer functions:

function TIMER_convert_secs_to_hhmmss {
    local _REM_SECS=$1; shift
    
    let SECS=_REM_SECS%60

    let _REM_SECS=_REM_SECS-SECS

    let MINS=_REM_SECS/60%60

    let _REM_SECS=_REM_SECS-60*MINS

    let HRS=_REM_SECS/3600

    [ $SECS -lt 10 ] && SECS="0$SECS"
    [ $MINS -lt 10 ] && MINS="0$MINS"
}


function TIMER_quieter_time_taken {
    local _START_SECS=$START_SECS
    local _TOOK_SECS
    [ ! -z "$1" ] && _START_SECS=$1; shift
    
    END_SECS=$(date +%s)
    #echo "Started at $(date)   [$_START_SECS]"
    #echo "Ended   at $(date)   [$END_SECS]"
    
    let _TOOK_SECS=END_SECS-_START_SECS
    #echo "Took $_TOOK_SECS secs"

    TIMER_convert_secs_to_hhmmss $_TOOK_SECS
    [ $_TOOK_SECS -ge 60 ] &&
        echo "Took $_TOOK_SECS secs [${HRS}h${MINS}m${SECS}]" ||
        echo "Took $_TOOK_SECS secs"
}

function TIMER_time_taken {
    local _START_SECS=$START_SECS
    local _TOOK_SECS
    [ ! -z "$1" ] && _START_SECS=$1; shift

    END_SECS=$(date +%s)
    echo "Started at $(date)   [$_START_SECS]"
    echo "Ended   at $(date)   [$END_SECS]"
    
    let _TOOK_SECS=END_SECS-_START_SECS
    #echo "Took $_TOOK_SECS secs"

    TIMER_convert_secs_to_hhmmss $_TOOK_SECS
    [ $_TOOK_SECS -ge 60 ] &&
        echo "Took $_TOOK_SECS secs [${HRS}h${MINS}m${SECS}]" ||
        echo "Took $_TOOK_SECS secs"
}

function TIMER_start {
    START_SECS=$(date +%s)
    #echo "Notebook started at $(date)   [$START_SECS]"
}


## -- Main: --------------------------------------------------

if [ -z "$(which kubectl 2>/dev/null)" ];then
    die "kubectl is not on your PATH"
fi

while [ ! -z "$1" ]; do
	case $1 in
		-n) DO_STEPS=0;;

		-1) INITIAL_SETUP;;

		-2) UPGRADE_DEPLOY;;

                -3) UPGRADE_DEPLOY_LARGER;;

		*) die "Unknown option <$1>";;
	esac
	shift
done



exit 0


## -- END: ---------------------------------------------------

 1117  helm upgrade $NAMESPACE -f config.yaml
 1118  history
 1119  cat helm_install_jh.sh 
 1120  #helm upgrade $NAMESPACE -f config.yaml
 1121  ls
 1122  helm upgrade $NAMESPACE jupyterhub-v0.3.tgz -f config.yaml
 1123  more config.yaml
 1124  #helm upgrade $NAMESPACE jupyterhub-v0.3.tgz -f config.yaml
 1125  helm list
 1126  helm upgrade --help
 1127  #helm upgrade --help
 1128  helm upgrade v1 jupyterhub-v0.3.tgz -f config.yaml
 1129  helm list
 1130  history
 1131  helm delete --purge $NAMESPACE
 1132  helm list
 1133  helm delete --purge v1 $NAMESPACE
 1134  #helm delete --purge v1 $NAMESPACE
 1135  helm list
 1136  ./helm_install_jh.sh 
 1137  helm list
 1138  vi config.yaml
 1139  helm upgrade v1 jupyterhub-v0.3.tgz -f config.yaml
 1140  history
 1141  history > setup.sh
