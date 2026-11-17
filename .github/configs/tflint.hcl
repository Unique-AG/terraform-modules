# TFLint for the AWS modules (STANDARD.md IAC-01 to IAC-03): every rule of the
# bundled terraform ruleset, which covers module structure, naming, documented and
# typed variables, and pinned versions.
plugin "terraform" {
  enabled = true
  preset  = "all"
}
