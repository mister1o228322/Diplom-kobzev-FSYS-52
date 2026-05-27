# Diplom-kobzev-FSYS-52
Diplom-kobzev
### 1) Установка YC CLI
```python
curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
exec bash
yc version
```
<img width="1386" height="246" alt="image" src="https://github.com/user-attachments/assets/f0ad97ce-2b3f-4391-83e0-87a48d5e5d63" />

1.2)  Установка нового cloud-id 
```python
yc config set cloud-id b1g73e8859memevohmp6
```
<img width="593" height="124" alt="image" src="https://github.com/user-attachments/assets/5c573196-3207-4c45-89c0-03454f1c0907" />

1.3) установка folder-id
```python
yc config set folder-id b1gcvraf0lu2e23skc09
yc config list
```
<img width="629" height="153" alt="image" src="https://github.com/user-attachments/assets/c9035121-9bfa-41dd-b8d0-229df644e43e" />

1.4) Создаем сервисный аккаунт 
```python
yc iam service-account create --name diploma-sa
```
<img width="596" height="120" alt="image" src="https://github.com/user-attachments/assets/9076b043-8db0-45e1-a0fb-04fd67c155b5" />

1.5) Назначаем роль editor
```python
yc resource-manager folder add-access-binding --id b1gcvraf0lu2e23skc09 --role editor --subject serviceAccount:aje7r79535effekotoni
```
1.6 сначала получим ID сервисного аккаунта:

```python
yc iam service-account get --name diploma-sa --format json
```
 <img width="708" height="189" alt="image" src="https://github.com/user-attachments/assets/7373c073-a8d9-4754-b554-2c433cac5b3e" />

1.7 назначаем роль

<img width="1699" height="239" alt="image" src="https://github.com/user-attachments/assets/d9d81973-ae9e-486f-97c3-35ac6e4f73d5" />

1.8 создаём авторизованный ключ

```python
yc iam key create --service-account-name diploma-sa --output ~/key.json
```
<img width="835" height="81" alt="image" src="https://github.com/user-attachments/assets/9c233322-b63d-4a99-af81-bbe67c35e3d9" />

### 2) Установка Terraform (были проблемы с установкой) 
2.1

```python
sudo apt update && sudo apt upgrade -y
```

<img width="617" height="161" alt="image" src="https://github.com/user-attachments/assets/381dbc60-ccba-43c0-ad42-f199ee598082" />

2.2 Проблемы с которыми столкрнулся

2.2.1 Проблема: Стандартный репозиторий HashiCorp не работал из-за географических ограничений (ошибка 404).

1) Использовали установку через Snap: sudo snap install terraform --classic

Результат: Установлена версия Terraform v1.15.4

```python
kobzev@kobzev-server:~$ terraform -v
Terraform v1.15.4 on linux_amd64
```
2.2.2 Установка провайдера Yandex Cloud для Terraform

Проблема:

Terraform не мог скачать провайдер yandex-cloud/yandex из официального реестра (registry.terraform.io недоступен)

Ошибка: Invalid provider registry host

Ручная установка провайдера:

Скачали архив terraform-provider-yandex_0.130.0_linux_amd64.zip с GitHub

Распаковали в директорию ~/.terraform.d/plugins/yandex-cloud/yandex/0.130.0/linux_amd64/

Инициализировали Terraform с параметром -plugin-dir

```python
terraform init -plugin-dir=/home/kobzev/.terraform.d/plugins
```

2.2.3 Проблемы с синтаксисом Terraform

Проблема: Ошибка Functions may not be called here при использовании file() внутри блока variable.

```python
metadata = {
  ssh-keys = "ubuntu:${file("/home/kobzev/.ssh/id_rsa.pub")}"
}
```

2.3 Инициализация Terraform

<img width="1167" height="941" alt="image" src="https://github.com/user-attachments/assets/fadeb295-8801-4ea8-b031-9dcba8ac8885" />

2.4 Проверяем план Terraform

```python
cd ~/diploma/terraform
terraform plan
```

<img width="1307" height="949" alt="image" src="https://github.com/user-attachments/assets/6f4b0680-45bb-40d4-b4c5-f39f57ddc5cc" />

2.5 Применяем конфигурацию

```python
terraform apply -auto-approve
```
<img width="908" height="949" alt="image" src="https://github.com/user-attachments/assets/57efe25d-ed4d-4dd6-b179-0e3fe73ec5d3" />

2.6 Проверяем созданные ВМ

```python
# Список всех ВМ
yc compute instance list --format=table

# Получаем IP бастиона
yc compute instance get bastion --format=json | jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address'

# Альтернативно - просто список с IP
yc compute instance list --format=table | grep -E "NAME|bastion|web"
```

<img width="1046" height="291" alt="image" src="https://github.com/user-attachments/assets/1f8194fa-9a35-45c8-b63b-e65fc67bffaf" />

### 3 Бастион

<img width="1150" height="928" alt="image" src="https://github.com/user-attachments/assets/ba49d820-0282-4495-aa09-8a9b9ad4249a" />

3.1 Проверим доступ к веб-серверам

```python
# На бастионе (ты уже внутри) проверяем доступ к web-a
ping -c 2 web-a.ru-central1.internal

# Проверяем web-b
ping -c 2 web-b.ru-central1.internal

# Проверяем DNS резолвинг
getent hosts web-a
getent hosts web-b

# Проверяем что nginx не установлен (пока)
curl -v web-a.ru-central1.internal:80 2>&1 | head -20
```

<img width="947" height="644" alt="image" src="https://github.com/user-attachments/assets/313b23aa-9cac-4595-97aa-b8acc7e0737f" />

### 4nginx 
4.1 устанавливаем nginx на веб-серверы

Создание inventory файла

```python
cat > ~/inventory.ini << EOF
[web]
web-a.ru-central1.internal
web-b.ru-central1.internal

[web:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/.ssh/id_rsa
EOF
```

4.2 Создание Ansible плейбука

```python
cat > ~/nginx-playbook.yml << EOF
---
- name: Install nginx on web servers
  hosts: web
  become: yes
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Install nginx
      apt:
        name: nginx
        state: present

    - name: Start nginx
      service:
        name: nginx
        state: started
        enabled: yes

    - name: Create index.html
      copy:
        content: |
          <html>
          <head><title>Diploma Project</title></head>
          <body>
          <h1>Welcome to {{ ansible_hostname }}!</h1>
          <p>Group: FSYS-52</p>
          <p>Author: Kobzev Ilya</p>
          </body>
          </html>
        dest: /var/www/html/index.html
EOF
```
4.3 Запуск плейбука

```python
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ~/inventory.ini ~/nginx-playbook.yml
```
4.4 Проверка результата

```python
curl web-a.ru-central1.internal
curl web-b.ru-central1.internal
```
<img width="951" height="287" alt="image" src="https://github.com/user-attachments/assets/34a528c5-2442-4aed-b456-e77add56cfcd" />

### 5 Cоздаем Application Load Balancer







