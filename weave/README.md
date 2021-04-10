https://www.weave.works/docs/net/latest/kubernetes/kube-addon/

weave.yaml is the result of the following command:

```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```
