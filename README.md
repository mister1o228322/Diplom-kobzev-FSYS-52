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

### 2) Установка Terraform

