# image-vault-init
Vault sidecar to initialize vault service

```
server:
  extraContainers:
  - name: vault-init
    image: docker.io/steveszabo/vault-init:6111e19
    env:
    - name: VAULT_ENVIRONMENT
      value: eks-engineering-01
    - name: AWS_DEFAULT_REGION
      value: ca-central-1
    securityContext:
      runAsNonRoot: true
      runAsUser: 999
      runAsGroup: 999
```