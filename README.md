# clusterapi-hcloud
helm chart to deploy a kubernetes cluster on hcloud using [clusterapi](https://cluster-api.sigs.k8s.io/)

## why
The clusterapi project enables us to deploy a kubernetes cluster declaratively using kubernetes CRDs which is a huge step forward compared to 
the traditional imperative tools like kubeadm, kops, kubespray, etc.
But still, deploying and maintaining a cluster requires writing many manifests and tweaking values across those manifests. 
Furthermore, these manifests must be duplicated each time a new cluster needs to be deployed.

The projects approach to this is the [ClusterClass](https://cluster-api.sigs.k8s.io/tasks/experimental-features/cluster-class/index.html) CRD which allows to solve the mentioned issues
in a kubernetes native way, without assuming anything other than a kubernetes cluster and the various clusterapi components. 

Unfortunately `ClusterClass`es are still *very* alpha and after a few experiments with it I decided that it's easier for me to just use helm since I, and probably you are already familier with helm.

Also in comparison to what `clusterctl generate ...` gives you, I decided to include some addons, without which the cluster would be pretty useless, namely the hetzner cloud controller manager, a cni plugin and a csi driver. 

## usage
### requirements
#### management cluster
clusterapi requires a management cluster where the various controller components and the CRDs defining your cluster live. This can be any cluster but the project discourages the use of kind and recommends proper backup policies. With that said I have found that it's possible to start a kind cluster, deploy the workload cluster, stop the cluster and everything works fine. Theoretically it should also be possible to backup the CRDs with something like velero and be safe, but do this on your own risk. If you loose the backup your workload cluster will work fine, but you cannot modify it anymore because clusterapi lost track of it existing. 

I would recommend creating a new kind cluster *specifically* for clusterapi since sometimes nuking everything and starting from scratch is sometimes easier. Choose an existing cluster or create a new kind cluster with
```shell
kind create cluster --name clusterapi
```
Refer to the [kind project](https://kind.sigs.k8s.io/) for more information if you are unfamiliar with kind.

> Since you will be switching between the management and workload clusters quite often I would recommand something like [kubectx](https://github.com/ahmetb/kubectx)

Then install the clusterapi into the management cluster with
```
clusterctl init --core cluster-api --bootstrap kubeadm --control-plane kubeadm --infrastructure hetzner --addon helm
```

### hetzner cloud project
Login to the [Hetzner Cloud Console](https://console.hetzner.cloud/projects) and create a new project.
In the created project go to "Sicherheit->SSH-Keys" and upload the public ssh key. Take note of the name of the key since you have to provide in the values later. 
Next go to "Sicherheit->API-Tokens" and create a new read/write token. Also take note of the key for later.

### create cluster
To create the cluster adjust the values in `example.values.yaml` to your needs and simple run
```shell
helm upgrade --install example-cluster oci://ghcr.io/danielr1996/clusterapi-hcloud -f example-values.yaml 
```

Helm will print some notes what you can do now with your cluster, if you want to recall them run
```shell
helm get notes example-cluster
```

## day2 operations

day2 operations includes everything that comes *after* initially deploying the cluster, e.g. rescaling nodes, updating kubernetes version, changing machine type

https://cluster-api.sigs.k8s.io/tasks/upgrading-clusters

## references
[clusterapi](https://cluster-api.sigs.k8s.io/)
[kind](https://kind.sigs.k8s.io/)
[cluster api provider hetzner](https://github.com/syself/cluster-api-provider-hetzner)
[hetzner cloud controller manager](https://github.com/hetznercloud/hcloud-cloud-controller-manager)
[flannel](https://github.com/flannel-io/flannel)
[hetzner csi-driver](https://github.com/hetznercloud/csi-driver)