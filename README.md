# hello-world

A simple hello-world web application running with a non-root user on Alpine Linux in a Docker container.

**If you simply want to deploy this to a kubernetes cluster, simply gain access to a cluster and skip down to the ['Using a Kubernetes Deployment'](https://github.com/appvia/hello-world#using-a-kubernetes-deployment) section below.**

## Build

```
docker build -t hello-world .
```

## Run

```
docker run -it -p 8080:8080 --rm --name hello-world ghcr.io/appvia/hello-world/hello-world:main
```

Visit http://localhost:8080 in a web browser.

## Deploy to Kubernetes

### Using a Kubernetes Deployment
- Copy the following yaml to a file called deployment.yaml
```
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

```
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
