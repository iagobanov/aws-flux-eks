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
  default  = ["dev", "homol", "prod", "helm", "security"]
}

variable "github_owner" {
  default = "iagobanov"
}

variable "repository_name" {
  default = "aws-flux-eks"
}

variable "branch" {
  default = "main"
}

variable "target_path" {
  default = "apps/"
}
