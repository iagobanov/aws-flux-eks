module "lambda_function_eval" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "container-scan-results"
  description   = "Container Scan Eval"
  handler       = "index.lambda_handler"
  runtime       = "python3.7"
  timeout       = "60"

  source_path = "../apps/scan-results-eval"


  environment_variables = {
    Critical_Finding_Threshold = "0"
    High_Finding_Threshold	   = "0"
    Low_Finding_Threshold	   = "15"
    Medium_Finding_Threshold   = "10"
  }

  attach_policy_json = true
  policy_json        = <<-EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:us-east-2:${data.aws_caller_identity.current.id}:*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:us-east-2:${data.aws_caller_identity.current.id}:log-group:/aws/lambda/eval-container-scan-results:*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codepipeline:PutApprovalResult",
                "codepipeline:GetPipelineState"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
  EOT

  tags = {
    Name = "container-scan-results"
  }
}


resource "aws_cloudwatch_event_rule" "inspector" {
  name        = "inspector-scan"
  description = "Capture Inspector scan"

  event_pattern = <<EOF
{
  "detail-type": [
    "Inspector2 Scan"
  ],
  "source": [
    "aws.inspector2"
  ]
}
EOF
}

resource "aws_cloudwatch_event_target" "inspector" {
  rule      = aws_cloudwatch_event_rule.inspector.name
  target_id = "SendToLamba"
  arn       = module.lambda_function_eval.lambda_function_arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
    statement_id = "AllowExecutionFromInspector"
    action = "lambda:InvokeFunction"
    function_name = module.lambda_function_eval.lambda_function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.inspector.arn
}
