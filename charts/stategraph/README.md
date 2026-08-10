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
| `stategraph.cost.enabled` | Enable the cost intelligence service | `false` |
| `stategraph.extraEnv` | Extra environment variables, as a list of Kubernetes `EnvVar` objects; overrides chart-managed settings | `[]` |
| `stategraph.oauth.existingSecret` | Read OAuth credentials from a Secret you manage yourself | `""` |
| `stategraph.oauth.existingSecretKeys.clientId` | Client ID key in that Secret | `oauth-client-id` |
| `stategraph.oauth.existingSecretKeys.clientSecret` | Client secret key in that Secret | `oauth-client-secret` |
| `stategraph.oauth.existingSecretKeys.cookieSecret` | Cookie-secret key in that Secret; unset means the env var is not wired up | `""` |
| `stategraph.oauth.existingSecretKeys.googleServiceAccountJson` | Google service-account JSON key in that Secret; unset means the env var is not wired up | `""` |
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

### Enabling the Cost Service

```bash
helm upgrade stategraph stategraph/stategraph \
  --namespace stategraph \
  --set stategraph.cost.enabled=true
```

### Setting Arbitrary Environment Variables

Anything the chart does not expose as a named value can be passed through
`stategraph.extraEnv`. It is a list of Kubernetes `EnvVar` objects, copied into
the server container's `env` verbatim, so entries take precedence over the
chart's own settings and a value can come from a Secret or ConfigMap the chart
knows nothing about:

```yaml
stategraph:
  extraEnv:
    - name: STATEGRAPH_LOG_LEVEL
      value: "debug"
    - name: STATEGRAPH_SOME_TOKEN
      valueFrom:
        secretKeyRef:
          name: stategraph-external
          key: some-token
```

Literal values also work from the command line:

```bash
helm upgrade stategraph stategraph/stategraph \
  --namespace stategraph \
  --set stategraph.extraEnv[0].name=STATEGRAPH_LOG_LEVEL \
  --set stategraph.extraEnv[0].value=debug
```

The older map form (`STATEGRAPH_LOG_LEVEL: "debug"`) is still accepted, so
values files written for chart versions before 0.1.11 keep working.

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

### Using an Existing Secret for the OAuth Credentials

Setting `stategraph.oauth.clientSecret` in a values file means committing a
secret to git. To avoid that, put the credentials in a Secret you manage
yourself — typically one produced by the External Secrets Operator,
sealed-secrets, or `kubectl create secret` — and point the chart at it with
`stategraph.oauth.existingSecret`. The chart then creates no OAuth Secret of its
own and reads every OAuth credential from yours.

```yaml
stategraph:
  oauth:
    enabled: true
    type: oidc
    existingSecret: stategraph-oauth
    oidc:
      issuerUrl: https://issuer.example.com
```

An `ExternalSecret` that satisfies the default key names:

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: stategraph-oauth
  namespace: stategraph
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: my-store
    kind: SecretStore
  target:
    name: stategraph-oauth
  data:
    - secretKey: oauth-client-id
      remoteRef: {key: stategraph/oauth, property: client_id}
    - secretKey: oauth-client-secret
      remoteRef: {key: stategraph/oauth, property: client_secret}
    - secretKey: oauth-cookie-secret
      remoteRef: {key: stategraph/oauth, property: cookie_secret}
```

If your Secret uses different key names, map them with
`stategraph.oauth.existingSecretKeys`:

```yaml
stategraph:
  oauth:
    existingSecret: stategraph-oauth
    existingSecretKeys:
      clientId: client_id
      clientSecret: client_secret
      cookieSecret: cookie_secret
```

Notes:

- `cookieSecret` and `googleServiceAccountJson` default to empty, and an empty
  key means the chart does not wire that environment variable up at all —
  naming a key your Secret does not carry would leave the pod in
  `CreateContainerConfigError`.
- The chart cannot generate the cookie secret for you here. Provide one (16, 24,
  or 32 bytes) and name its key whenever `stategraph.replicaCount > 1`;
  otherwise the app picks a random value per process and a login whose callback
  lands on another pod fails with `invalid CSRF token`.
- The database password is separate — see
  `postgresql.auth.existingSecret` above. Setting one has no effect on the
  other, so a deployment that keeps everything out of git sets both.

### External PostgreSQL Database (Containers Only)

Set `postgresql.enabled=false` to deploy only the Stategraph application
containers and connect to a database you manage yourself. This skips the
bundled PostgreSQL Deployment, Service, and PersistentVolumeClaim, and points
the app at the host given by `postgresql.host`.

```bash
# Store the database password in a Secret first
kubectl create secret generic stategraph-db \
  --namespace stategraph \
  --from-literal=db-password='your-secure-password'

# Install, referencing that Secret
helm install stategraph stategraph/stategraph \
  --namespace stategraph \
  --create-namespace \
  --set postgresql.enabled=false \
  --set postgresql.host="postgres.external.com" \
  --set postgresql.port=5432 \
  --set postgresql.auth.username="stategraph" \
  --set postgresql.auth.database="stategraph" \
  --set postgresql.auth.existingSecret="stategraph-db" \
  --set postgresql.auth.existingSecretKey="db-password"
```

Notes:

- The external database, user, and database name must already exist and be
  reachable from the cluster at `host:port`.
- The app runs its own schema migrations on first boot, so the database user
  needs schema/DDL privileges.
- You can pass the password inline with
  `--set postgresql.auth.password="your-secure-password"` instead of using a
  Secret. Do not leave it empty when `postgresql.enabled=false` — the chart
  would auto-generate a random password that won't match your external database.

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
