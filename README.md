# Diplom-kobzev-FSYS-52

Дипломная работа по профессии «Системный администратор» Кобзев И.В

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
<img width="2554" height="1269" alt="image" src="https://github.com/user-attachments/assets/2d08433c-0bcc-4729-bcab-9d190e2ea7e8" />

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
<img width="2550" height="1284" alt="image" src="https://github.com/user-attachments/assets/479ba518-9c75-44a3-adc2-b19358d7bab0" />
<img width="870" height="971" alt="image" src="https://github.com/user-attachments/assets/d8a5a88b-0223-4426-9f6a-cb7a44968672" />



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

5.1 конфигурация балансировщика

```python
cat > alb.tf << 'EOF'
# Target Group (целевая группа)
resource "yandex_alb_target_group" "web" {
  name = "web-target-group"

  target {
    subnet_id = yandex_vpc_subnet.private-a.id
    ip_address = yandex_compute_instance.web-a.network_interface[0].ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.private-b.id
    ip_address = yandex_compute_instance.web-b.network_interface[0].ip_address
  }
}

# Backend Group (группа бэкендов)
resource "yandex_alb_backend_group" "web" {
  name = "web-backend-group"

  http_backend {
    name = "web-backend"
    weight = 1
    port = 80
    target_group_ids = [yandex_alb_target_group.web.id]
    healthcheck {
      timeout = "10s"
      interval = "2s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

# HTTP Router (маршрутизатор)
resource "yandex_alb_http_router" "web" {
  name = "web-router"
}

# Virtual Host (виртуальный хост)
resource "yandex_alb_virtual_host" "web" {
  name = "web-host"
  http_router_id = yandex_alb_http_router.web.id

  route {
    name = "main-route"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
        timeout = "60s"
      }
    }
  }
}

# Load Balancer (балансировщик)
resource "yandex_alb_load_balancer" "web" {
  name = "web-load-balancer"
  network_id = yandex_vpc_network.diploma.id

  allocation_policy {
    location {
      zone_id = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public.id
    }
  }

  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web.id
      }
    }
  }
}

output "lb_ip" {
  value = yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}
EOF
```
<img width="787" height="897" alt="image" src="https://github.com/user-attachments/assets/2d524d7f-dead-4e1a-95b3-0f0228313075" />

Сайт : 

<img width="1151" height="394" alt="image" src="https://github.com/user-attachments/assets/e93c86d1-a0cc-45ea-8012-4fd6c1678cb6" />

### 6 Zabix 

6.1 Создаём ВМ для Zabbix

```python
cd ~/diploma/terraform
nano vms.tf
```

<img width="974" height="676" alt="image" src="https://github.com/user-attachments/assets/b0ebcec0-ccf3-4e00-a4ca-fc16372f7aa3" />


6.2 После добавления конфигурации выполнена команда

```python
terraform apply -auto-approve
```

<img width="974" height="1088" alt="image" src="https://github.com/user-attachments/assets/0b5e9927-2aba-49db-a406-f653febf31f1" />

<img width="2305" height="456" alt="image" src="https://github.com/user-attachments/assets/44bea3e7-7974-49c5-a6eb-3629f961f251" />

6.3 Добавляем Zabbix в Ansible inventory.

```python
cd ~/diploma/ansible
nano inventory
```

<img width="1158" height="618" alt="image" src="https://github.com/user-attachments/assets/86e2d482-c061-4e18-bf1b-bfd66e9a1a33" />


6.4 Почему не удалось установить Zabbix через Ansible плейбук
В ходе выполнения дипломной работы была предпринята попытка автоматизировать установку Zabbix Server с использованием Ansible. Однако в процессе возникли следующие проблемы:
1) В репозитории Zabbix по умолчанию использовался пакет для Ubuntu 24.04, в то время как созданная виртуальная машина работала под управлением Ubuntu 22.04. Это привело к ошибкам при установке:

```python
E: Unable to correct problems, you have held broken packages.
```
Пакеты Zabbix для Ubuntu 24.04 требовали более новые версии системных библиотек:

1) libc6 (>= 2.38) — в Ubuntu 22.04 доступна версия 2.35
2) libssl3t64 (>= 3.0.0) — отсутствует в стандартных репозиториях Ubuntu 22.04

6.5 Устанавливаем через SSH Zabix .

Подключись к ВМ zabbix

```python
ssh ubuntu@89.169.156.132
```

