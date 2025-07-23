resource "aws_amplify_app" "frontend_web" {
    name = "frontend-web-app"
    description = "Frontend for the IAM Policy Generator"
    repository = "https://github.com/EdisonLim17/iam-policy-generator"

    access_token = local.github_pat

    build_spec = file("${path.module}/../../../frontend/amplify.yml")
    
    enable_branch_auto_build = true
    enable_branch_auto_deletion = true
}

resource "aws_amplify_branch" "frontend_web_branch" {
    app_id = aws_amplify_app.frontend_web.id
    branch_name = "main"

    lifecycle {
        create_before_destroy = true
    }
}

data "aws_secretsmanager_secret_version" "github_pat" {
    secret_id     = "arn:aws:secretsmanager:us-east-1:415730361496:secret:github/pat/iam-policy-generator-bnr2z9"
}

locals {
    github_pat = jsondecode(nonsensitive(data.aws_secretsmanager_secret_version.github_pat.secret_string)).github_pat
}