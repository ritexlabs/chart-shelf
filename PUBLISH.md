# Publish Helm Charts

This repository publishes packaged Helm charts from the top-level `colorapp/` and `votingapp/` folders.

## Prepare the charts
Each chart folder should contain the standard Helm chart structure:
```
colorapp/
votingapp/
```

## Package the charts
Use the Helm CLI to package each chart:
```
helm package colorapp
helm package votingapp
```
This generates versioned archives such as `colorapp-1.0.0.tgz`.

## Create the repository index
Generate the Helm repository index file:
```
helm repo index . --url https://ritexlabs.github.io/chart-shelf/
```

## Publish manually
```
git add --all
git commit -m "Add packaged charts and index"
git push origin main
```

## GitHub Pages
Set GitHub Pages to publish from the `gh-pages` branch. The published URL is:
https://ritexlabs.github.io/chart-shelf/

