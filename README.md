# hello-world

A simple hello-world web application running with a non-root user on Alpine Linux in a Docker container.

## Prerequisites

Docker
Helm

## Build

```
docker build --platform=linux/amd64 -t hello-world .
```

## Run

```
docker run -it -p 8080:8080 --rm --name hello-world ghcr.io/rhowellsr-2020/hello-world/hello-world:main
```

Visit http://localhost:8080 in a web browser.

## Push to GHCR

### Create a new GitHub Personal Access Token

Follow instructions as seen on:

https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry


### Push image to GHCR

```
REGISTRY=ghcr.io/rhowells-2020
GH_REPO=hello-world
IMAGE_NAME=hello-world
TAG=main
IMAGE_URL=${REGISTRY}/${GH_REPO}/${IMAGE_NAME}:${TAG}

docker build --platform=linux/amd64 -t ${IMAGE_URL} .
docker push ${IMAGE_URL}
```

## Deploy to Kubernetes

### Helm Install

```
INGRESS_HOSTNAME=
KUBE_NAMESPACE=hello-world

helm -n ${KUBE_NAMESPACE} install hello-world ./charts/hello-world --set ingress.hostname=${INGRESS_HOSTNAME}
```

### Helm Flux Operator

```
cat <<EOF | kubectl -n ${KUBE_NAMESPACE} apply -f -
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: hello-world
spec:
  interval: 1h
  url: https://github.com/appvia/hello-world
  ref:
    branch: main
EOF

cat <<EOF | kubectl -n ${KUBE_NAMESPACE} apply -f -
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: hello-world
spec:
  releaseName: hello-world
  interval: 1h
  chart:
    spec:
      chart: charts/hello-world
      sourceRef:
        kind: GitRepository
        name: hello-world
        namespace: ${KUBE_NAMESPACE}
  values:
    ingress:
      hostname: ${INGRESS_HOSTNAME}
EOF
```
