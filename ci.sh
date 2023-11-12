helm package chart -d dist
helm push dist/clusterapi-hcloud-1.2.0.tgz oci://ghcr.io/danielr1996