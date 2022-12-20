```yaml
- name: Postfix and Dovecot are running
  ansible.builtin.service:
    name: "{{ item }}"
    state: started
  loop:
    - postfix
    - dovecot
```

```yaml
vars:
  mail_services:
    - postfix
    - dovecot
tasks:
  - name: Postfix and Dovecot are running
    ansible.builtin.service:
      name: "{{ item }}"
      state: started
    loop: "{{ mail_services }}"
```
```yaml
- name: Users exist and are in the correct groups
  user:
    name: "{{ item['name'] }}"
    state: present
    groups: "{{ item['groups'] }}"
  loop:
    - name: jane
      groups: wheel
    - name: joe
      groups: root
```

The register keyword can also capture the output of a task that loops. The following snippet shows the structure of the register variable from a task that loops:
```yaml
---
- name: Loop Register Test
  gather_facts: no
  hosts: localhost
  tasks:
    - name: Looping Echo Task
      ansible.builtin.shell: "echo This is my item: {{ item }}"
      loop:
        - one
        - two
      register: echo_results
- name: Show echo_results variable
      ansible.builtin.debug:
        var: echo_results
```

### Earlier-style Ansible Loops
|Loop keyword|Description|
|--|--|
|with_items|Behaves the same as the loop keyword for simple lists, such as a list of strings or a list of dictionaries. Unlike loop, if lists of lists are provided to with_items, they are flattened into a single-level list. The item loop variable holds the list item used during each iteration.|
|with_file | Requires a list of control node file names. The item loop variable holds the content of a corresponding file from the file list during each iteration
|with_sequence| Requires parameters to generate a list of values based on a numeric sequence. The item loop variable holds the value of one of the generated items in the generated sequence during each iteration.
