variable "github_pat_token" {
  description = "GitHub OAuth token for accessing private repositories."
  type        = string
  sensitive = true
  default     = null
}