# Stategraph Helm Chart

A Helm chart for deploying [Stategraph](https://stategraph.com): Terraform/OpenTofu state management (Infrastructure as a Database) and Orchestration (plans and applies from pull requests).

The chart deploys the Enterprise server image, `ghcr.io/stategraph/stategraph-server`, with a bundled or external PostgreSQL. Each chart version pins a server version through `appVersion`; `stategraph.image.tag` overrides it.

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

## First-time setup

Open Stategraph after the install. The first visit shows the setup screen: it asks for the Enterprise license key, then creates the first admin account and signs you in. Local email and password sign-in is the default; see [Authentication](#authentication) for Google or OIDC.

To supply the license key up front, so the setup screen skips that step:

```bash
helm install stategraph stategraph/stategraph \
  --namespace stategraph \
  --create-namespace \
  --set stategraph.license.key="<license-key>"
```

Or keep it out of the values file with a Secret you manage yourself:

```bash
kubectl create secret generic stategraph-license -n stategraph \
  --from-literal=license-key='<license-key>'

helm install stategraph stategraph/stategraph \
  --namespace stategraph \
  --create-namespace \
  --set stategraph.license.existingSecret=stategraph-license
```

## Configuration

The following table lists the configurable parameters of the Stategraph chart and their default values.

### Application Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `stategraph.image.repository` | Stategraph image repository | `ghcr.io/stategraph/stategraph-server` |
| `stategraph.image.tag` | Stategraph image tag; empty means the chart's `appVersion` | `""` |
| `stategraph.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `stategraph.replicaCount` | Number of replicas | `1` |
| `stategraph.ui.base` | Public base URL for the UI (`STATEGRAPH_UI_BASE`) | `http://localhost:8080` |
| `stategraph.ui.oauthRedirectBase` | OAuth callback base URL; empty means `stategraph.ui.base` | `""` |
| `stategraph.port` | Internal application port | `8180` |
| `stategraph.license.key` | Enterprise license key | `""` |
| `stategraph.license.existingSecret` | Read the license key from a Secret you manage yourself | `""` |
| `stategraph.license.existingSecretKey` | Key in that Secret | `license-key` |
| `stategraph.cost.enabled` | Enable cost estimation | `false` |
| `stategraph.cost.databaseName` | Price-book database on the same PostgreSQL server | `cloud_pricing` |
| `stategraph.cost.sslMode` | libpq `sslmode` for the price-book connection | `disable` |
| `stategraph.cost.refreshHours` | Price-book refresh interval; empty means the image default (168), `0` turns it off | `""` |
| `stategraph.security.enabled` | Enable security scanning of states with checkov | `false` |
| `stategraph.orchestration.enabled` | Enable Stategraph Orchestration | `false` |
| `stategraph.orchestration.apiBase` | `TERRAT_API_BASE`; empty means `stategraph.ui.base` plus `/api` | `""` |
| `stategraph.orchestration.uiBase` | `TERRAT_UI_BASE`; empty means `stategraph.ui.base` | `""` |
| `stategraph.orchestration.webBaseUrl` | `TERRAT_WEB_BASE_URL`; empty means `stategraph.ui.base` | `""` |
| `stategraph.orchestration.telemetryLevel` | `TERRAT_TELEMETRY_LEVEL`: `anonymous` or `disabled`; empty means the image default | `""` |
| `stategraph.orchestration.databaseName` | Orchestration database | `terrateam` |
| `stategraph.orchestration.provisionDatabase` | Create the Orchestration database and FDW roles from an init container on the server pod | `true` |
| `stategraph.orchestration.provisionDatabaseResources` | Resources of that init container | see values.yaml |
| `stategraph.orchestration.fdw.user` | Read role of the FDW bridge | `stategraph_mql` |
| `stategraph.orchestration.fdw.provisionerUser` | Write role for GitLab provisioning from the console | `stategraph_provisioner` |
| `stategraph.orchestration.fdw.password` | Password of the read role; empty generates a stable value | `""` |
| `stategraph.orchestration.fdw.provisionerPassword` | Password of the write role; empty generates a stable value | `""` |
| `stategraph.orchestration.fdw.existingSecret` | Read both passwords from a Secret you manage yourself | `""` |
| `stategraph.orchestration.fdw.existingSecretKeys.password` | Read-role password key in that Secret | `fdw-password` |
| `stategraph.orchestration.fdw.existingSecretKeys.provisionerPassword` | Write-role password key; empty means not wired up | `fdw-provisioner-password` |
| `stategraph.orchestration.github.appId` | GitHub App ID; setting it turns GitHub on | `""` |
| `stategraph.orchestration.github.clientId` | GitHub App OAuth client ID | `""` |
| `stategraph.orchestration.github.clientSecret` | GitHub App OAuth client secret | `""` |
| `stategraph.orchestration.github.pem` | GitHub App private key | `""` |
| `stategraph.orchestration.github.webhookSecret` | GitHub App webhook secret | `""` |
| `stategraph.orchestration.github.appUrl` | Install URL of the App, linked from the console | `""` |
| `stategraph.orchestration.github.apiBaseUrl` | GitHub Enterprise Server API base | `""` |
| `stategraph.orchestration.github.webBaseUrl` | GitHub Enterprise Server web base | `""` |
| `stategraph.orchestration.github.existingSecret` | Read the five GitHub credentials from a Secret you manage yourself | `""` |
| `stategraph.orchestration.github.existingSecretKeys.*` | Key names in that Secret | see values.yaml |
| `stategraph.orchestration.gitlab.appId` | GitLab application ID; setting it turns GitLab on | `""` |
| `stategraph.orchestration.gitlab.appSecret` | GitLab application secret | `""` |
| `stategraph.orchestration.gitlab.accessToken` | GitLab access token with the `api` scope | `""` |
| `stategraph.orchestration.gitlab.apiBaseUrl` | Self-managed GitLab root URL | `""` |
| `stategraph.orchestration.gitlab.webBaseUrl` | Self-managed GitLab web URL | `""` |
| `stategraph.orchestration.gitlab.existingSecret` | Read the three GitLab credentials from a Secret you manage yourself | `""` |
| `stategraph.orchestration.gitlab.existingSecretKeys.*` | Key names in that Secret | see values.yaml |
| `stategraph.extraEnv` | Extra environment variables, as a list of Kubernetes `EnvVar` objects; overrides chart-managed settings | `[]` |
| `stategraph.extraVolumes` | Extra volumes for the server pod | `[]` |
| `stategraph.extraVolumeMounts` | Extra volume mounts for the server container | `[]` |
| `stategraph.podLabels` | Additional labels on the server pods | `{}` |
| `stategraph.terminationGracePeriodSeconds` | Time the server gets to finish requests in progress at stop | `60` |
| `stategraph.startupProbe` | Startup probe on `/health/ready`; allows `failureThreshold * periodSeconds` for migrations | see values.yaml |
| `stategraph.livenessProbe` | Liveness probe on `/health/live` | see values.yaml |
| `stategraph.readinessProbe` | Readiness probe on `/health/ready` | see values.yaml |
| `stategraph.db.statementTimeout` | `STATEGRAPH_DB_STATEMENT_TIMEOUT` | `60s` |
| `stategraph.oauth.enabled` | Enable Google or OIDC sign-in | `false` |
| `stategraph.oauth.type` | `google` or `oidc` | `""` |
| `stategraph.oauth.clientId` | OAuth client ID | `""` |
| `stategraph.oauth.clientSecret` | OAuth client secret | `""` |
| `stategraph.oauth.cookieSecret` | Cookie-signing secret (16, 24, or 32 characters); empty generates a stable value | `""` |
| `stategraph.oauth.displayName` | Provider name on the sign-in button | `OAuth Login` |
| `stategraph.oauth.emailDomain` | Email domain allowed to sign in | `*` |
| `stategraph.oauth.existingSecret` | Read OAuth credentials from a Secret you manage yourself | `""` |
| `stategraph.oauth.existingSecretKeys.clientId` | Client ID key in that Secret | `oauth-client-id` |
| `stategraph.oauth.existingSecretKeys.clientSecret` | Client secret key in that Secret | `oauth-client-secret` |
| `stategraph.oauth.existingSecretKeys.cookieSecret` | Cookie-secret key in that Secret; unset means the env var is not wired up | `""` |
| `stategraph.oauth.existingSecretKeys.googleServiceAccountJson` | Google service-account JSON key in that Secret; unset means the env var is not wired up | `""` |
| `stategraph.resources.requests.cpu` | CPU request | `100m` |
| `stategraph.resources.requests.memory` | Memory request | `256Mi` |
| `stategraph.resources.limits.cpu` | CPU limit | `2` |
| `stategraph.resources.limits.memory` | Memory limit | `4Gi` |

### PostgreSQL Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `postgresql.enabled` | Enable bundled PostgreSQL | `true` |
| `postgresql.image.repository` | PostgreSQL image repository; also provides `psql` for the Orchestration init container | `postgres` |
| `postgresql.image.tag` | PostgreSQL image tag | `17-alpine` |
| `postgresql.auth.username` | Database username | `stategraph` |
| `postgresql.auth.password` | Database password (leave empty to auto-generate) | `""` |
| `postgresql.auth.database` | Database name | `stategraph` |
| `postgresql.auth.existingSecret` | Use existing secret for password | `""` |
| `postgresql.auth.existingSecretKey` | Key in existing secret | `db-password` |
| `postgresql.host` | External database host (when `postgresql.enabled=false`) | `postgres` |
| `postgresql.port` | Database port | `5432` |
| `postgresql.persistence.enabled` | Enable persistence | `true` |
| `postgresql.persistence.size` | PVC size | `10Gi` |
| `postgresql.persistence.storageClass` | Storage class | `""` (default) |
| `postgresql.resources.requests.cpu` | CPU request | `100m` |
| `postgresql.resources.requests.memory` | Memory request | `256Mi` |
| `postgresql.resources.limits.cpu` | CPU limit | `8` |
| `postgresql.resources.limits.memory` | Memory limit | `8Gi` |

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
  --set ingress.enabled=true \
  --set ingress.hosts[0].host="stategraph.example.com" \
  --set ingress.hosts[0].paths[0].path="/" \
  --set ingress.hosts[0].paths[0].pathType="Prefix" \
  --set ingress.tls[0].secretName="stategraph-tls" \
  --set ingress.tls[0].hosts[0]="stategraph.example.com" \
  --set ingress.annotations."cert-manager\.io/cluster-issuer"="letsencrypt-prod"
```

`stategraph.ui.oauthRedirectBase` follows `stategraph.ui.base` unless set.

### Enabling Cost Estimation

```bash
helm upgrade stategraph stategraph/stategraph \
  --namespace stategraph \
  --set stategraph.cost.enabled=true
```

The in-image pricing service connects to the same PostgreSQL server, user, and password as the `stategraph` database and creates the `cloud_pricing` database there, so the database user needs `CREATEDB`, or the database must exist. On the first start it downloads the price book in the background, several hundred MB, and refreshes it weekly.

### Enabling Security Scanning

```bash
helm upgrade stategraph stategraph/stategraph \
  --namespace stategraph \
  --set stategraph.security.enabled=true
```

### Enabling Orchestration

Orchestration turns pull requests into plans and applies through a GitHub App or a GitLab connection. It needs a second logical database, `terrateam`, and two roles, `stategraph_mql` and `stategraph_provisioner`, on the same PostgreSQL server. With `stategraph.orchestration.provisionDatabase` on (the default), an init container on the server pod creates them with the `stategraph` database credentials and sets the role passwords from the chart's Secret, before each server start. That works out of the box with the bundled PostgreSQL. On an external server, the connecting role needs `CREATEDB` and `CREATEROLE`, and on managed PostgreSQL such as Amazon RDS it also needs superuser rights (`rds_superuser`) for the `postgres_fdw` bridge.

Create the GitHub App with the setup wizard:

```bash
docker run --rm -p 3000:3000 ghcr.io/stategraph/orchestration-setup:latest
```

Put the credentials it prints into a Secret:

```bash
kubectl create secret generic stategraph-github -n stategraph \
  --from-literal=github-app-id="$GITHUB_APP_ID" \
  --from-literal=github-app-client-id="$GITHUB_APP_CLIENT_ID" \
  --from-literal=github-app-client-secret="$GITHUB_APP_CLIENT_SECRET" \
  --from-literal=github-app-pem="$GITHUB_APP_PEM" \
  --from-literal=github-webhook-secret="$GITHUB_WEBHOOK_SECRET"
```

Then turn Orchestration on:

```bash
helm upgrade stategraph stategraph/stategraph \
  --namespace stategraph \
  --set stategraph.ui.base="https://stategraph.example.com" \
  --set stategraph.orchestration.enabled=true \
  --set stategraph.orchestration.github.existingSecret=stategraph-github \
  --set stategraph.orchestration.github.appUrl="$GITHUB_APP_URL"
```

In the App settings on GitHub, set the webhook URL to `https://stategraph.example.com/api/github/v1/events` and add `https://stategraph.example.com/api/v1/vcs-installations/github/claim/callback` as a callback URL.

For GitLab, the equivalent Secret carries `gitlab-app-id`, `gitlab-app-secret`, and `gitlab-access-token`, named by `stategraph.orchestration.gitlab.existingSecret`. Connect each group from the **Get Started** page of the console; the connect wizard shows the project webhook URL, `https://stategraph.example.com/api/v1/gitlab/events`, and its secret. For self-managed GitLab, also set `stategraph.orchestration.gitlab.apiBaseUrl` and `webBaseUrl`.

The inline values (`github.appId`, `github.pem`, `gitlab.appId`, ...) also work and end up in the chart's Secret, which is convenient for a trial.

Notes:

- The public URLs `TERRAT_API_BASE`, `TERRAT_UI_BASE`, and `TERRAT_WEB_BASE_URL` derive from `stategraph.ui.base`. With the same host as `stategraph.ui.base`, that host serves the Stategraph console only. To serve the Terrateam console as well, give `stategraph.orchestration.uiBase` a host of its own that also routes to this Service.
- With `provisionDatabase` off, create the database and the roles by hand before the first start with Orchestration on, and set `stategraph.orchestration.fdw.password` and `provisionerPassword` (or `fdw.existingSecret`) to the passwords you gave the roles.
- Orchestration does not start when a GitHub App is configured without its webhook secret, and only the container log shows that.
- Telemetry is on by default (`anonymous`). Set `stategraph.orchestration.telemetryLevel=disabled` to turn it off.

### Setting Arbitrary Environment Variables

Anything the chart does not expose as a named value can be passed through
`stategraph.extraEnv`. It is a list of Kubernetes `EnvVar` objects, copied into
the server container's `env` verbatim, so entries take precedence over the
chart's own settings and a value can come from a Secret or ConfigMap the chart
knows nothing about:

```yaml
stategraph:
  extraEnv:
    - name: STATEGRAPH_ACCESS_LOG
      value: "/dev/stdout"
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
  --set stategraph.extraEnv[0].name=STATEGRAPH_ACCESS_LOG \
  --set stategraph.extraEnv[0].value=/dev/stdout
```

The older map form (`STATEGRAPH_ACCESS_LOG: "/dev/stdout"`) is still accepted, so
values files written for chart versions before 0.1.11 keep working.

Leave optional variables unset rather than empty: several Orchestration variables treat an empty string differently from an absent one.

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

### Authentication

Local email and password sign-in is on when `stategraph.oauth.enabled` is off. For Google or OIDC:

```bash
helm install stategraph stategraph/stategraph \
  --namespace stategraph \
  --create-namespace \
  --set stategraph.ui.base="https://stategraph.example.com" \
  --set stategraph.oauth.enabled=true \
  --set stategraph.oauth.type="google" \
  --set stategraph.oauth.clientId="your-client-id" \
  --set stategraph.oauth.clientSecret="your-client-secret" \
  --set stategraph.oauth.emailDomain="example.com"
```

In your provider, register `https://stategraph.example.com/oauth2/google/callback` or `/oauth2/oidc/callback` as the redirect URI. `stategraph.oauth.emailDomain` defaults to `*`, which lets any identity the provider authenticates sign in, and the first user to sign in while no instance admin exists becomes one; restrict it to your domain on any public deployment.

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
- With cost estimation or Orchestration on, the same server also holds the
  `cloud_pricing` and `terrateam` databases; see the sections above for what
  the user needs to create them.

## Health checks

The image answers two endpoints on port 8080. `/health/live` answers `200` as soon as the web server is up, and `/health/ready` answers `200` only after the database migrations ran and the server serves requests; during migrations it answers `502`. The chart's startup probe polls `/health/ready` and allows five minutes by default before the liveness probe on `/health/live` begins. For a large database, raise `stategraph.startupProbe.failureThreshold`.

## Accessing Stategraph

### Local Development (Port Forward)

```bash
kubectl port-forward -n stategraph svc/stategraph 8080:80
```

Then access at: http://localhost:8080

### Production (with Ingress)

Access at your configured domain (e.g., https://stategraph.example.com)

## Security Notes

An `https://` URL in `stategraph.ui.base` sets the `Secure` flag on cookies, and an `http://` URL does not. So `stategraph.ui.base=http://myserver:8080` allows sign-in over plain HTTP, for a port-forward or an internal network. Use HTTPS for anything reachable from outside, and keep `stategraph.ui.base` equal to the URL users open.

## Upgrading

```bash
helm repo update
helm upgrade stategraph stategraph/stategraph -n stategraph
```

Each chart version pins a server version. The server migrates its databases at start; `/health/ready` keeps traffic off a pod until that is done, and replicas that start together migrate safely. At stop the server drains requests in progress within the 60 second `terminationGracePeriodSeconds` the chart sets.

### From 0.1.x

- The image tag now defaults to the chart's `appVersion` instead of `latest`. Set `stategraph.image.tag` to keep another version.
- The probes moved from `/api/v1/health` to `/health/live` and `/health/ready`.
- `stategraph.ui.oauthRedirectBase` defaults to `stategraph.ui.base` instead of `http://localhost:8080`.
- With `stategraph.cost.enabled`, the chart now points the pricing service at the chart's database through `PRICING_DB_*`. Remove any `PRICING_DB_*` entries from `stategraph.extraEnv` that did the same.

## Uninstalling

```bash
helm uninstall stategraph -n stategraph
```

To also delete the namespace:

```bash
kubectl delete namespace stategraph
```

## Support

- Documentation: https://stategraph.com/docs/admin/self-hosting/kubernetes
- Issues: https://github.com/stategraph/releases/issues
- Chart Issues: https://github.com/stategraph/helm-charts/issues
