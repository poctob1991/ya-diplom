variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
  default     = "b1ggs1r5hj84n2674aqt"
}

variable "yc_folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
  default     = "b1g6i1nq2m3gi9dr81eh"
}

variable "yc_zone" {
  description = "Yandex Cloud default zone"
  type        = string
  default     = "ru-central1-a"
}

variable "vm_user" {
  description = "Username for VM access"
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
