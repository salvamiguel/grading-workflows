plugin "terraform" {
  enabled = true
  preset  = "recommended"
}
rule "terraform_naming_convention" {
  enabled = true
  variable { format = "snake_case" }
  resource { format = "snake_case" }
}
rule "terraform_documented_variables" { enabled = true }
rule "terraform_typed_variables"      { enabled = true }