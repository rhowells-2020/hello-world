# hello-world

A simple hello-world web application running with a non-root user on Alpine Linux in a Docker container.

**If you want to test this image directly on a Kubernetes Cluster, skip down to the ['Using a Kubernetes Deployment'](#using-a-kubernetes-deployment) section below.**

## Prerequisites

Docker
Helm

## Build

```
docker build --platform=linux/amd64 -t hello-world .
```

## Run

```
docker run -it -p 8080:8080 --rm --name hello-world ghcr.io/rhowells-2020/hello-world/hello-world:main
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

### Using a Kubernetes Deployment
- Copy the following yaml to a file called deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world
  labels:
    app: helloworld
spec:
  replicas: 1
  selector:
    matchLabels:
      app: helloworld
  template:
    metadata:
      labels:
        app: helloworld
    spec:
      containers:
      - name: hello-world
        image: ghcr.io/appvia/hello-world/hello-world:main
        ports:
        - containerPort: 8080
```

- Run `kubectl apply -f ./deployment.yaml` to apply the deployment to your kubernetes cluster.
- To expose the service you need to get the name of the pod created. Simply run `kubectl get pod`
- You should see a list similar to the following (I'm using the namespace called 'dev' to house my deployment. Change the -n dev as necessary):

```
╰─ kubectl get pod -n dev
NAME                           READY   STATUS    RESTARTS   AGE
hello-world-69dd8c495f-86q6m   1/1     Running   0          7m14s
```
- Run the next command, but change the hello-world-69dd8c495f-86q6m to match your pod name: `kubectl port-forward hello-world-69dd8c495f-86q6m 8080:8080 -n dev`
- Again, change the pod name to match yours, and the -n dev to match your namespace. If you didn't specify one when you did the `kubectl apply` then you can leave the '-n dev' off.

You should now be able to navigate to [http://localhost:8080](http://localhost:8080) to see the application in action!


### Helm Install

The below example will deploy the Hello World application and expose it via Ingress, using the `ingress-nginx` controller (included by default in Wayfinder Clusters if enabled).

```
INGRESS_HOSTNAME=
KUBE_NAMESPACE=hello-world

helm -n ${KUBE_NAMESPACE} install hello-world ./charts/hello-world --set ingress.hostname=${INGRESS_HOSTNAME}
```

### Helm Flux Operator

The below example will deploy the Hello World application and expose it via Ingress, using the `ingress-nginx` controller (included by default in Wayfinder Clusters if enabled).

```
cat <<EOF | kubectl -n ${KUBE_NAMESPACE} apply -f -
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: hello-world
spec:
  interval: 1h
  url: https://github.com/rhowells-2020/hello-world
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