```python
# Удаляем неправильный репозиторий
sudo rm -f /etc/apt/sources.list.d/zabbix*.list
sudo apt update

# Устанавливаем PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Создаём БД и пользователя
sudo -u postgres psql -c "CREATE USER zabbix WITH PASSWORD 'zabbix_pass123';"
sudo -u postgres psql -c "CREATE DATABASE zabbix OWNER zabbix;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE zabbix TO zabbix;"

# Скачиваем и устанавливаем Zabbix 7.0 для Ubuntu 22.04
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_7.0-2+ubuntu22.04_all.deb
sudo apt update

# Устанавливаем Zabbix Server, frontend, agent2, nginx
sudo apt install -y zabbix-server-pgsql zabbix-frontend-php php8.1-pgsql zabbix-agent2 nginx

# Импортируем схему БД
zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix

# Настраиваем Zabbix Server
sudo sed -i 's/# DBPassword=/DBPassword=zabbix_pass123/' /etc/zabbix/zabbix_server.conf
sudo sed -i 's/DBPassword=/DBPassword=zabbix_pass123/' /etc/zabbix/zabbix_server.conf

# Настраиваем nginx для Zabbix (меняем порт на 8080)
sudo sed -i 's/listen 80;/listen 8080;/' /etc/zabbix/nginx.conf

# Запускаем сервисы
sudo systemctl restart zabbix-server zabbix-agent2 nginx php8.1-fpm
sudo systemctl enable zabbix-server zabbix-agent2 nginx php8.1-fpm
```

Проверь, что Zabbix сервер запустился:
```python
sudo systemctl status zabbix-server --no-pager
```

У меня проблемы с забиксом 5.0 - графики не отображались, хотя данные в Latest data были, все переустановил, агенты на хосты тоже переустановил

<img width="884" height="554" alt="image" src="https://github.com/user-attachments/assets/58404855-34a2-4c65-a522-a33de440141b" />

<img width="1084" height="663" alt="image" src="https://github.com/user-attachments/assets/63c4859e-64e4-47f4-b695-27f0fe9cf94f" />

<img width="1026" height="597" alt="image" src="https://github.com/user-attachments/assets/2c53cf1b-bb01-4c12-a350-2373c0f48273" />

<img width="2552" height="1240" alt="image" src="https://github.com/user-attachments/assets/31aa26cf-c2d2-4ddd-85f3-64d0f774dcdf" />

<img width="1181" height="708" alt="image" src="https://github.com/user-attachments/assets/253a6cec-18ed-4e59-a178-446f83fe7569" />

<img width="2366" height="739" alt="image" src="https://github.com/user-attachments/assets/53427bfb-307b-444e-8c7c-789471ea130c" />

<img width="2557" height="1291" alt="image" src="https://github.com/user-attachments/assets/4189387f-8ea9-42fb-96d0-d0071bcc9f14" />

<img width="2539" height="1311" alt="image" src="https://github.com/user-attachments/assets/29db8f7a-1a86-4c11-b5f9-6d8fce0a6e4b" />

<img width="2548" height="1279" alt="image" src="https://github.com/user-attachments/assets/5a63b9b7-0497-4b50-aa57-7d8ca38f6f14" />

<img width="2556" height="1281" alt="image" src="https://github.com/user-attachments/assets/7a0a22dd-57cd-4919-895b-486e022df517" />

### 7.Kibana 

7.1 Создаем ВМ Kibana и Elastic

```python
# Elasticsearch ВМ
resource "yandex_compute_instance" "elasticsearch" {
  name        = "elasticsearch"
  hostname    = "elasticsearch"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd83vkt13re8v8cdapql"
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-a.id
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/kobzev/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

# Kibana ВМ
resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  hostname    = "kibana"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd83vkt13re8v8cdapql"
      size     = 15
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/kobzev/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}
```
<img width="855" height="893" alt="image" src="https://github.com/user-attachments/assets/e0e35559-6402-4e63-b9b1-2ea6858d6bcf" />
<img width="2429" height="584" alt="image" src="https://github.com/user-attachments/assets/079ce82c-3f95-4f24-ba2a-78ebef4ff6c1" />

7.2 Установка Kibana 

