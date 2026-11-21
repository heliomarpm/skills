# Referência: Kubernetes, Helm e GitOps (`sk-devops`)

Consulte este guia quando a infraestrutura incluir clusters Kubernetes, charts Helm, manifests Kustomize ou pipelines GitOps.

## 1. Endurecimento padrão de workloads (`Deployment` / `StatefulSet`)
- **Menor privilégio obrigatório**: `runAsNonRoot: true`, `allowPrivilegeEscalation: false`, `capabilities.drop: ["ALL"]`, `readOnlyRootFilesystem: true` (monte `emptyDir` apenas onde a app precisa gravar temporários, como `/tmp`).
- **ServiceAccount dedicada**: `automountServiceAccountToken: false` quando o pod não consulta a API do Kubernetes.
- **Recursos e QoS**: defina `requests` de CPU e memória realistas e `limits` de memória (evita OOM inesperado no nó). Em CPU, evite `limits` baixos sem medir *CPU throttling*.
- **Imagens imutáveis**: prefira tags semânticas combinadas com digest (`@sha256:...`); nunca use `:latest`.

## 2. Disponibilidade, probes e drenagem segura
- **Alinhe com `sk-observability`**:
  - `startupProbe`: protege inicializações lentas antes que `livenessProbe` atue.
  - `readinessProbe`: checa se o pod pode receber tráfego (remove do Service sem reiniciar o processo).
  - `livenessProbe`: checa só se o processo está vivo; **nunca** deve depender de banco/API externa para não causar reinício em cascata.
- **Shutdown sem queda de requisição**: configure `terminationGracePeriodSeconds` (ex.: `45`) maior que o dreno do aplicativo, usando `lifecycle.preStop` com pequena pausa (`sleep 5`) antes do encerramento para o Endpoints/Ingress propagar a remoção.
- **Resiliência multi-réplica**: defina `PodDisruptionBudget` (`minAvailable` ou `maxUnavailable: 1`), `topologySpreadConstraints` entre zonas e `HPA` com `behavior.scaleDown.stabilizationWindowSeconds` para evitar *flapping*.

## 3. Rede e segredos
- **NetworkPolicy**: aplique *default-deny* para ingress (e egress quando restrito) no namespace e libere apenas os fluxos explícitos (ex.: Ingress → API → Banco).
- **Segredos**: **nunca** versione `Secret` com valores reais (nem Base64) no Git. Use External Secrets Operator, Sealed Secrets ou injeção por CSI driver (OIDC/Workload Identity).

## 4. Modelo mínimo de referência (`Deployment` + `PDB`)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-pagamentos
  labels:
    app.kubernetes.io/name: api-pagamentos
spec:
  replicas: 2
  revisionHistoryLimit: 3
  selector:
    matchLabels:
      app.kubernetes.io/name: api-pagamentos
  template:
    metadata:
      labels:
        app.kubernetes.io/name: api-pagamentos
    spec:
      automountServiceAccountToken: false
      terminationGracePeriodSeconds: 45
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: app
          image: ghcr.io/org/api-pagamentos:1.4.2@sha256:0000000000000000000000000000000000000000000000000000000000000000
          ports:
            - containerPort: 8080
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: ["ALL"]
          resources:
            requests:
              cpu: "200m"
              memory: "256Mi"
            limits:
              memory: "512Mi"
          startupProbe:
            httpGet: { path: /healthz, port: 8080 }
            failureThreshold: 12
            periodSeconds: 5
          readinessProbe:
            httpGet: { path: /readyz, port: 8080 }
            periodSeconds: 5
            timeoutSeconds: 2
          livenessProbe:
            httpGet: { path: /healthz, port: 8080 }
            periodSeconds: 10
            timeoutSeconds: 2
          lifecycle:
            preStop:
              exec:
                command: ["sh", "-c", "sleep 5"]
          volumeMounts:
            - name: tmp
              mountPath: /tmp
      volumes:
        - name: tmp
          emptyDir:
            sizeLimit: "64Mi"
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: api-pagamentos-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: api-pagamentos
```

## 5. Helm, Kustomize e GitOps
- **Validação estática antes de aplicar**: rode `helm lint`, `helm template ... | trivy config -` (ou `kustomize build` + `kubeconform`).
- **GitOps (ArgoCD / Flux)**: separe repositório/branch de código da configuração de ambiente, use *sync waves* ou *PreSync Hook* para migrações compatíveis (`sk-sql`), mantendo rollback declarativo por reversão de commit.
- **Portão humano obrigatório**: nunca execute `kubectl apply`, `kubectl delete` ou `helm upgrade` em cluster sem pedido ou confirmação explícita.
