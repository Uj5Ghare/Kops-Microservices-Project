{{/*
Expand the name of the chart.
*/}}
{{- define "mongo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mongo.fullname" -}}
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
{{- define "mongo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mongo.labels" -}}
helm.sh/chart: {{ include "mongo.chart" . }}
{{ include "mongo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.defaults.labels }}
app: {{ .Values.defaults.labels }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mongo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mongo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Values.defaults.labels }}
app: {{ .Values.defaults.labels }}
{{- end }}
{{- end }}

{{/*
Annotations
*/}}
{{- define "mongo.annotations" -}}
{{- if .Values.defaults.annotations }}
{{- range $key, $value := .Values.defaults.annotations }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- if .Values.defaults.managedBy }}
app.kubernetes.io/managed-by: {{ .Values.defaults.managedBy }}
{{- end }}
{{- end }}
