

~/.ansible.cfg

/etc/ansible/ansible.cfg

```ini
[defaults]
inventory = ./inventory
remote_user = someuser
ask_pass = false
[privilege_escalation]
become = true
become_method = sudo
become_user = root
become_ask_pass = false
```
