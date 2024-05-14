run "allow_only_gmail_com" {

  command = plan

  assert {
    condition     = endswith(var.email, "gmail.com")
    error_message = "Only available domain is gmail.com."
  }

}
