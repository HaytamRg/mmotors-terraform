data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "dev" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type             = "persistent"
      instance_interruption_behavior = "stop"
    }
  }

  tags = { Name = "mmotors-dev" }
}

data "aws_iam_policy_document" "sched_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "scheduler" {
  name               = "mmotors-dev-scheduler"
  assume_role_policy = data.aws_iam_policy_document.sched_assume.json
}

resource "aws_iam_role_policy" "scheduler" {
  name = "start-stop-ec2"
  role = aws_iam_role.scheduler.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ec2:StartInstances", "ec2:StopInstances"]
      Resource = aws_instance.dev.arn
    }]
  })
}

resource "aws_scheduler_schedule" "start" {
  name                         = "mmotors-dev-start"
  schedule_expression          = "cron(0 8 ? * MON-FRI *)"
  schedule_expression_timezone = "Europe/Paris"
  flexible_time_window { mode = "OFF" }
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.scheduler.arn
    input    = jsonencode({ InstanceIds = [aws_instance.dev.id] })
  }
}

resource "aws_scheduler_schedule" "stop" {
  name                         = "mmotors-dev-stop"
  schedule_expression          = "cron(0 20 ? * MON-FRI *)"
  schedule_expression_timezone = "Europe/Paris"
  flexible_time_window { mode = "OFF" }
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.scheduler.arn
    input    = jsonencode({ InstanceIds = [aws_instance.dev.id] })
  }
}
