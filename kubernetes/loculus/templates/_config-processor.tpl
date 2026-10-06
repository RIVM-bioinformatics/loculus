{{- define "loculus.configProcessor" -}}
- name: config-processor-{{ .name }}
  image: {{ include "loculus.image" (dict "name" "configProcessor" "defaultRepository" "ghcr.io/loculus-project/config-processor" "values" .values) }}
  imagePullPolicy: {{ include "loculus.imagePullPolicy" (dict "name" "configProcessor" "values" .values) }}
  volumeMounts:
    - name: {{ .name }}
      mountPath: /input
    - name: {{ .name }}-processed
      mountPath: /output
    - name: {{ .name }}-staging
      mountPath: /staging
  # Process into a directory this container creates itself, then copy the contents.
  # shutil.copytree copies the source directory's metadata onto an existing target,
  # which fails on the kubelet-owned /output emptyDir unless the container runs as root.
  command: ["sh", "-c"]
  args:
    - python3 /app/config-processor.py /input /staging/processed && cp -R /staging/processed/. /output/
  resources:
    requests:
      cpu: 50m
      memory: 64Mi
    limits:
      cpu: 500m
      memory: 256Mi
  {{- include "loculus.containerSecurityContext" (list "config-processor" .Values) | nindent 2 }}
  env:
    - name: LOCULUSSUB_smtpPassword
      valueFrom:
        secretKeyRef:
          name: smtp-password
          key: secretKey
    - name: LOCULUSSUB_insdcIngestUserPassword
      valueFrom:
        secretKeyRef:
          name: service-accounts
          key: insdcIngestUserPassword
    - name: LOCULUSSUB_preprocessingPipelinePassword
      valueFrom:
        secretKeyRef:
          name: service-accounts
          key: preprocessingPipelinePassword
    - name: LOCULUSSUB_externalMetadataUpdaterPassword
      valueFrom:
        secretKeyRef:
          name: service-accounts
          key: externalMetadataUpdaterPassword
    - name: LOCULUSSUB_backendUserPassword
      valueFrom:
        secretKeyRef:
          name: service-accounts
          key: backendUserPassword
    - name: LOCULUSSUB_backendKeycloakClientSecret
      valueFrom:
        secretKeyRef:
          name: backend-keycloak-client-secret
          key: backendKeycloakClientSecret
    - name: LOCULUSSUB_orcidSecret
      valueFrom:
        secretKeyRef:
          name: orcid
          key: orcidSecret
{{- end }}


{{- define "loculus.configVolume" -}}
- name: {{ .name }}
  configMap:
    name: {{ if .configmap }}{{ .configmap }}{{ else }}{{ .name }}{{ end }}
- name: {{ .name }}-processed
  emptyDir: {}
- name: {{ .name }}-staging
  emptyDir: {}
{{- end }}

{{- define "loculus.websiteOrganismConfigMapName" -}}
{{- printf "loculus-web-org-config-%s" . | trunc 63 | trimSuffix "-" -}}
{{- end }}
