variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "Key pair name in AWS"
  type        = string
  default     = "devops-demo-key"
}

variable "public_key_path" {
  description = "Path to your local public key file"
  type        = string
  default     = "~/.ssh/devops-demo.pub"
}