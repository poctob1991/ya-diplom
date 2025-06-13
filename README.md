=====
В данном репозитории находится инструменты IaC:
**terraform - разворачивает инфраструктуру в Yandex Cloud.**
Для разворачиания инфраструктцры необходимо перейти в дирректорию terraform и выполнить следующие команды
terraform init
terraform plan
terraform apply
Для удаления инфраструктцры выполнить команду
terrafrom destroy

├── key.json
├── main.tf
├── providers.tf
├── templates
│   └── inventory.tpl
├── terraform.tfstate
├── terraform.tfstate.backup
└── variables.tf
  main.tf -основной файл, в котором описывается, какие ресурсы вы хотите создать и как они должны быть настроены. Используем сервисный аккаунт.
  variables.tf - файл, который содержит объявления переменных, используемых в конфигурации Terraform
  providers.tf - файл, в котором вы указываете, какие облачные провайдеры и другие сервисы Terraform будет использовать для создания инфраструктуры
 удалить только один сервер
 terraform destroy -target=yandex_compute_instance._instance_
создать только один сервер
 terraform apply -target=yandex_compute_instance._instance_

**ansible помогает автоматизировать настройку удалённых серверов в сети и управление ими**
для настройки удаленных серверов перейти в дирректорию ansible и выполнить команды
!!! В roles/base_setup/tasks/ шаг по восстановлению базы данных, необходимо заменить my_wiki.dump на актуальную 
ansible-playbook playbook.yml
├── ansible.cfg
├── group_vars
│   └── all.yml
├── inventory.yml
├── my_wiki.dump
├── playbook.yml
├── README.md
└── roles
    ├── base_setup
    │   └── tasks
    │       ├── main.yml
    │       └── main.yml.bak
    ├── mediawiki
    │   ├── tasks
    │   │   └── main.yml
    │   └── templates
    │       ├── LocalSettings.php.j2
    │       ├── LocalSettings.php.j2.bak
    │       └── mediawiki.conf.j2
    ├── nginx
    │   ├── tasks
    │   │   └── main.yml
    │   └── templates
    │       └── load-balancer.conf.j2
    ├── postgresql
    │   ├── files
    │   │   └── postgres_failover.sh
    │   ├── tasks
    │   │   └── main.yml
    │   └── templates
    │       ├── keepalived.conf.j2
    │       └── recovery.conf.j2
    └── zabbix
        ├── tasks
        │   └── main.yml
        └── templates
            ├── zabbix_agentd.conf.j2
            └── zabbix_server.conf.j2
ansible.cfg - конфигурационный файл, который содержит настройки Ansible, определяющие его поведение
group_vars - определяет переменные, которые применяются ко всем хостам, принадлежащим определенной группе
inventory.yml - файл, который содержит список серверов (или других хостов), которые вы хотите управлять с помощью Ansible
playbook.yml - файл, где описывается, какие задачи нужно выполнить на удаленных машинах, чтобы они были в нужном состоянии
roles - сценарии по установке и настроке хостов
my_wiki.dump - dump базы данных mediawiki
если нужно выполнить настройки для определенного хоста
ansible-playbook  --limit _host_ playbook.yml
