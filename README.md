# CoreOS Based Kubernetes Cluster for Development and Testing
<!-- TOC -->

- [CoreOS Based Kubernetes Cluster for Development and Testing](#coreos-based-kubernetes-cluster-for-development-and-testing)
    - [Prepare](#prepare)
        - [Set Number of Nodes](#set-number-of-nodes)
        - [Generate SSL Keys and Certificates for the Nodes](#generate-ssl-keys-and-certificates-for-the-nodes)
    - [Use](#use)
        - [Start Your Cluster](#start-your-cluster)
        - [Stare in Awe and With Wonder](#stare-in-awe-and-with-wonder)
        - [Check Cluster Status](#check-cluster-status)
        - [SSH Into a Node](#ssh-into-a-node)
        - [Port Forward to a Node](#port-forward-to-a-node)
            - [Using SSH Command Line Options](#using-ssh-command-line-options)
            - [Changing an Active SSH Connection](#changing-an-active-ssh-connection)
            - [Make a Change to _config.rb_](#make-a-change-to-_configrb_)
        - [Stop Your cluster](#stop-your-cluster)
        - [Destroy Your Cluster](#destroy-your-cluster)
        - [Reprovision](#reprovision)
    - [Nodes](#nodes)
    - [Services](#services)
    - [Container Networking](#container-networking)
    - [Setting Up More Than One Cluster](#setting-up-more-than-one-cluster)
        - [Configure Node Subnet](#configure-node-subnet)
            - [Simply Speaking...](#simply-speaking)
        - [Service Cluster IP Addresses](#service-cluster-ip-addresses)
        - [Change the Master IP in the Worker Configuration](#change-the-master-ip-in-the-worker-configuration)

<!-- /TOC -->

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

### SSH Into a Node

`vagrant ssh <node>`

For example, to SSH into `core-01`, which is the master node, execute

`vagrant ssh core-01`

### Port Forward to a Node

There are three ways to forward ports on your local machine where Vagrant is running, the _host_ to the nodes i.e. the _guests_. These are discussed below.

#### Using SSH Command Line Options

The command `vagrant ssh <node>` takes in parameters to pass to the SSH client. These parameters are made distinct from the Vagrant command by inserting a `--` between the command and the parameters to be passed to the SSH client.

Assume for this example that you'd like to forward port `8080` on the host to the first node `core-01`. This is the node that runs the Kubernetes master. To effect this port forward, the command you'd execute would be

```
vagrant ssh core-01 -- -L8080:localhost:8080
```

**Before Forwarding Ports**
```
$ curl -o /dev/null -s -v http://localhost:8080
* Rebuilt URL to: http://localhost:8080/
*   Trying ::1...
* TCP_NODELAY set
* Connection failed
* connect to ::1 port 8080 failed: Connection refused
*   Trying 127.0.0.1...
* TCP_NODELAY set
* Connection failed
* connect to 127.0.0.1 port 8080 failed: Connection refused
* Failed to connect to localhost port 8080: Connection refused
* Closing connection 0
```

**After Forwarding Ports**
```
$ curl -o /dev/null -s -v http://localhost:8080
* Rebuilt URL to: http://localhost:8080/
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8080 (#0)
> GET / HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.51.0
> Accept: */*
>
< HTTP/1.1 200 OK
< Content-Type: application/json
< Date: Tue, 25 Apr 2017 04:32:05 GMT
< Content-Length: 967
<
{ [967 bytes data]
* Curl_http_done: called premature == 0
* Connection #0 to host localhost left intact
```

#### Changing an Active SSH Connection

You can change an active SSH connection that you started using `vagrant ssh <node>` by using the SSH escape sequence.

After initiating an SSH connection

```
vagrant ssh core-01
```

... insert a new line and type in `~C`. Note the upper case of the letter `C`.

```
$
$
ssh> 
```

You can now modify the port forward settings of the active SSH connection. Enter

```
-L8080:localhost:8080

```

You'll need to hit _Enter_ twice.

... to forward host port 8080 to port 8080 on the guest.

To check if this worked, you can borrow the test demonstrated in [the previous section](#using-ssh-command-line-options)

#### Make a Change to _config.rb_

Change the variable `$forwarded_ports` in `config.rb` and assign it a map of all ports you want forwarded. The _key_ is the port on the guests i.e. the nodes, and _value_ is the port on the host.

```
# Forward ports 2500 and 5300 on the host to ports 25 and 53 on the nodes

$forwarded_ports = { "25" => "2500", "53" => "5300" }
```

These port forwards will be setup by Vagrant when you bring the environment up.

Since configuration specified as above will apply to every node in the cluster, Vagrant will have to pick ports on the host so that each specified port on the nodes gets a unique port on the host. Therefore, you'll need to query Vagrant for each node to see which exact host ports have been picked to forward to the remote ports on the node. To do so, execute

`vagrant port <node>`

For example, to check ports forwarded to `core-01`, execute

`vagrant port core-01`

... which, considering the configuration above for `$forwarded_ports`, will output

```
The forwarded ports for the machine are listed below. Please note that
these values may differ from values configured in the Vagrantfile if the
provider supports automatic port collision detection and resolution.

    22 (guest) => 2222 (host)
    25 (guest) => 2500 (host)
    53 (guest) => 5300 (host)
```

The same command executed for `core-02`

`vagrant port core-02`

... will output

```
The forwarded ports for the machine are listed below. Please note that
these values may differ from values configured in the Vagrantfile if the
provider supports automatic port collision detection and resolution.

    22 (guest) => 2202 (host)
    25 (guest) => 2200 (host)
    53 (guest) => 2201 (host)
```

As you can see, while the guest ports are the same, the host ports are different.

### Stop Your cluster

`vagrant halt`

To restart your cluster, execute `vagrant up`. VirtualBox doesn't bring the VMs back up nicely. It is better in this case to leave the cluster running or to destroy and reprovision.

### Destroy Your Cluster

`vagrant destroy`

This will ask you to confirm deletion of every node. You can choose to destroy a single node by executing

`vagrant destroy <node>`

You can destroy everything and not have `vagrant` ask you by executing

`vagrant destroy -f`

### Reprovision

You can reprovision any single node by executing

`vagrant up --provision <node>`

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
