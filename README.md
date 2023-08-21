
# requirements
- a running kubernetes cluster (the management cluster) used to provision the workload cluster, kind can be used but is not recommended
- a hetzner cloud project with an api token and an ssh key

## prepare
copy .env.example to .env and adjust the values as needed
``` shell
# load environment variables
source .env

# initialize the cluster api components in the management cluster
KUBECONFIG=$CAPI_KUBECONFIG clusterctl init --core cluster-api --bootstrap kubeadm --control-plane kubeadm --infrastructure hetzner

# setup token
KUBECONFIG=$CAPI_KUBECONFIG kubectl create secret generic hetzner --from-literal=hcloud=$HCLOUD_TOKEN
KUBECONFIG=$CAPI_KUBECONFIG kubectl patch secret hetzner -p '{"metadata":{"labels":{"clusterctl.cluster.x-k8s.io/move":""}}}'
```

## provision
``` shell
# (optional) create examples cluster manifests
KUBECONFIG=$CAPI_KUBECONFIG clusterctl generate cluster $CLUSTER_NAME > $CLUSTER_NAME.yaml

# apply the manifests to create the cluster
KUBECONFIG=$CAPI_KUBECONFIG kubectl apply -f .

# see status of cluster
KUBECONFIG=$CAPI_KUBECONFIG clusterctl describe cluster $CLUSTER_NAME

# get kubeconfig
KUBECONFIG=$CAPI_KUBECONFIG clusterctl get kubeconfig $CLUSTER_NAME > ~/.kube/$CLUSTER_NAME

# check that everything is up and running
KUBECONFIG=~/.kube/$CLUSTER_NAME kubectl get pods -A
```