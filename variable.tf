variable "domain_name" {
  description = "Your domain name (e.g., mydomain.com)"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy instances"
  type        = string
  default     = "ap-south-1"
}

variable "cloudflare_api_token" {
  description = "API token for Cloudflare"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for the domain"
  type        = string
}

variable "linux_ami_configs" {
  description = "List of Linux AMIs and user data scripts"
  type = list(object({
    name             = string
    ami_id           = string
    user_data_script = string
  }))
  default = [
    { name = "ubuntu22", ami_id = "ami-09b0a86a2c84101e1", user_data_script = "ubuntu.sh" },
    { name = "ubuntu24", ami_id = "ami-053b12d3152c0cc71", user_data_script = "ubuntu.sh" },
    { name = "centos8", ami_id = "ami-001a304f6307735d7", user_data_script = "centos.sh" },
    { name = "centos9", ami_id = "ami-0017796981adef557", user_data_script = "centos.sh" },
    { name = "debian10", ami_id = "ami-005edfef3ce3aa37a", user_data_script = "ubuntu.sh" },
    #{ name = "debian11", ami_id = "ami-00970149b812c5a3e", user_data_script = "ubuntu.sh" },
    { name = "debian12", ami_id = "ami-03c68e52484d7488f", user_data_script = "ubuntu.sh" },
  ]
}

variable "windows_ami_configs" {
  description = "List of Windows AMIs"
  type = list(object({
    name   = string
    ami_id = string
  }))
  default = [
    { name = "windows16", ami_id = "ami-00edc869087cf9077" },
    { name = "windows19", ami_id = "ami-0a63b322ce5ba80c9" },
    { name = "windows22", ami_id = "ami-070198ebf4affc3e7" },
    { name = "windows25", ami_id = "ami-03235cc8fe4d9bf1e" },
  ]
}

variable "instance_type" {
  description = "Instance type for Linux servers"
  type        = string
  default     = "t3.micro"
}

variable "windows_instance_type" {
  description = "Instance type for Windows servers"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "AWS Key Pair name"
  type        = string
}

variable "security_group" {
  description = "Security group for instances"
  type        = string
}
