export EXP_CLUSTER_RESOURCE_SET=true

kind create cluster --name capi-kind --kubeconfig ~/.kube/capi-kind

KUBECONFIG=~/.kube/capi-kind clusterctl init --infrastructure hetzner --addon helm

KUBECONFIG=~/.kube/capi-kind velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.2.1 \
    --bucket danielrichtercodes-capi-kind \
    --secret-file ./tools/backblaze.ini \
    --use-volume-snapshots=false \
    --backup-location-config region=s3.us-west-004,s3Url=https://s3.us-west-004.backblazeb2.com