```pythom
# Установить Docker
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Запустить Kibana (подключаемся к elasticsearch по внутреннему IP 10.2.0.35)
sudo docker run -d \
  --name kibana \
  --restart always \
  -p 5601:5601 \
  -e "ELASTICSEARCH_HOSTS=http://10.2.0.35:9200" \
  docker.elastic.co/kibana/kibana:7.17.23

# Проверить, что Kibana запустилась
sudo docker ps

# Посмотреть логи (дождаться готовности)
sudo docker logs -f kibana
```
<img width="2550" height="1351" alt="image" src="https://github.com/user-attachments/assets/c1f35a69-c399-40b5-a3f7-0161393b8b8a" />


7.2 Установка Elastic

```Python
# Подключиться к elasticsearch
ssh ubuntu@10.2.0.35

# Установка
sudo apt update
sudo apt install -y wget gnupg curl

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

sudo apt update
sudo apt install -y elasticsearch

# Настройка
sudo tee /etc/elasticsearch/elasticsearch.yml > /dev/null <<EOF
network.host: 0.0.0.0
discovery.type: single-node
xpack.security.enabled: false
EOF

sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch

# Проверка
curl -X GET "localhost:9200"

# Выйти из elasticsearch
exit
```

7.3 Создаём Index Pattern

Устанавливаем Filebeat

```python
# Добавить ключ Elastic
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

# Добавить репозиторий (версия 7.x)
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list

# Обновить и установить
sudo apt update
sudo apt install -y filebeat

# Создать конфиг
sudo mkdir -p /etc/filebeat
sudo tee /etc/filebeat/filebeat.yml > /dev/null <<EOF
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/nginx/access.log
    - /var/log/nginx/error.log
  fields:
    service: nginx
    host: web-a

output.elasticsearch:
  hosts: ["10.2.0.35:9200"]

setup.kibana:
  host: "10.1.0.26:5601"
EOF

# Запустить Filebeat
sudo systemctl start filebeat
sudo systemctl enable filebeat

# Проверить статус
sudo systemctl status filebeat

# Проверить соединение
sudo filebeat test output
```

Выполняем на web-a; web-b; elasticsearch; kibana; zabbix.

```Python
# Установить Docker
sudo apt update
sudo apt install -y docker.io nginx
sudo systemctl start docker nginx
sudo systemctl enable docker nginx

# Создать конфиг Filebeat
sudo mkdir -p /etc/filebeat
sudo tee /etc/filebeat/filebeat.yml > /dev/null <<EOF
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/nginx/access.log
    - /var/log/nginx/error.log
  fields:
    service: nginx
    host: web-b

output.elasticsearch:
  hosts: ["10.2.0.35:9200"]
  protocol: "http"

setup.kibana:
  host: "10.1.0.26:5601"
EOF

# Изменить права на логи
sudo chmod 755 /var/log/nginx
sudo touch /var/log/nginx/access.log /var/log/nginx/error.log
sudo chmod 644 /var/log/nginx/*.log

# Сгенерировать тестовые запросы
curl http://localhost/

# Запустить Filebeat
sudo docker run -d \
  --name filebeat \
  --restart always \
  --user root \
  -v /etc/filebeat/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro \
  -v /var/log/nginx:/var/log/nginx:ro \
  docker.elastic.co/beats/filebeat:7.17.23

# Проверить
sudo docker logs filebeat --tail 20
```

<img width="1236" height="1026" alt="image" src="https://github.com/user-attachments/assets/24c3fb7f-87fe-4aea-8871-baaa765d7a6a" />

7.4 Gроверим индексы в Elasticsearch

```Python 
curl -X GET "http://10.2.0.35:9200/_cat/indices?v"
```
<img width="1070" height="143" alt="image" src="https://github.com/user-attachments/assets/c49d98ec-cb56-4221-94f2-9ea2a59bcfc8" />

7.5 Cоздадим Index Pattern в Kibana
<img width="2553" height="1338" alt="image" src="https://github.com/user-attachments/assets/616fd8e6-e417-41c0-afe5-aa2d05a7963a" />
<img width="2533" height="1277" alt="image" src="https://github.com/user-attachments/assets/14aa3abb-0893-42f4-a6f6-67eb07ee5329" />
<img width="2540" height="1276" alt="image" src="https://github.com/user-attachments/assets/df783057-9a8b-459d-a1c7-86ea4fa920a9" />

7.6 Снапшоты 
7.6.1 Создание 

