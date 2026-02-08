# Stategraph Helm Charts

Official Helm charts for [Stategraph](https://stategraph.com) - a modern Terraform/OpenTofu state management solution.

## Usage

Add the Stategraph Helm repository:

```bash
helm repo add stategraph https://stategraph.github.io/helm-charts
helm repo update
```

## Available Charts

### [Stategraph](./charts/stategraph)

Deploy Stategraph with bundled PostgreSQL database.

```bash
helm install my-stategraph stategraph/stategraph \
  --namespace stategraph \
  --create-namespace
```

See the [chart README](./charts/stategraph/README.md) for detailed configuration options.

## Development

### Testing Charts Locally

```bash
# Lint the chart
helm lint charts/stategraph

# Template the chart
helm template my-stategraph charts/stategraph

# Install from local directory
helm install my-stategraph ./charts/stategraph \
  --namespace stategraph \
  --create-namespace \
  --dry-run --debug
```

### Chart Releases

Charts are automatically released to GitHub Pages when changes are pushed to the `main` branch under `charts/**`. The GitHub Action uses [chart-releaser](https://github.com/helm/chart-releaser) to:

1. Package the chart
2. Create a GitHub release
3. Update the Helm repository index
4. Publish to GitHub Pages

To release a new version:

1. Update the `version` field in `charts/stategraph/Chart.yaml`
2. Update the `CHANGELOG.md` (if applicable)
3. Commit and push to `main`

The GitHub Action will automatically create a release and update the Helm repository.

## Support

- Documentation: https://stategraph.com/docs
- Issues: https://github.com/stategraph/stategraph/issues
- Chart Issues: https://github.com/stategraph/helm-charts/issues

## License

Apache License 2.0
