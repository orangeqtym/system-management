# This is the main entrypoint for Terraform configurations.
# It's configured to use workspaces for dev and prod.

terraform {
  # Example backend configuration - adjust for your needs
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "system-management/terraform.tfstate"
  #   region = "us-east-1"
  # }

  required_providers {
    # Add required providers here, e.g.,
    # hubitat = {
    #   source = "some-source/hubitat"
    #   version = "x.y.z"
    # }
  }
}

provider "hubitat" {
  # Configuration for the provider, potentially using variables
  # from the active workspace's .tfvars file.
}

# Define your resources here.
# You can use terraform.workspace to create conditional resources
# or to name resources differently based on the environment.
#
# resource "hubitat_device" "example" {
#   name = "my-device-${terraform.workspace}"
# }
