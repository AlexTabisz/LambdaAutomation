resource "aws_lambda_function" "my_lambda" {
    filename = data.archive_file.lambda_python_zip.output_path
    source_code_hash = data.archive_file.lambda_python_zip.output_base64sha256
    function_name = "EricLambda"
    role = aws_iam_role.iam_for_lambda.arn
    handler = "lambda_function.lambda_handler"
    runtime = "python3.9"
}


resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name        = "my-daily-rule"
  description = "Trigger Lambda function daily at 9 AM EST, Monday to Friday"
  schedule_expression = "cron(0 9 ? * 1-5 *)"  
}
#0 represents min
#9 represents 9am
#* every day, every month,
#1-5 where monday is 1 and friday 5

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "EventBridgeInvokeLambda" 
  action        = "lambda:InvokeFunction" #granting permission to invoke lambda
  function_name = aws_lambda_function.my_lambda.arn #retrive arn of lambda defined elsewhere in terraform
  principal     = "events.amazonaws.com" #ensures eventbridge service is granted permision to invoke the lambda function
}

#event targeting lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "LambdaFunctionTarget"
  arn       = aws_lambda_function.my_lambda.arn
}

#iam role for lambda
resource "aws_iam_role" "iam_for_lambda" {
    name = "iam_for_lambda"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "iam_lambda_logs" {
  name = "lambda_logs"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:*:*:*",
          "Effect" : "Allow"
        }
      ]
  })
}


#policy for lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_lambda_logs.arn
}

#uploading lambda function to terraform using a zip file
data "archive_file" "lambda_python_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  output_path = "${path.module}/lambda.zip"
}