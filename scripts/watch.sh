
#NAMESPACE=jhub
#[ ! -z "$1" ] && NAMESPACE=$1

[ -f ../.setup ] && . ../.setup
[ -f ./.setup ] && . ./.setup

export PATH=~/MINIKUBE/bin_0.19.0:$PATH

HDRS="--no-headers"

function setup_colour_stuff {

    #  NORMAL;           BOLD;                 INVERSE;
    _black='\e[00;30m';  _L_black='\e[01;30m';  _I_black='\e[07;30m'
    _white='\e[00;37m';  _L_white='\e[01;37m';  _I_white='\e[07;37m'
    _red='\e[00;31m';    _L_red='\e[01;31m';    _I_red='\e[07;31m'
    _green='\e[00;32m';  _L_green='\e[01;32m'   _I_green='\e[07;32m'
    _yellow='\e[00;33m'; _L_yellow='\e[01;33m'  _I_yellow='\e[07;33m'
    _blue='\e[00;34m'    _L_blue='\e[01;34m'    _I_blue='\e[07;34m'
    _magenta='\e[00;35m' _L_magenta='\e[01;35m' _I_magenta='\e[07;35m'
    _cyan='\e[00;36m'    _L_cyan='\e[01;36m'    _I_cyan='\e[07;36m'

    _norm='\e[00m'

    black()   { echo -en $_black;   echo -n "$*" ; echo -en $_norm; }
    white()   { echo -en $_white;   echo -n "$*" ; echo -en $_norm; }
    red()     { echo -en $_red;     echo -n "$*" ; echo -en $_norm; }
    green()   { echo -en $_green;   echo -n "$*" ; echo -en $_norm; }
    yellow()  { echo -en $_yellow;  echo -n "$*" ; echo -en $_norm; }
    blue()    { echo -en $_blue;    echo -n "$*" ; echo -en $_norm; }
    magenta() { echo -en $_magenta; echo -n "$*" ; echo -en $_norm; }
    cyan()    { echo -en $_cyan;    echo -n "$*" ; echo -en $_norm; }

    #red "Hello world "; yellow "from "; blue "BLUE!!"
}

setup_colour_stuff

CMD_NODES="kubectl get $HDRS nodes"
CMD_PODS="kubectl --namespace=$NAMESPACE get $HDRS pod"
CMD_SVC_PP="kubectl --namespace=$NAMESPACE get svc proxy-public"

watch -t --color \
    "echo \"watch \$(date)\";
     echo -e \"\n$(green get nodes):     $ $(red $CMD_NODES)\";  $CMD_NODES;
     echo -e \"\n$(green get pods):      $ $(red $CMD_PODS)\";   $CMD_PODS;
     echo -e \"\n$(green Get public ip): $ $(red $CMD_SVC_PP)\"; $CMD_SVC_PP"



