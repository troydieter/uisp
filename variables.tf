variable "aws-profile" {
  description = "AWS profile for provisioning the resources"
  type        = string
}

variable "aws_region" {
  description = "AWS Region- Defaulted to us-east-1"
  default     = "us-east-1"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "application" {
  description = "uisp"
  type        = string
  default     = "uisp"
}

variable "public_internet" {
  description = "Public Internet Space"
  type        = string
}

variable "tld" {
  description = "Top Level Domain"
  type        = string
}

variable "alb_sec_policy" {
  description = "Security Policy for the ALB Listener"
  type        = string
  default     = "ELBSecurityPolicy-FS-1-1-2019-08"
}

variable "instance_type" {
  description = "Instance size"
  type        = string
}