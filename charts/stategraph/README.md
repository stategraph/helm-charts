# Stategraph Helm Chart

A Helm chart for deploying [Stategraph](https://stategraph.com) - a modern Terraform/OpenTofu state management solution.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for PostgreSQL persistence)

## Installing the Chart

### From GitHub

```bash
helm repo add stategraph https://stategraph.github.io/helm-charts
helm repo update
helm install my-stategraph stategraph/stategraph --namespace stategraph --create-namespace
```

### From Source

```bash
git clone https://github.com/stategraph/helm-charts.git
cd helm-charts
helm install my-stategraph ./charts/stategraph --namespace stategraph --create-namespace
```

## Configuration

The following table lists the configurable parameters of the Stategraph chart and their default values.

### Application Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `stategraph.image.repository` | Stategraph image repository | `ghcr.io/stategraph/stategraph-server` |
| `stategraph.image.tag` | Stategraph image tag | `latest` |
| `stategraph.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `stategraph.replicaCount` | Number of replicas | `1` |
| `stategraph.ui.base` | Public base URL for the UI | `http://localhost:8080` |
| `stategraph.ui.oauthRedirectBase` | OAuth redirect base URL | `http://localhost:8080` |
| `stategraph.port` | Internal application port | `8180` |
| `stategraph.resources.requests.cpu` | CPU request | `100m` |
| `stategraph.resources.requests.memory` | Memory request | `256Mi` |
| `stategraph.resources.limits.cpu` | CPU limit | `2` |
| `stategraph.resources.limits.memory` | Memory limit | `2Gi` |

### PostgreSQL Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `postgresql.enabled` | Enable bundled PostgreSQL | `true` |
| `postgresql.image.repository` | PostgreSQL image repository | `postgres` |
| `postgresql.image.tag` | PostgreSQL image tag | `17-alpine` |
| `postgresql.auth.username` | Database username | `stategraph` |
| `postgresql.auth.password` | Database password (leave empty to auto-generate) | `""` |
| `postgresql.auth.database` | Database name | `stategraph` |
| `postgresql.auth.existingSecret` | Use existing secret for password | `""` |
| `postgresql.auth.existingSecretKey` | Key in existing secret | `db-password` |
| `postgresql.persistence.enabled` | Enable persistence | `true` |
| `postgresql.persistence.size` | PVC size | `10Gi` |
| `postgresql.persistence.storageClass` | Storage class | `""` (default) |
| `postgresql.resources.requests.cpu` | CPU request | `100m` |
| `postgresql.resources.requests.memory` | Memory request | `256Mi` |
| `postgresql.resources.limits.cpu` | CPU limit | `1` |
| `postgresql.resources.limits.memory` | Memory limit | `1Gi` |

### Service Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `service.annotations` | Service annotations | `{}` |

### Ingress Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `nginx` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hosts configuration | See values.yaml |
| `ingress.tls` | Ingress TLS configuration | `[]` |

## Examples

### Basic Installation with Auto-Generated Password

```bash
helm install stategraph stategraph/stategraph \
  --namespace stategraph \
  --create-namespace
```

Retrieve the auto-generated password:

```bash
kubectl get secret stategraph -n stategraph -o jsonpath="{.data.db-password}" | base64 -d
```

### Production Installation with Ingress and TLS

```bash
helm install stategraph stategraph/stategraph \
  --namespace stategraph \
  --create-namespace \
  --set stategraph.ui.base="https://stategraph.example.com" \
  --set stategraph.ui.oauthRedirectBase="https://stategraph.example.com" \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host="stategraph.example.com" \
  --set ingress.hosts[0].paths[0].path="/" \
  --set ingress.hosts[0].paths[0].pathType="Prefix" \
  --set ingress.tls[0].secretName="stategraph-tls" \
  --set ingress.tls[0].hosts[0]="stategraph.example.com" \
  --set ingress.annotations."cert-manager\.io/cluster-issuer"="letsencrypt-prod"
```

### Using Existing Secret for Database Password

```bash
# Create secret first
kubectl create secret generic stategraph-db \
  --from-literal=db-password='your-secure-password' \
  -n stategraph

# Install with existing secret
helm install stategraph stategraph/stategraph \
  --namespace stategraph \
  --create-namespace \
  --set postgresql.auth.existingSecret="stategraph-db"
```

### External PostgreSQL Database

```bash
helm install stategraph stategraph/stategraph \
  --namespace stategraph \
  --create-namespace \
  --set postgresql.enabled=false \
  --set postgresql.host="postgres.external.com" \
  --set postgresql.port=5432 \
  --set postgresql.auth.username="stategraph" \
  --set postgresql.auth.existingSecret="external-db-secret"
```

## Accessing Stategraph

### Local Development (Port Forward)

```bash
kubectl port-forward -n stategraph svc/stategraph 8080:80
```

Then access at: http://localhost:8080

### Production (with Ingress)

Access at your configured domain (e.g., https://stategraph.example.com)

## Security Notes

⚠️ **Important**: Stategraph uses secure cookies which only work over:
- HTTPS (recommended for production)
- localhost over HTTP (development only)

**DO NOT** use custom hostnames over HTTP - authentication will fail!

## Upgrading

```bash
helm repo update
helm upgrade stategraph stategraph/stategraph -n stategraph
```

## Uninstalling

```bash
helm uninstall stategraph -n stategraph
```

To also delete the namespace:

```bash
kubectl delete namespace stategraph
```

## Support

- Documentation: https://stategraph.com/docs
- Issues: https://github.com/stategraph/releases/issues
- Chart Issues: https://github.com/stategraph/helm-charts/issues
