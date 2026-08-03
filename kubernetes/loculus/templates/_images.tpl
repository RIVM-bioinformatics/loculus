{{- define "loculus.imageRegistry" -}}
{{- $root := index . 0 -}}
{{- $imageValues := (index . 1) | default dict -}}
{{- if hasKey $imageValues "registry" -}}
{{- $imageValues.registry | default "" | trimSuffix "/" -}}
{{- else -}}
{{- $root.Values.images.registry | default "" | trimSuffix "/" -}}
{{- end -}}
{{- end -}}

{{- define "loculus.image" -}}
{{- $root := index . 0 -}}
{{- $imageValues := index . 1 -}}
{{- $tag := index . 2 -}}
{{- $registry := include "loculus.imageRegistry" (list $root $imageValues) -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry $imageValues.repository $tag -}}
{{- else -}}
{{- printf "%s:%s" $imageValues.repository $tag -}}
{{- end -}}
{{- end -}}

{{- define "loculus.imageFromRepository" -}}
{{- $root := index . 0 -}}
{{- $repository := index . 1 -}}
{{- $tag := index . 2 -}}
{{- $registry := $root.Values.images.registry | default "" | trimSuffix "/" -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- else -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}
{{- end -}}

{{- define "loculus.imagePullPolicy" -}}
{{- $root := index . 0 -}}
{{- $imageValues := (index . 1) | default dict -}}
{{- $imageValues.pullPolicy | default $root.Values.images.pullPolicy -}}
{{- end -}}

{{- define "loculus.imagePullSecrets" -}}
{{- $root := index . 0 -}}
{{- $workload := index . 1 -}}
{{- $workloadOverrides := index $root.Values.images.pullSecretOverrides $workload -}}
{{- $secrets := or (and (ne $workloadOverrides nil) (gt (len $workloadOverrides) 0) $workloadOverrides) $root.Values.images.pullSecrets -}}
{{- if $secrets }}
imagePullSecrets:
{{- toYaml $secrets | nindent 2 }}
{{- end }}
{{- end -}}