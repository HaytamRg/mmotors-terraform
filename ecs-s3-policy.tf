data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task" {
  name               = "mmotors-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

data "aws_iam_policy_document" "ecs_read_documents" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.documents.arn,
      "${aws_s3_bucket.documents.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "ecs_read_documents" {
  name   = "mmotors-ecs-read-documents"
  policy = data.aws_iam_policy_document.ecs_read_documents.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_documents" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_read_documents.arn
}
