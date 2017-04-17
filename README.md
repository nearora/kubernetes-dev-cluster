# CoreOS based Kubernetes cluster for development and testing

_The `Vagrantfile` in this directory is a symlink to the `Vagrantfile` in the `coreos-vagrant` submodule. Do not edit the `Vagrantfile` here._

## Prepare

The [submodule](https://coreos.com/os/docs/latest/booting-on-vagrant.html) we're using presents with a few pre-requisites.

After cloning this repository, from the directory where you find _this_ file, execute

`git submodule update --init --recursive`

This should populate the directory `coreos-vagrant` with files from its source repository including the `Vagrantfile` that we require.

### Set number of nodes

Change the number of nodes in `config.rb`. It is set to `5` by default.

```
# Size of the CoreOS cluster created by Vagrant
$num_instances=5
```

### Generate SSL keys and certificates for nodes

Once you have decided the number of nodes, execute `create-keys.sh` located in the current directory with _number of nodes_ as the first parameter.

`./create-keys.sh 5`

## Start your cluster

Be prepared to be amazed and execute

`vagrant up`

## Stare in awe and with wonder

Vagrant will download the requisite images and stand up number of nodes as you have specified. The first node is the master and the others are worker nodes. Currently, pods can be scheduled on the master as well. A detailed explanation of the setup follows.

## Services

## Networking

## Notes

### Hyperkube kubelet

`--config` option has been changed to `--pod-manifest-path` in latter versions.
