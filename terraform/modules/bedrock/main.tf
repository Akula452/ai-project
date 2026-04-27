resource "aws_bedrock_model_invocation_logging_configuration" "this" {
  logging_config {
    embedding_data_delivery_enabled = true
    image_data_delivery_enabled     = true
    text_data_delivery_enabled      = true

    cloudwatch_config {
      log_group_name = aws_cloudwatch_log_group.bedrock_logs.name
      role_arn       = var.bedrock_role_arn
    }
  }
}

resource "aws_cloudwatch_log_group" "bedrock_logs" {
  name              = "/aws/bedrock/${var.project_name}"
  retention_in_days = var.log_retention_days
}

# ---------------------------------------------------------------------------
# Bedrock Agent — orchestrates Claude to answer stock price questions
# ---------------------------------------------------------------------------
resource "aws_bedrockagent_agent" "stock_agent" {
  agent_name              = "${var.project_name}-stock-agent"
  agent_resource_role_arn = var.bedrock_role_arn
  foundation_model        = var.bedrock_model_id
  prepare_agent           = true

  idle_session_ttl_in_seconds = 300

  instruction = <<-EOT
    You are a financial assistant that retrieves real-time stock prices.
    When a user asks for a stock price, always call the get_stock_price function
    with the exact ticker symbol the user provided.
    Report back the price, currency, exchange, and timestamp from the function response.
    If the ticker is invalid or data is unavailable, inform the user clearly and suggest
    they verify the symbol on Yahoo Finance.
  EOT
}

# Action group — wires Claude to the stock action Lambda
resource "aws_bedrockagent_agent_action_group" "stock_price" {
  agent_id          = aws_bedrockagent_agent.stock_agent.agent_id
  agent_version     = "DRAFT"
  action_group_name = "StockPriceActionGroup"
  description       = "Retrieves real-time stock prices from Yahoo Finance"

  action_group_executor {
    lambda = var.stock_action_lambda_arn
  }

  function_schema {
    member_functions {
      functions {
        name        = "get_stock_price"
        description = "Retrieves the real-time stock price for a given ticker symbol from Yahoo Finance"
        parameters {
          map_block_key = "ticker"
          description   = "The stock ticker symbol (e.g. AAPL, MSFT, GOOGL, BTC-USD)"
          type          = "string"
          required      = true
        }
      }
    }
  }

  depends_on = [aws_bedrockagent_agent.stock_agent]
}

# Allow Bedrock Agent service to invoke the stock action Lambda
resource "aws_lambda_permission" "bedrock_invoke_stock" {
  statement_id  = "AllowBedrockAgentInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.stock_action_lambda_arn
  principal     = "bedrock.amazonaws.com"
  source_arn    = aws_bedrockagent_agent.stock_agent.agent_arn
}

# Alias — stable pointer to DRAFT version for invocation
resource "aws_bedrockagent_agent_alias" "live" {
  agent_id         = aws_bedrockagent_agent.stock_agent.agent_id
  agent_alias_name = "live"

  depends_on = [aws_bedrockagent_agent_action_group.stock_price]
}
