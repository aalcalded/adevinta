terraform {
    backend "s3" {
        bucket = var.s3bucket
        region = var.region
        encrypt = true
        key = "terraform.tfstate"
        workspace_key_prefix = "workspace"
    }
}