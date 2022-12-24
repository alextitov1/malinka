```sh
ansible-vault create secret.yml
ansible-vault create --vault-password-file=vault-pass secret.yml
ansible-vault view secret1.yml
ansible-vault edit secret.yml
ansible-vault encrypt secret1.yml secret2.yml
ansible-vault decrypt secret1.yml --output=secret1-decrypted.yml
ansible-vault rekey secret.yml
ansible-navigator run -m stdout --playbook-artifact-enable false create_users.yml --vault-id @prompt
ansible-navigator run -m stdout create_users.yml --vault-password-file=vault-pass
```