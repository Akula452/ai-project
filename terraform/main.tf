module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

# Stock action Lambda — fetches real-time prices from Yahoo Finance
# Invoked by the Bedrock Agent as an action group executor
module "stock_lambda" {
  source               = "./modules/lambda"
  project_name         = var.project_name
  function_name_suffix = "stock-action"
  source_dir           = "${path.root}/../lambda/stock_action"
  execution_role_arn   = module.iam.lambda_stock_role_arn
  timeout              = var.lambda_timeout
  memory_size          = var.lambda_memory_size
  log_retention_days   = var.log_retention_days
}

module "bedrock" {
  source                  = "./modules/bedrock"
  project_name            = var.project_name
  bedrock_role_arn        = module.iam.bedrock_role_arn
  bedrock_model_id        = var.bedrock_model_id
  stock_action_lambda_arn = module.stock_lambda.function_arn
  log_retention_days      = var.log_retention_days

  depends_on = [module.stock_lambda]
}

# API handler Lambda — bridges API Gateway to Bedrock Agent Runtime
module "api_lambda" {
  source               = "./modules/lambda"
  project_name         = var.project_name
  function_name_suffix = "api-handler"
  source_dir           = "${path.root}/../lambda/api_handler"
  execution_role_arn   = module.iam.lambda_api_role_arn
  timeout              = var.lambda_timeout
  memory_size          = var.lambda_memory_size
  log_retention_days   = var.log_retention_days

  environment_variables = {
    BEDROCK_AGENT_ID       = module.bedrock.agent_id
    BEDROCK_AGENT_ALIAS_ID = module.bedrock.agent_alias_id
  }

  depends_on = [module.bedrock]
}

module "apigateway" {
  source               = "./modules/apigateway"
  project_name         = var.project_name
  lambda_invoke_arn    = module.api_lambda.invoke_arn
  lambda_function_name = module.api_lambda.function_name
  stage_name           = var.api_stage_name

  depends_on = [module.api_lambda]
}
