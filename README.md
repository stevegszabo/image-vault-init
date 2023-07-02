# image-vault-init
Vault sidecar to initialize vault service

- [AWS KMS Unseal](https://developer.hashicorp.com/vault/docs/configuration/seal/awskms)
- [AWS KMS Unseal tutorial](https://developer.hashicorp.com/vault/tutorials/auto-unseal/autounseal-aws-kms)
- [AWS KMS Unseal vendor sample](https://github.com/hashicorp/vault-guides/tree/master/operations/aws-kms-unseal/terraform-aws)

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