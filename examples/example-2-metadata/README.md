# Metadata example

By default this example uses OS Login and contains no authorized public key. To exercise module-generated SSH cloud-config in a disposable run, pass a public key through an environment variable rather than committing it:

```shell
export TF_VAR_ssh_public_key="$(ssh-keygen -y -f ~/.ssh/id_ed25519)"
```

Set `TF_VAR_user_data` to test authoritative raw cloud-init; it intentionally replaces generated SSH and agent commands.
