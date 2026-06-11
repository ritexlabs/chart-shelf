## Deploy Helm Chart
There are multiple ways to deploy the chart and pass additional configuration parameters while deploying. For example, additional ingress annotations can be provided. [Supported Annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/#annotations)

### From command line

#### Add the Repo to Helm
Add the chart-shelf repository to Helm:
```
helm repo add chartshelf https://ritexlabs.github.io/chart-shelf/
helm repo update

helm repo list
helm search repo chartshelf

$ helm search repo chartshelf
NAME                    CHART VERSION   APP VERSION     DESCRIPTION                                      
chartshelf/colorapp     1.0.0           1.0.0           A Helm chart for deploying colorapp in Kubernetes
$ 
```

### Install Helm Chart
Quick deployment with default configuration.
### Method-1: Deploy Helm Chart (Default)
```
kubectl create ns colorapp

helm install colorapp chartshelf/colorapp -n colorapp

```

#### Method-2: Deploy Helm Chart (Advanced)
Retrieve the values file and update it accordingly.
```
helm inspect values chartshelf/colorapp > colorapp.yaml
```
You can also add an ACM certificate annotation or provide a TLS certificate.
```
replicaCount: 1

appenv:
  appcolor: red

image:
  repository: ritexlabs/colorapp
  tag: 1.0.0
  pullPolicy: IfNotPresent

service:
  type: NodePort
  port: 80

ingress:
  enabled: true
  className: alb
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/healthcheck-path: /health
    alb.ingress.kubernetes.io/group.name: frontend
    alb.ingress.kubernetes.io/certificate-arn: <ACM ARN Endpoint>
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
  hosts:
    - host: colorapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls: []
```

Using this values file lets install the helm chart
```
kubectl create ns colorapp

helm install colorapp chartshelf/colorapp --namespace colorapp --values colorapp.yaml
```

#### Method-3: Deploy Helm Chart using command line parameters
```
kubectl create ns colorapp

helm install local-colorapp ./colorapp \
  --set appVersion=v1.0.0 \
  --set service.type=ClusterIP \
  --set service.port=8080 \
  --set replicaCount=2 \
  --set ingress.annotations."alb\\.ingress\\.kubernetes\\.io/load-balancer-name"="colorapp-alb"

```

### Method-4: Deploy Helm Chart using Terraform
Terraform resource to deploy this chart
```
resource "helm_release" "color_app" {
  name       = "colorapp"
  repository = "https://ritexlabs.github.io/chart-shelf"
  chart      = "colorapp"  

  set {
    name  = "replicaCount:"
    value = "1"
  }

  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set {
    name  = "ingress.hosts[0].host"
    value = "<Your fully qualified domain name>"
  }

  // Optional - To Enable TLS
  set {
    name  = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io/certificate-arn"
    value = "<Your ACM certificate arn>"
  } 

  // Optional - If your cluster has alb_controller deployed then this will provision ALB"
  set {
    name  = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io/load-balancer-name"
    value = "<Provided ALB name will be used to provision alb>"
  }   

  // Optional - If you already have ALB"
  set {
    name  = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io/group.name"
    value = "<Your group name for ALB>"
  } 

  // Optional - Restrict Inbound Traffic
  set {
    name  = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io/inbound-cidrs"
    value = "<Comma [,] Seperated cird ranges >"
  }     
}
```

### Uninstall Chart
```
helm uninstall colorapp --namespace colorapp

helm repo remove chartshelf

kubectl delete ns colorapp
```