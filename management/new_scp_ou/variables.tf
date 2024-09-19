# SCP targets - i.e. the OUs in our AWS Organization
variable "ou_targets" {
  type = map(any)
  default = {
    "securityOU" = "ou-8ujb-lg3em6ua",
    "testOU" = "ou-8ujb-fxhuqsag"
  }
}

 