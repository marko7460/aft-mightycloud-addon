variable portfolio_id {
  type = string
  description = "The ID of the portfolio to which to associate the principal."
}

variable "project_id" {
  type = string
}

################################################################################
# GitHub OIDC Role
################################################################################

variable "mightycloud_name" {
  description = "Name of IAM role"
  type        = string
  default     = "mightycloud-oidc-hyperautomation"
}

variable "mightycloud_path" {
  description = "Path of IAM role"
  type        = string
  default     = "/"
}

variable "mightycloud_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = null
}

variable "mightycloud_description" {
  description = "IAM Role description"
  type        = string
  default     = "Role used by hypetautomation"
}

variable "mightycloud_name_prefix" {
  description = "IAM role name prefix"
  type        = string
  default     = null
}

variable "mightycloud_force_detach_policies" {
  description = "Whether policies should be detached from this role when destroying"
  type        = bool
  default     = true
}

variable "mightycloud_max_session_duration" {
  description = "Maximum CLI/API session duration in seconds between 3600 and 43200"
  type        = number
  default     = null
}

variable "mightycloud_organizations" {
  description = "List of mightycloud organizations that are allowed to assume xoofigy hyperautomation role"
  type        = list(string)
  default     = []
}

variable "mightycloud_uids" {
  description = "List of mightycloud user ids that are allowed to assume xoofigy hyperautomation role"
  type        = list(string)
  default     = []
}

variable "mightycloud_architectures" {
  description = "List of mightycloud architectures that are allowed to assume xoofigy hyperautomation role"
  type        = list(string)
  default     = []
}