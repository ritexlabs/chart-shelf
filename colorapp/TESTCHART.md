# Add new charts into this repository
This file shows the steps to add new chart into this repository

## Create new helm chart
To create new helm chart create its structure via simple helm command. Make sure you have installed helm. 
[Install Helm](https://helm.sh/docs/intro/install/)
```
helm create colorapp

```

## Test Helm chart
Deploy locally to test if its workign as expected

### Deploy with ingress
```
helm install local-colorapp ./colorapp \
  --set appVersion=v1.0.0 \
  --set service.type=ClusterIP \
  --set service.port=8080 \
  --set replicaCount=2 \
  --set ingress.enabled=true \
  --set hosts.host=colorapp.example.com \
  --set ingress.annotations."alb\\.ingress\\.kubernetes\\.io/load-balancer-name"="colorapp-alb"

```

### Deploy using command values file
Copy values.yaml file as my_values.yaml. Modify all the required values and add additional annotations if needed.
```
cp values.yaml my_values.yaml

helm install local-colorapp ./colorapp -f my_values.yaml
```

To upgrade
```
helm upgrade local-colorapp ./colorapp
```

To delete
```
helm uninstall local-colorapp
```