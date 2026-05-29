terraform {
  required_version = ">= 0.13"
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.130.0"
    }
  }
}

provider "yandex" {
  service_account_key_file = "/home/kobzev/key.json"
  cloud_id                 = "b1g73e8859memevohmp6"
  folder_id                = "b1gcvraf0lu2e23skc09"
  zone                     = "ru-central1-a"
}

variable "ssh_public_key" {
  description = "SSH public key path"
  type        = string
  default     = "/home/kobzev/.ssh/id_rsa.pub"
}
