# CoreOS based Kubernetes cluster for development and testing

_The `Vagrantfile` in this directory is a symlink to the `Vagrantfile` in the `coreos-vagrant` submodule. Do not edit the `Vagrantfile` here._

## Prepare

The [submodule](https://coreos.com/os/docs/latest/booting-on-vagrant.html) we're using presents with a few pre-requisites.

After cloning this repository, from the directory where you find _this_ file, execute

`git submodule update --init --recursive`

This should populate the directory `coreos-vagrant` with files from its source repository including the `Vagrantfile` that we require.

### Set Number of Nodes

Change the number of nodes in `config.rb`. It is set to `5` by default.

```
# Size of the CoreOS cluster created by Vagrant
$num_instances=5
```

### Generate SSL Keys and Certificates for the Nodes

Once you have decided the number of nodes, execute `create-keys.sh` located in the current directory with _number of nodes_ as the first parameter.

`./create-keys.sh 5`

## Use

To use each distinct cluster, change into the directory representing that cluster and follow the instructions that follow.

### Start Your Cluster

Be prepared to be amazed and execute

`vagrant up`

### Stare in Awe and With Wonder

Vagrant will download the requisite images and stand up number of nodes as you have specified. The first node is the master and the others are worker nodes. Currently, pods can be scheduled on the master as well. A detailed explanation of the setup follows.

### Check Cluster Status

`vagrant status`

### SSH into a Node

`vagrant ssh _<node_name>`

For example, to SSH into `core-01`, which is the master node, execute

`vagrant ssh core-01`

### Stop Your cluster

`vagrant halt`

To restart your cluster, execute `vagrant up`. VirtualBox doesn't bring the VMs back up nicely. It is better in this case to leave the cluster running or to destroy and reprovision.

### Destroy Your Cluster

`vagrant destroy`

This will ask you to confirm deletion of every node. You can choose to destroy a single node by executing

`vagrant destroy _<node_name>_`

You can destroy everything and not have `vagrant` ask you by executing

`vagrant destroy -f`

### Reprovision

You can reprovision any single node by executing

`vagrant up --provision _<node_name>_`

To provision everything again, execute

`vagrant up --provision`

## Nodes

## Services

_This_ repository sets services to be assigned IP addresses from the range `192.168.211.129` through to `192.168.211.254`. This'll need to be modified if you are setting up [more than one cluster](#setting-up-more-than-one-cluster).

## Container Networking

The Kubernetes nodes are setup with Flanneld. This allows all containers to see all other containers on the same cluster irrespective of the nodes hosting the containers. Since Flanneld sets up as overlay network, this doesn't really need to change when you setup more clusters.

`config.rb` will recode the `etcd_endpoints` for `flannel` on every run to point to the first node's IP address. When you change the IP address subnet used to assign node IP addresses, `config.rb` will recode the `etcd_endpoints` for `flannel` per the new network. You'll learn more about this in the [next section](#setting-up-more-than-one-cluster).

## Setting Up More Than One Cluster

Each directory where you've cloned _this_ repository and run the _Prepare_ setups above will be ready to bring up a cluster. You can clone _this_ repository in other distinct directories and execute the steps in _Prepare_ in each of those directories to setup more Kubernetes clusters.

### Configure Node Subnet

You will need to change the subnet used by nodes of each cluster. If there's just one cluster, don't bother with this. However, if you are running more than one cluster, this is a necessity.

Edit `config.rb`, find the below line and edit it to change the third octet to something different from other cluster.

```
$private_vm_network_prefix = "192.168.211"
```

#### Simply Speaking...

This repository assumes that all networks from `192.168.211.0/24` through to `192.168.220.0/24` are reserved for nodes and services. The first half of this subnet i.e. `.0/25` is reserved for the nodes and `.128/25` for services. The nodes get a subnet but services just get an IP address.

For each new cluster setup on the same machine, keep incrementing the third octet till you reach `220` and then stop.

### Service Cluster IP Addresses

Edit `user-data-master` and find the line that sets the service cluster ip address range for Kubernetes API Server. In the repository, the line is as follows

```
        --service-cluster-ip-range=192.168.211.128/25 \
```

Increment the third octet just as you did with `config.rb` in the previous section to change node networking.

Networks from `192.168.221.0/24` through to `192.168.230.0/24` are reserved for service cluster ip addresses.

### Change the Master IP in the Worker Configuration

Nodes other than the first node need to be told where to look for the Kubernetes API server. Edit `user-data-worker` and find the following two lines.

```
        --api-servers=http://192.168.211.11:8080 \
```

```
        --master=http://192.168.211.11:8080 \
```

The first line configures `kubelet` and the second line configures the `kube-proxy`. The IP addresses there should be the IP address of the first node. You only need to change the third octet. This is the same as the third octet [you configured earlier](#configure-node-subnet). The first node currently always gets an IP address with the host portion set to `11`. The other nodes follow on from there with the host portion set to `12`, `13`, `14` and so on for the second, third and fourth nodes. You get the idea.
