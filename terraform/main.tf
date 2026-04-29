terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.2-rc01"
    }
  }
  backend "pg" {
    conn_str = "postgres://192.168.40.112/terraform"
  }
}

variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type = string
}

variable "proxmox_vm_template" {
  type = string
}

variable "master_prefix"{
  type = string
}

variable "node_prefix"{
  type = string
}

variable "master_ip_prefix"{
  type = string
  default = "1"
}

variable "node_ip_prefix"{
  type = string
  default = "2"
}

variable "ssh_user" {
  type = string
  default = "debian"
}

variable "ssh_password" {
  type = string
  default = "debian"
}

variable "network_bridge" {
  type = string
}

variable "node_subnet" {
  type = string
}

variable "vlan_tag" {
  type = string
}

variable "network_gateway" {
  type = string
  default = "192.168.80.1"
}

variable "dns_server" {
  type = string
  default = "192.168.80.1"
}

variable "master-count" {
  default = 1
}

variable "node-count" {
  default = 1
}

variable "ssh_key" {
  type =  string
}

provider "proxmox" {
  pm_tls_insecure     = true
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_log_enable = true
  pm_log_file = "terraform-plugin-proxmox.log"
  pm_debug = true
  pm_log_levels = {
    _default = "debug"
    _capturelog = ""
  }
}
