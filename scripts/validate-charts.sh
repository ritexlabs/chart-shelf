#!/usr/bin/env bash

set -euo pipefail

if [[ $# -gt 0 ]]; then
  charts=("$@")
else
  charts=(colorapp votingapp)
fi

for chart_dir in "${charts[@]}"; do
  if [[ ! -f "${chart_dir}/Chart.yaml" ]]; then
    echo "Missing chart directory or Chart.yaml: ${chart_dir}" >&2
    exit 1
  fi

  chart_name=$(awk -F': *' '/^name:/ {print $2; exit}' "${chart_dir}/Chart.yaml")
  chart_version=$(awk -F': *' '/^version:/ {print $2; exit}' "${chart_dir}/Chart.yaml")

  if [[ -z "${chart_name}" || -z "${chart_version}" ]]; then
    echo "Missing name or version in ${chart_dir}/Chart.yaml" >&2
    exit 1
  fi

  if [[ "${chart_name}" != "${chart_dir}" ]]; then
    echo "Chart name ${chart_name} does not match folder name ${chart_dir}" >&2
    exit 1
  fi

  helm lint "${chart_dir}" --strict
  helm template "${chart_name}" "${chart_dir}" >/dev/null

  tmpdir=$(mktemp -d)
  helm package "${chart_dir}" --destination "${tmpdir}" >/dev/null

  if [[ ! -f "${tmpdir}/${chart_name}-${chart_version}.tgz" ]]; then
    echo "Expected package ${chart_name}-${chart_version}.tgz was not created" >&2
    exit 1
  fi
done

echo "All charts validated successfully."