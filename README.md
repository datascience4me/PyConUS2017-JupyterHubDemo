# PyConUS2017-JupyterHubDemo

Demo of deploying JupyterHub to Google Cloud using Helm plus extending images


**NOTE**: This deployment is totally insecure - not real authentication

Please refer to https://zero-to-jupyterhub-with-kubernetes.readthedocs.io for more complete instructions

## Run this demo
To run this demo clone this repository

```sh
    git clone https://github.com/mjbright/PyConUS2017-JupyterHubDemo
    cd PyConUS2017-JupyterHubDemo
```

Modify the .setup file to use your variables, such as NAMESPACE to use and docker hub login.


Then run the setup script selecting the appropriate stage:

## Stage1:

```sh
    ./scripts/setup.sh -1
```

## Stage2:

```sh
    ./scripts/setup.sh -2
```

Checkout the ipython-in-depth repo

```sh
    cd MyImageDir
    git clone https://github.com/ipython/ipython-in-depth
    cd -
```

## Stage3:

```sh
    ./scripts/setup.sh -3
```


