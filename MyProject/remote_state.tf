terraform {
  backend "remote" {
    organization = "MakokTerraformProject"

    workspaces {
      name = "TerraformProject"
    }
  }
}