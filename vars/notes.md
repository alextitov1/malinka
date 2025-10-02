encrypted with double password

```sh
ansible-vault edit vars/secret.yaml

# change vault password
ansible-vault rekey vars/secret.yaml

ansible-vault view vars/secret.yaml
ansible-vault encrypt vars/secret.yaml
ansible-vault decrypt vars/secret.yaml

ansible-vault create vars/secret.yaml
```