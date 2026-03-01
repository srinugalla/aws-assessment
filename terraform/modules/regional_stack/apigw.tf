resource "aws_apigatewayv2_api" "http" {
  name          = "assessment-http-api-${var.region}-${random_id.suffix.hex}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id          = aws_apigatewayv2_api.http.id
  authorizer_type = "JWT"
  name            = "cognito-jwt"

  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [var.cognito_user_pool_client_id]
    issuer   = "https://cognito-idp.us-east-1.amazonaws.com/${var.cognito_user_pool_id}"
  }
}

resource "aws_apigatewayv2_integration" "greeter" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.greeter.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "dispatcher" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.dispatcher.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "greet" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "GET /greet"
  target    = "integrations/${aws_apigatewayv2_integration.greeter.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "dispatch" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "POST /dispatch"
  target    = "integrations/${aws_apigatewayv2_integration.dispatcher.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw_greeter" {
  statement_id  = "AllowAPIGatewayInvokeGreeter-${random_id.suffix.hex}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.greeter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_dispatcher" {
  statement_id  = "AllowAPIGatewayInvokeDispatcher-${random_id.suffix.hex}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dispatcher.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}
