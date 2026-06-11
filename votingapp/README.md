# Add New Charts Into This Repository
This file shows how to test and deploy the votingapp chart.

## Create a new Helm chart
To create a new Helm chart, use the standard Helm command. Make sure Helm is installed.
[Install Helm](https://helm.sh/docs/intro/install/)
```
helm create votingapp
```
## Test Helm Chart
Deploy locally to test that it works as expected.
### Deploy using command line with minimal parameters
```
helm install local-votingapp ./votingapp

```

### Deploy using command line parameters and ingress
```
helm install local-votingapp ./votingapp \
  --set vote.service.type=ClusterIP \
  --set vote.service.port=80 \
  --set vote.replicaCount=2 \
  --set vote.ingress.enabled=true \
  --set result.service.type=ClusterIP \
  --set result.service.port=80 \
  --set result.replicaCount=2 \
  --set result.ingress.enabled=true \
  --set result.ingress.hosts[0].host=votingresult.example.com 

```

### Deploy using a values file
Copy `values.yaml` to `my_values.yaml`. Modify the required values and add any extra annotations if needed.

```
cp values.yaml my_values.yaml

helm install local-votingapp ./votingapp -f my_values.yaml
```

To upgrade
```
helm upgrade local-votingapp ./votingapp
```

To delete
```
helm uninstall local-votingapp
```

## Deploy Helm Chart
There are multiple ways to deploy the chart and pass additional configuration parameters. For example, additional ingress annotations can be provided. [Supported Annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/#annotations)
### From command line

#### Add the Repo to Helm
On any machine, you can now add your repo:
```
helm repo add chartshelf https://ritexlabs.github.io/chart-shelf/
helm repo update

helm repo list
helm search repo chartshelf

$ helm search repo chartshelf
NAME                    CHART VERSION   APP VERSION     DESCRIPTION                                      
chartshelf/votingapp     1.0.0           1.0.0           A Helm chart for deploying votingapp in Kubernetes
$ 
```
### Install Helm Chart
Retrieve the values file and update it accordingly.

#### Install using values file
```
helm inspect values chartshelf/votingapp > votingapp.yaml
```
You can also add an ACM certificate annotation or provide the TLS certificate.
```
vote:
  replicaCount: 1
  image: dockersamples/examplevotingapp_vote
  pullPolicy: IfNotPresent
  containerPort: 80
  service:
    type: NodePort
    port: 80
  ingress:
    enabled: False
    className: alb
    annotations: 
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/healthcheck-path: /
      alb.ingress.kubernetes.io/group.name: frontend    
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
      alb.ingress.kubernetes.io/success-codes: "200,302,307"
    hosts:
      - host: castvote.example.com
        paths:
          - path: /
            pathType: Prefix
    tls: []  

result:
  replicaCount: 1
  image: dockersamples/examplevotingapp_result
  pullPolicy: IfNotPresent
  containerPort: 80
  service:
    type: NodePort
    port: 80
    nodePort: 31002
  ingress:
    enabled: False
    className: alb
    annotations: 
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/healthcheck-path: /
      alb.ingress.kubernetes.io/group.name: frontend    
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
      alb.ingress.kubernetes.io/success-codes: "200,302,307"
    hosts:
      - host: voteresult.example.com
        paths:
          - path: /
            pathType: Prefix
    tls: []    

worker:
  image: dockersamples/examplevotingapp_worker
  pullPolicy: IfNotPresent

redis:
  image: redis:alpine
  pullPolicy: IfNotPresent
  containerPort: 6379
  service:
    type: NodePort
    port: 6379
  
db:
  image: postgres:9.4
  pullPolicy: IfNotPresent
  containerPort: 5432
  postgresUser: postgres
  postgresPassword: postgres
  service:
    type: NodePort
    port: 5432
```
Using this values file lets install the helm chart
```
helm install votingapp chartshelf/votingapp --namespace votingapp --values votingapp.yaml
```

#### Install using command line parameters
```
helm install local-votingapp ./votingapp \
  --set appVersion=v1.0.0 \
  --set service.type=ClusterIP \
  --set service.port=8080 \
  --set replicaCount=2 \
  --set ingress.annotations."alb\\.ingress\\.kubernetes\\.io/load-balancer-name"="votingapp-alb"

```

### Uninstall Chart
```
helm uninstall votingapp --namespace votingapp
helm repo remove chartshelf
```
### Deploy using terraform
Terraform resource to deploy this chart
```
resource "helm_release" "voting_app" {
  name       = "votingapp"
  repository = "https://ritexlabs.github.io/chart-shelf"
  chart      = "votingapp"  

  set {
    name  = "replicaCount:"
    value = "1"
  }

  set {
    name  = "vote.ingress.enabled"
    value = "true"
  }

  set {
    name  = "vote.ingress.hosts[0].host"
    value = "<Your fully qualified domain name>"
  }

  set {
    name  = "result.ingress.enabled"
    value = "true"
  }

  set {
    name  = "result.ingress.hosts[0].host"
    value = "<Your result fully qualified domain name>"
  }

  // Optional - To Enable TLS
  set {
    name  = "vote.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/certificate-arn"
    value = "<Your ACM certificate arn>"
  } 

  set {
    name  = "result.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/certificate-arn"
    value = "<Your ACM certificate arn>"
  }

  // Optional - If your cluster has alb_controller deployed then this will provision ALB"
  set {
    name  = "vote.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/load-balancer-name"
    value = "<Provided ALB name will be used to provision alb>"
  }   

  set {
    name  = "result.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/load-balancer-name"
    value = "<Provided ALB name will be used to provision alb>"
  }

  // Optional - If you already have ALB"
  set {
    name  = "vote.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/group.name"
    value = "<Your group name for ALB>"
  } 

  set {
    name  = "result.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/group.name"
    value = "<Your group name for ALB>"
  }

  // Optional - Restrict Inbound Traffic
  set {
    name  = "vote.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/inbound-cidrs"
    value = "<Comma [,] Seperated cird ranges >"
  }     

  set {
    name  = "result.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/inbound-cidrs"
    value = "<Comma [,] Seperated cird ranges >"
  }
}
```