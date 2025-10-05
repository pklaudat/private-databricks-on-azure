
variable "resource_prefix" {
  description = "A prefix for naming resources."
  type        = string
  default     = "databricks"
}

variable "location" {
  description = "The Azure region to deploy resources in."
  type        = string
  default     = "Central US"

}