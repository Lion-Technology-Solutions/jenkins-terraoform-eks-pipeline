variable "cluster_name" {
  description = "Name of the Amazon EKS cluster."
  type        = string
  default     = "jenkins-eks"

  validation {
    condition     = length(var.cluster_name) <= 100 && can(regex("^[A-Za-z0-9][A-Za-z0-9-]*$", var.cluster_name))
    error_message = "cluster_name must start with an alphanumeric character, contain only alphanumerics or hyphens, and be at most 100 characters."
  }
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version. Leave empty to use the current AWS default version."
  type        = string
  default     = ""

  validation {
    condition     = var.kubernetes_version == "" || can(regex("^1\\.[0-9]+$", var.kubernetes_version))
    error_message = "kubernetes_version must be empty or use a value such as 1.34."
  }
}

variable "environment" {
  description = "Environment name used for tagging."
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for the EKS VPC."
  type        = string
  default     = "10.40.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zone_count" {
  description = "Number of us-east-1 availability zones used by the cluster."
  type        = number
  default     = 2

  validation {
    condition     = var.availability_zone_count >= 2 && var.availability_zone_count <= 3
    error_message = "availability_zone_count must be 2 or 3."
  }
}

variable "enable_nat_gateway" {
  description = "Create a NAT gateway so private worker nodes have outbound internet access."
  type        = bool
  default     = true
}

variable "endpoint_public_access_cidrs" {
  description = "IPv4 CIDR blocks allowed to reach the public EKS API endpoint. Restrict this in production."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = length(var.endpoint_public_access_cidrs) > 0 && alltrue([for cidr in var.endpoint_public_access_cidrs : can(cidrnetmask(cidr))])
    error_message = "endpoint_public_access_cidrs must contain valid IPv4 CIDR blocks."
  }
}

variable "node_instance_type" {
  description = "EC2 instance type used by the EKS managed node group."
  type        = string
  default     = "t3.medium"
}

variable "node_capacity_type" {
  description = "Capacity type for the EKS managed node group."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_disk_size" {
  description = "Worker-node root disk size in GiB."
  type        = number
  default     = 30

  validation {
    condition     = var.node_disk_size >= 20
    error_message = "node_disk_size must be at least 20 GiB."
  }
}

variable "node_min_size" {
  description = "Minimum worker-node count."
  type        = number
  default     = 1

  validation {
    condition     = var.node_min_size >= 0
    error_message = "node_min_size cannot be negative."
  }
}

variable "node_desired_size" {
  description = "Desired worker-node count."
  type        = number
  default     = 2

  validation {
    condition     = var.node_desired_size >= 0
    error_message = "node_desired_size cannot be negative."
  }
}

variable "node_max_size" {
  description = "Maximum worker-node count."
  type        = number
  default     = 4

  validation {
    condition     = var.node_max_size >= 1
    error_message = "node_max_size must be at least 1."
  }
}

variable "cloudwatch_log_retention_days" {
  description = "Retention period for EKS control-plane logs."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags applied to AWS resources."
  type        = map(string)
  default     = {}
}
