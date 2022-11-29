resource "aws_kms_key" "cosign" {
  description             = "Cosign Key"
  deletion_window_in_days = 10

  key_usage = "SIGN_VERIFY"
  customer_master_key_spec = "RSA_4096"
}

resource "aws_kms_alias" "cosign" {
  name          = "alias/${var.app_name}"
  target_key_id = aws_kms_key.cosign.key_id
}
