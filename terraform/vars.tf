# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = "eks-gitops-devsec"
}

variable "aws_region" {
  type = string
  default = "us-east-2"
}


variable "app_name" {
  default = "nginx-app"
}

variable "registries" {
  type = list(string)
  description = "(optional) describe your variable"
  default  = ["dev", "homol", "prod", "helm"]
}

variable "token" {
  default = ""
}
