{{/*
Expand the name of the chart.
*/}}
{{- define "stategraph.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "stategraph.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "stategraph.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "stategraph.labels" -}}
helm.sh/chart: {{ include "stategraph.chart" . }}
{{ include "stategraph.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "stategraph.selectorLabels" -}}
app.kubernetes.io/name: {{ include "stategraph.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Server image reference. An empty tag means the chart's appVersion.
*/}}
{{- define "stategraph.image" -}}
{{- printf "%s:%s" .Values.stategraph.image.repository (default .Chart.AppVersion .Values.stategraph.image.tag) -}}
{{- end -}}

{{/*
Host of the stategraph database: the bundled Service or the external host.
*/}}
{{- define "stategraph.dbHost" -}}
{{- if .Values.postgresql.enabled -}}
{{- include "stategraph.fullname" . }}-postgres
{{- else -}}
{{- .Values.postgresql.host -}}
{{- end -}}
{{- end -}}

{{/*
Get the secret name for database password
*/}}
{{- define "stategraph.secretName" -}}
{{- if .Values.postgresql.auth.existingSecret }}
{{- .Values.postgresql.auth.existingSecret }}
{{- else }}
{{- include "stategraph.fullname" . }}
{{- end }}
{{- end }}

{{/*
Get the secret key for database password
*/}}
{{- define "stategraph.secretKey" -}}
{{- if .Values.postgresql.auth.existingSecret -}}
{{- .Values.postgresql.auth.existingSecretKey -}}
{{- else -}}
db-password
{{- end -}}
{{- end -}}

{{/*
Base of the OAuth callback URLs. Empty means the UI base.
*/}}
{{- define "stategraph.oauthRedirectBase" -}}
{{- default .Values.stategraph.ui.base .Values.stategraph.ui.oauthRedirectBase -}}
{{- end -}}

{{/*
Name of the Secret holding the OAuth credentials. Either one managed outside the
chart -- created by the External Secrets Operator, sealed-secrets, or by hand --
or the chart's own Secret when oauth.existingSecret is unset.
*/}}
{{- define "stategraph.oauth.secretName" -}}
{{- if .Values.stategraph.oauth.existingSecret -}}
{{- .Values.stategraph.oauth.existingSecret -}}
{{- else -}}
{{- include "stategraph.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Keys within the OAuth Secret. The key names are only configurable for an
external Secret; the chart's own Secret always writes the canonical names, so
overriding them there could only produce a dangling reference.
*/}}
{{- define "stategraph.oauth.clientIdKey" -}}
{{- if .Values.stategraph.oauth.existingSecret -}}
{{- default "oauth-client-id" .Values.stategraph.oauth.existingSecretKeys.clientId -}}
{{- else -}}
oauth-client-id
{{- end -}}
{{- end -}}

{{- define "stategraph.oauth.clientSecretKey" -}}
{{- if .Values.stategraph.oauth.existingSecret -}}
{{- default "oauth-client-secret" .Values.stategraph.oauth.existingSecretKeys.clientSecret -}}
{{- else -}}
oauth-client-secret
{{- end -}}
{{- end -}}

{{/*
Cookie-secret key. Empty means "do not wire the env var at all": with an
external Secret the chart cannot generate this value, and referencing a key the
Secret does not carry would leave the pod in CreateContainerConfigError. The
app falls back to a per-process random value, which is only safe at
replicaCount 1.
*/}}
{{- define "stategraph.oauth.cookieSecretKey" -}}
{{- if .Values.stategraph.oauth.existingSecret -}}
{{- .Values.stategraph.oauth.existingSecretKeys.cookieSecret -}}
{{- else -}}
oauth-cookie-secret
{{- end -}}
{{- end -}}

{{/*
Google service-account JSON key, or empty when it should not be wired up.
*/}}
{{- define "stategraph.oauth.googleServiceAccountJsonKey" -}}
{{- if .Values.stategraph.oauth.existingSecret -}}
{{- .Values.stategraph.oauth.existingSecretKeys.googleServiceAccountJson -}}
{{- else if .Values.stategraph.oauth.google.serviceAccountJson -}}
oauth-service-account-json
{{- end -}}
{{- end -}}

{{/*
License key: "true" when a key is supplied inline or through an external Secret.
*/}}
{{- define "stategraph.license.enabled" -}}
{{- if or .Values.stategraph.license.key .Values.stategraph.license.existingSecret -}}
true
{{- end -}}
{{- end -}}

{{- define "stategraph.license.secretName" -}}
{{- if .Values.stategraph.license.existingSecret -}}
{{- .Values.stategraph.license.existingSecret -}}
{{- else -}}
{{- include "stategraph.fullname" . -}}
{{- end -}}
{{- end -}}

{{- define "stategraph.license.secretKey" -}}
{{- if .Values.stategraph.license.existingSecret -}}
{{- default "license-key" .Values.stategraph.license.existingSecretKey -}}
{{- else -}}
license-key
{{- end -}}
{{- end -}}

{{/*
Orchestration public URLs. Empty values derive from the UI base.
*/}}
{{- define "stategraph.orchestration.apiBase" -}}
{{- default (printf "%s/api" .Values.stategraph.ui.base) .Values.stategraph.orchestration.apiBase -}}
{{- end -}}

{{- define "stategraph.orchestration.uiBase" -}}
{{- default .Values.stategraph.ui.base .Values.stategraph.orchestration.uiBase -}}
{{- end -}}

{{- define "stategraph.orchestration.webBaseUrl" -}}
{{- default .Values.stategraph.ui.base .Values.stategraph.orchestration.webBaseUrl -}}
{{- end -}}

{{/*
The Secret holding the two FDW role passwords, and its keys. With an external
Secret an empty provisioner key means that env var is not wired up.
*/}}
{{- define "stategraph.fdw.secretName" -}}
{{- if .Values.stategraph.orchestration.fdw.existingSecret -}}
{{- .Values.stategraph.orchestration.fdw.existingSecret -}}
{{- else -}}
{{- include "stategraph.fullname" . -}}
{{- end -}}
{{- end -}}

{{- define "stategraph.fdw.passwordKey" -}}
{{- if .Values.stategraph.orchestration.fdw.existingSecret -}}
{{- default "fdw-password" .Values.stategraph.orchestration.fdw.existingSecretKeys.password -}}
{{- else -}}
fdw-password
{{- end -}}
{{- end -}}

{{- define "stategraph.fdw.provisionerPasswordKey" -}}
{{- if .Values.stategraph.orchestration.fdw.existingSecret -}}
{{- .Values.stategraph.orchestration.fdw.existingSecretKeys.provisionerPassword -}}
{{- else -}}
fdw-provisioner-password
{{- end -}}
{{- end -}}

{{/*
GitHub App: "true" when credentials are supplied inline or through an external Secret.
*/}}
{{- define "stategraph.github.enabled" -}}
{{- if or .Values.stategraph.orchestration.github.appId .Values.stategraph.orchestration.github.existingSecret -}}
true
{{- end -}}
{{- end -}}

{{- define "stategraph.github.secretName" -}}
{{- if .Values.stategraph.orchestration.github.existingSecret -}}
{{- .Values.stategraph.orchestration.github.existingSecret -}}
{{- else -}}
{{- include "stategraph.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Key of one GitHub credential in that Secret. Takes a dict with "ctx" (the root
context), "name" (the existingSecretKeys field) and "default" (the canonical key).
*/}}
{{- define "stategraph.github.key" -}}
{{- if .ctx.Values.stategraph.orchestration.github.existingSecret -}}
{{- default .default (index .ctx.Values.stategraph.orchestration.github.existingSecretKeys .name) -}}
{{- else -}}
{{- .default -}}
{{- end -}}
{{- end -}}

{{/*
GitLab: "true" when credentials are supplied inline or through an external Secret.
*/}}
{{- define "stategraph.gitlab.enabled" -}}
{{- if or .Values.stategraph.orchestration.gitlab.appId .Values.stategraph.orchestration.gitlab.existingSecret -}}
true
{{- end -}}
{{- end -}}

{{- define "stategraph.gitlab.secretName" -}}
{{- if .Values.stategraph.orchestration.gitlab.existingSecret -}}
{{- .Values.stategraph.orchestration.gitlab.existingSecret -}}
{{- else -}}
{{- include "stategraph.fullname" . -}}
{{- end -}}
{{- end -}}

{{- define "stategraph.gitlab.key" -}}
{{- if .ctx.Values.stategraph.orchestration.gitlab.existingSecret -}}
{{- default .default (index .ctx.Values.stategraph.orchestration.gitlab.existingSecretKeys .name) -}}
{{- else -}}
{{- .default -}}
{{- end -}}
{{- end -}}
