```yaml
tasks:
  - name: copy demo.example.conf configuration template
ansible.builtin.template:
      src: /var/lib/templates/demo.example.conf.template
      dest: /etc/httpd/conf.d/demo.example.conf
    notify:
		- restart apache
handlers:
- name: restart apache
  ansible.builtin.service:
	name: httpd
state: restarted
```
```yaml
tasks:
  - name: copy demo.example.conf configuration template
    ansible.builtin.template:
      src: /var/lib/templates/demo.example.conf.template
      dest: /etc/httpd/conf.d/demo.example.conf
    notify:
      - restart mysql
      - restart apache
handlers:
  - name: restart mysql
    ansible.builtin.service:
      name: mariadb
      state: restarted
  - name: restart apache
    ansible.builtin.service:
      name: httpd
      state: restarted
```

```yaml
tasks:
    - name: Install {{ web_package }} package
      ansible.builtin.dnf:
        name: "{{ web_package }}"
        state: present
      ignore_errors: yes
```

```yaml
tasks:
- name: Check local time
    ansible.builtin.command: date
    register: command_result
    changed_when: false
```

```yaml
block:
- name: Install {{ web_package }} package
    ansible.builtin.dnf:
    name: "{{ web_package }}"
    state: present
    failed_when: web_package == "httpd"
```

```yaml
asks:
    - name: Attempt to set up a webserver
      block:
        - name: Install {{ web_package }} package
          ansible.builtin.dnf:
            name: "{{ web_package }}"
            state: present
      rescue:
        - name: Install {{ db_package }} package
          ansible.builtin.dnf:
            name: "{{ db_package }}"
            state: present
      always:
        - name: Start {{ db_service }} service
          ansible.builtin.service:
            name: "{{ db_service }}"
            state: started

```