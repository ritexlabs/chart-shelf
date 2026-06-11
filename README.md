# chart-shelf
Helm charts for quickly deploying sample applications.

## Charts
- [colorapp](./colorapp/README.md): sample color application with ingress support.
- [votingapp](./votingapp/README.md): sample voting application with vote, result, worker, redis, and db components.

## Add the Repo to Helm
On any machine, add the repository:
```
helm repo add chartshelf https://ritexlabs.github.io/chart-shelf/
helm repo update
helm repo list
helm search repo chartshelf
```

## Remove Repository
```
helm repo remove chartshelf
```

## Publish Flow
GitHub Actions publishes packaged charts from `.github/workflows/publish-charts.yaml` when files change under `colorapp/` or `votingapp/`.