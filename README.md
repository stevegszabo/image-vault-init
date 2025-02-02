# image-vault-init

Vault sidecar to initialize vault service

- [GCP KMS Unseal tutorial](https://developer.hashicorp.com/vault/tutorials/auto-unseal/autounseal-gcp-kms)

Vault helm chart values

```
server:
  extraContainers:
  - name: vault-init
    image: docker.io/steveszabo/vault-init:latest
    env:
    - name: VAULT_ADDR
      value: https://127.0.0.1:8200
    securityContext:
      runAsNonRoot: true
      runAsUser: 999
      runAsGroup: 999
```