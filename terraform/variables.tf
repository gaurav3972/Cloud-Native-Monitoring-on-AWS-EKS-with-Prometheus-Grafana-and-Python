variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "monitoring-cluster"
}

# Path to kubeconfig ON YOUR LOCAL MACHINE after cluster creation.
# You will update this path if different (e.g., Windows path).
variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}

# Worker node sizing
variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_capacity" {
  type    = number
  default = 1
}

variable "max_capacity" {
  type    = number
  default = 3
}
