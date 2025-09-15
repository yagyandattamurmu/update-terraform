
provider "aws" {
  region              = var.region
  profile             = var.aws_profile
  allowed_account_ids = [var.aws_account]

  //noinspection HCLUnknownBlockType
  default_tags {
    tags = {
      Terraform   = "true"
      Application = "itt"
      Owner       = "Global Applications"
      Contact     = "kishore.bolisetti@bdpint.com"
      Environment = var.env
    }
  }
}