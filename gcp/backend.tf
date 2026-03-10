terraform {
  backend "http" {
    address = "https://gitlab.com/api/v4/projects/79772542/terraform/state/dev-gcp"
    lock_address = "https://gitlab.com/api/v4/projects/79772542/terraform/state/dev-gcp/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/79772542/terraform/state/dev-gcp/lock"
    username = var.gl_user
    password = var.gl_pat
    lock_method = "POST"
    unlock_method = "DELETE"
    retry_wait_min = 5
  }
}
