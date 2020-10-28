provider "aws" {
}

resource "random_id" "id" {
  byte_length = 8
}

data "archive_file" "lambda_zip_inline" {
  type        = "zip"
  output_path = "/tmp/lambda_zip_inline.zip"
  source {
    content  = <<EOF
module.exports.handler = async (event, context) => {
	const what = "world";
	const response = `Hello $${what}!`;
	return response;
};
EOF
    filename = "main.js"
  }
}

resource "aws_lambda_function" "lambda_zip_inline" {
  function_name = "${random_id.id.hex}-zip_inline"

  filename         = data.archive_file.lambda_zip_inline.output_path
  source_code_hash = data.archive_file.lambda_zip_inline.output_base64sha256

  handler = "main.handler"
  runtime = "nodejs12.x"
  role    = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "loggroup_inline" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_zip_inline.function_name}"
  retention_in_days = 14
}

output "lambda_zip_inline" {
  value = aws_lambda_function.lambda_zip_inline.arn
}

data "archive_file" "lambda_zip_file_int" {
  type        = "zip"
  output_path = "/tmp/lambda_zip_file_int.zip"
  source {
    content  = file("src/main.js")
    filename = "main.js"
  }
}

resource "aws_lambda_function" "lambda_file_int" {
  function_name = "${random_id.id.hex}-file_int"

  filename         = data.archive_file.lambda_zip_file_int.output_path
  source_code_hash = data.archive_file.lambda_zip_file_int.output_base64sha256

  handler = "main.handler"
  runtime = "nodejs12.x"
  role    = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "loggroup_file_int" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_file_int.function_name}"
  retention_in_days = 14
}

output "lambda_file_int" {
  value = aws_lambda_function.lambda_file_int.arn
}

data "archive_file" "lambda_zip_dir" {
  type        = "zip"
  output_path = "/tmp/lambda_zip_dir.zip"
  source_dir  = "src"
}

resource "aws_lambda_function" "lambda_zip_dir" {
  function_name = "${random_id.id.hex}-zip_dir"

  filename         = data.archive_file.lambda_zip_dir.output_path
  source_code_hash = data.archive_file.lambda_zip_dir.output_base64sha256

  handler = "main.handler"
  runtime = "nodejs12.x"
  role    = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "loggroup_zip_dir" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_zip_dir.function_name}"
  retention_in_days = 14
}

output "lambda_zip_dir" {
  value = aws_lambda_function.lambda_zip_dir.arn
}

resource "aws_s3_bucket" "bucket" {
  force_destroy = true
}

resource "aws_s3_bucket_object" "lambda_code" {
  key    = "${random_id.id.hex}-object"
  bucket = aws_s3_bucket.bucket.id
  source = data.archive_file.lambda_zip_dir.output_path
  etag   = data.archive_file.lambda_zip_dir.output_base64sha256
}

resource "aws_lambda_function" "lambda_s3" {
  function_name = "${random_id.id.hex}-s3"

  s3_bucket = aws_s3_bucket.bucket.id
  s3_key    = aws_s3_bucket_object.lambda_code.id

  source_code_hash = data.archive_file.lambda_zip_dir.output_base64sha256

  handler = "main.handler"
  runtime = "nodejs12.x"
  role    = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "loggroup_s3" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_s3.function_name}"
  retention_in_days = 14
}

output "lambda_s3" {
  value = aws_lambda_function.lambda_s3.arn
}

data "aws_iam_policy_document" "lambda_exec_role_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_iam_role_policy" "lambda_exec_role" {
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_exec_role_policy.json
}

resource "aws_iam_role" "lambda_exec" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}
