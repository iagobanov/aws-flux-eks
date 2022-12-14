resource "aws_secretsmanager_secret" "events_secrets" {
  name     = "sample-secret"
}

resource "aws_secretsmanager_secret_version" "events_secrets_version" {
  secret_id     = aws_secretsmanager_secret.events_secrets.id
  secret_string = "mysamplesecret"

  depends_on = [
    aws_secretsmanager_secret.events_secrets
  ]
}
