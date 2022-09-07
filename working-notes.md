
Using GH & GH Container Registry
useful guide - https://dev.to/asizikov/using-github-container-registry-with-kubernetes-38fb


Via Wayfinder UI

Self Service
Workspace to1
Cluster aks1
DNS record dev.hello.imperialapp.io



(Check NS records created via whois, ie https://who.is/dns/dev.hello.imperialapp.io)

Build app and create docker image as per README.md

Notes

in /charts/hello-world/values.yaml tag is copied and pasted from ghcr.io with correct tag
ie https://github.com/users/rhowells-2020/packages/container/package/hello-world%2Fhello-world

tag is main
sha is sha256:3636fbae28d6a5c452e403a75f8f5aee80d2b3fb78a6c2a899ee279ddb9c0e65


Command line:

az login

wf use workspace to1

wf -w to1 get clusters

wf access cluster aks1

kubectl get namespaces

export KUBE_NAMESPACE=aks1
export INGRESS_HOSTNAME=dev.hello.imperialapp.io

can check you can pull images from GH container repo via commandline (troubleshooting)
<< CR_PAT=ppppppp >>
echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
docker pull ghcr.io/rhowells-2020/hello-world/hello-world:main

plus need to create a secret with personal access token - follow https://dev.to/asizikov/using-github-container-registry-with-kubernetes-38fb

once double base64 encoded use ...
kubectl -n aks1 create -f dockerconfigjson.yaml
kubectl -n aks1 get secret
kubectl -n aks1 delete secret dockerconfigjson-github-com

** FOLLOW README for helm instructions **
can 'hot edit' helm deployment: kubectl edit deployments -n aks1 hello-world


kubectl -n aks1 get pods
kubectl -n aks1 describe pod nnnnn
kubectl -n aks1 logs nnnnn
kubectl -n aks1 delete pod nnnnn

helm -n ${KUBE_NAMESPACE} install hello-world ./charts/hello-world --set ingress.hostname=${INGRESS_HOSTNAME}
helm uninstall -n aks1 hello-world

helm flux operator installed as README.md

.healthy running pods
>> kubectl -n aks1 get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-world-8c46567c9-czskt   1/1     Running   0          73m
hello-world-8c46567c9-mm9g7   1/1     Running   0          83m

**ingress**

ingress controller
nginx


kubectl -n aks1 get ingress

