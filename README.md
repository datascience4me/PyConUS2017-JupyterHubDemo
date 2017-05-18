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

This stage will create a cluster of VMs to host our JupyterHub.

It will then install the Kubernetes Helm tool, download the *chart* file for the JupyterHub application and "helm install" the application.

```sh
    ./scripts/setup.sh -1
```

**NOTE**: If the helm install is run *too early* it may be necessary to rerun this step, in this case invoked with the '*-1a*' option.

```sh
          ./scripts/setup.sh -1a
```

Once this setup stage is complete, you can connect to the external-ip of your JupyterHub deployment using a browser.

There is no real authentication implemented, you can enter any valid username (valid to be used as part of the pod name) and password at this point.

Once logged in start a server and you should be connected to the familiar Jupyter server interface.

The docker image used for the Jupyter server is jupyter/base-notebook, part of the jupyter/docker-stack github repository.

This image is a Debian based 200MBy image - quite small.



## Stage2:

Checkout the ipython-in-depth repo so that we can run those examples under the minimal-notebook image.

```sh
    cd MyImageDir
    git clone https://github.com/ipython/ipython-in-depth
    cd -
```

Then launch the setup script which will
- Build a docker image derived from base-notebook
  - including our copy of the ipython-in-depth repo
- Tag and upload our image to Docker Hub
  - Note: online examples use gcr.io also
- Modify the helm Chart file (config.yaml) to reference this image
- Perform a "helm upgrade" of our deployment.

```sh
    ./scripts/setup.sh -2
```

Once the deployment is available you will see that existing Jupyter servers (identified as jupyter-<user>-<num> pods) are still running.

Now if you logout and login again you will have a Jupyter server running our latest image with ipython-in-depth files available to us.

## Stage3:

Stage3 opts to use a more functional jupyter/minimal-notebook as the base image.

The Dockerfile *Dockerfile.minimal-notebook* then installs the bash_kernel module.

We again build and tag the new image, push it to Docker Hub and then
modify the helm Chart file to refer to this image.

Deploy this upgrade using:

```sh
    ./scripts/setup.sh -3
```

Once the "helm upgrade" is complete then new Jupyter servers will have te bash_kernel as well as Python3 kernels available.

There's even a sample bash array tutorial notebook to try out.



