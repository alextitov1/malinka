```sh
ansible -i inventory localhost -m setup

ansible-navigator run -m stdout site.yml --syntax-check
```

inventory
```sh
ansible-navigator inventory -m stdout --list

ansible-inventory --list

ansible-inventory --graph all
```

#list all ansible modules
```sh
ansible-doc -l
```