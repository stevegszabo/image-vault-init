# image-vault-init

Vault sidecar to initialize vault service

- [Unseal concept](https://developer.hashicorp.com/vault/docs/concepts/seal)
- [GCP KMS Unseal](https://developer.hashicorp.com/vault/docs/configuration/seal/gcpckms)
- [GCP KMS Unseal tutorial](https://developer.hashicorp.com/vault/tutorials/auto-unseal/autounseal-gcp-kms)

Vault helm chart values

```
server:
  extraContainers:
  - name: vault-init
    image: docker.io/steveszabo/vault-init:latest
    env:
    - name: VAULT_ADDR
      value: http://127.0.0.1:8200
    securityContext:
      runAsNonRoot: true
      runAsUser: 999
      runAsGroup: 999
```