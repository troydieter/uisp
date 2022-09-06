# IAM resources for uisp

resource "aws_iam_instance_profile" "uisp" {
  name = "uisp_client-${random_id.rando.hex}_profile"
  role = aws_iam_role.uisp_client.name
}

resource "aws_iam_role" "uisp_client" {
  name = "uisp_client-${random_id.rando.hex}_role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy" "ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm-role-policy-attach" {
  role       = aws_iam_role.uisp_client.name
  policy_arn = data.aws_iam_policy.ssm.arn
}