```Python 
# Создать снапшоты для всех 6 дисков
for disk_id in epdeoobpssu9ba221pov fhm1kv92kdsinot8ieac fhmfqu7eov70jq0mmed1 fhmip9m6ehfd42p1eil6 fhmk6k3dk1pjtukmnghl fhmvf2a22n41lg7a1u5e; do
  echo "Создаю снапшот для диска $disk_id..."
  yc compute snapshot create \
    --name "snapshot-$(date +%Y%m%d-%H%M%S)-${disk_id: -6}" \
    --disk-id "$disk_id" \
    --description "Дипломный проект - снапшот от $(date)"
  sleep 2  # небольшая пауза между созданием снапшотов
done
```
<img width="1359" height="621" alt="image" src="https://github.com/user-attachments/assets/54ed9527-a78e-4274-bc97-d4273548fb10" />

7.6.2 Проверка 

```Python
kobzev@kobzev-server:~/diploma/terraform$ yc compute snapshot list --format yaml | grep -E "name:|status:" | paste - - | column -t
name:  snapshot-20260528-125112-t8ieac  status:  READY
name:  snapshot-20260528-125150-0mmed1  status:  READY
name:  snapshot-20260528-125308-kmnghl  status:  READY
name:  snapshot-20260528-125345-7a1u5e  status:  READY
name:  snapshot-20260528-125227-p1eil6  status:  READY
name:  snapshot-20260528-125026-221pov  status:  READY
kobzev@kobzev-server:~/diploma/terraform$
```
<img width="1315" height="402" alt="image" src="https://github.com/user-attachments/assets/afbdde05-1808-41c8-b1f5-e4045501900d" />

7.6.3 Создадим расписание для автоматических ежедневных снапшотов

```Python
yc compute snapshot-schedule create daily-snapshots \
  --expression "0 0 * * *" \
  --retention-period "168h" \
  --description "Ежедневные снапшоты для дипломного проекта"
```
<img width="823" height="354" alt="image" src="https://github.com/user-attachments/assets/5fd4a74e-9cdf-4759-937c-7da48566c686" />

Добавляем диски 

```Python
yc compute snapshot-schedule add-disks daily-snapshots \
  --disk-id epdeoobpssu9ba221pov \
  --disk-id fhm1kv92kdsinot8ieac \
  --disk-id fhmfqu7eov70jq0mmed1 \
  --disk-id fhmip9m6ehfd42p1eil6 \
  --disk-id fhmk6k3dk1pjtukmnghl \
  --disk-id fhmvf2a22n41lg7a1u5e
```

<img width="971" height="361" alt="image" src="https://github.com/user-attachments/assets/f5e410ff-903c-4114-a402-e0cfe26a361b" />

Отключаем прерываемость у всех ВМ

```Python
# Отключить прерываемость для всех ВМ
for vm in web-a web-b bastion zabbix7 elasticsearch kibana; do
  echo "Отключаю прерываемость для $vm..."
  yc compute instance update --name $vm --preemptible=false
done
```

<img width="1288" height="391" alt="image" src="https://github.com/user-attachments/assets/3131f318-cbe2-464f-8c64-d762954b815a" />

Пошаговое отключение прерываемости

```Python
# Остановить каждую ВМ, изменить параметр, затем запустить
for vm in web-a web-b bastion zabbix7 elasticsearch kibana; do
  echo "=== Обработка $vm ==="
  echo "Останавливаем $vm..."
  yc compute instance stop --name $vm
  
  echo "Отключаем прерываемость для $vm..."
  yc compute instance update --name $vm --preemptible=false
  
  echo "Запускаем $vm..."
  yc compute instance start --name $vm
  echo "=== $vm готово ==="
  echo ""
done
```

<img width="862" height="311" alt="image" src="https://github.com/user-attachments/assets/f8db9da1-8562-448a-8014-538a0d60aab6" />



Снимки дисков

<img width="1816" height="574" alt="image" src="https://github.com/user-attachments/assets/ac4a12db-f38e-49c9-a1c4-49da87836212" />

<img width="1896" height="430" alt="image" src="https://github.com/user-attachments/assets/6a6d85ef-b737-4530-bab5-df0182138fdd" />


1. Zabbix (http://111.88.253.35:8080)
Логин: Admin
Пароль: zabbix

2. Kibana (http://111.88.248.116:5601)
Скриншот Discover с логами (как вы делали ранее)

3. Сайт (http://158.160.130.23)
