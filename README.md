# image-vault-init

Vault sidecar to initialize vault service

- [GCP KMS Unseal tutorial](https://developer.hashicorp.com/vault/tutorials/auto-unseal/autounseal-gcp-kms)

Vault helm chart values

```
server:
  extraContainers:
  - name: vault-init
    image: docker.io/steveszabo/vault-init:6111e19
    env:
    - name: VAULT_ENVIRONMENT
      value: gke-engineering-01
    securityContext:
      runAsNonRoot: true
      runAsUser: 999
      runAsGroup: 999
```