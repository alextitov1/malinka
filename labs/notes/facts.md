ansible.builtin.setup - module automatically gathers facts

```yaml
- name: Fact dump
  hosts: all
  tasks:
    - name: Print all facts
      ansible.builtin.debug:
        var: ansible_facts
```
ansible_facts['default_ipv4']['address'] = ansible_facts.default_ipv4.address
```yaml
---
- hosts: all
  tasks:
  - name: Prints various Ansible facts
    ansible.builtin.debug:
      msg: >
        The default IPv4 address of {{ ansible_facts.fqdn }}
        is {{ ansible_facts.default_ipv4.address }}
```
Custom facts (ansible_facts['ansible_local'])

/etc/ansible/facts.d/file.fact

Content of File.fact:
```ini
[packages]
web_package = httpd
db_package = mariadb-server
[users]
user1 = joe
user2 = jane
```

disable fact gathering for a play
```yaml
---
- name: This play does not automatically gather any facts
  hosts: large_datacenter
  gather_facts: no
```
Manually gather facts
```yaml
  tasks:
    - name: Manually gather facts
      ansible.builtin.setup:
```

Collect a subset
```yaml
- name: Collect only hardware facts
  ansible.builtin.setup:
    gather_subset:
      - hardware
```
```yaml
- name: Collect all facts except for hardware facts
  ansible.builtin.setup:
    gather_subset:
      - !hardware
```