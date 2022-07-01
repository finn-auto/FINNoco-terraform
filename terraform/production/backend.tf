terraform {
  backend "remote" {
    organization = "finn"

    workspaces {
      name = "nocodb_opensource_workspace"
    }
  }
}