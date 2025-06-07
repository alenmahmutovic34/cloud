variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Ime projekta"
  type        = string
  default     = "grocery-store"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_pair_name" {
  description = "AWS Key Pair name za SSH pristup"
  type        = string
  default     = "my-key-pair"
}

variable "git_repo_url" {
  description = "URL Git repozitorija"
  type        = string
  default     = "https://github.com/alenmahmutovic34/cloud.git"
}
