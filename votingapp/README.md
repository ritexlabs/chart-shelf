# votingapp Helm Chart

This chart deploys the sample voting stack with vote, result, worker, redis, and db components.

The container images used by this chart come from the upstream Example Voting App project: https://github.com/dockersamples/example-voting-app.

## Publish Flow
This repository already builds and publishes both top-level charts automatically through `.github/workflows/publish-charts.yaml` whenever `colorapp/` or `votingapp/` changes.

## Quick Install
The chart is designed to work with its checked-in defaults, so you can install it without supplying a custom values file.

```
kubectl create ns votingapp
helm install votingapp ./votingapp -n votingapp
```

By default, the vote and result services are exposed as `NodePort`, so you can access them from the cluster nodes after installation. Run `helm get notes votingapp -n votingapp` for the exact URLs.

## Default Values
The bundled `values.yaml` provides deployable defaults for every component. The database uses demo-friendly trust authentication unless you override it with your own password.

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
    enabled: false
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
  ingress:
    enabled: false
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
  postgresPassword: ""
  postgresHostAuthMethod: trust
  service:
    type: NodePort
    port: 5432
```

## Customization
If you want ingress, copy the default values into your own file and enable the vote/result ingress blocks with your hostnames and annotations.

```
helm show values chartshelf/votingapp > votingapp.yaml
helm install votingapp chartshelf/votingapp -n votingapp -f votingapp.yaml
```

If you prefer password-based database access, set `db.postgresPassword` and clear `db.postgresHostAuthMethod` in your override file.

## Uninstall
```
helm uninstall votingapp -n votingapp
kubectl delete ns votingapp
```
