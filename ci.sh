helm package chart -d dist
helm push dist/clusterapi-hcloud-1.0.0-beta.4.tgz oci://ghcr.io/danielr1996