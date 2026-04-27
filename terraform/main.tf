module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "bedrock" {
  source           = "./modules/bedrock"
  project_name     = var.project_name
  bedrock_role_arn = module.iam.bedrock_role_arn
}
