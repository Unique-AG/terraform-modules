# Infrastructure as code standard

This standard sets the rules for the Terraform code that defines Unique's AWS estate. That code is the AWS modules in this repository and every layer that calls them, in the landing zone and in the installation blueprint. It builds on two guides and adds Unique's own rules:

- [HashiCorp's Terraform style guide](https://developer.hashicorp.com/terraform/language/style) covers layout, naming and formatting.
- [AWS Prescriptive Guidance: best practices for the Terraform AWS provider](https://web.archive.org/web/20260702045631/https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/introduction.html) covers security, structure and the AWS provider. AWS no longer publishes it at its own address, so the link goes to an archived copy.

Where a rule here differs from a guide, the rule here applies. The [design principles](./DESIGN.md) and the [contribution rules](./CONTRIBUTING.md) apply as well. The standard changes by pull request and is reviewed like the code it governs.

Each rule says how it is checked. The **gate** is the set of required checks a pull request passes before it can merge. **Review** is the approval of a code owner who isn't the author. The gate checks every rule a tool can check, and review covers the rest.

## Rules

### IAC-01 Style and layout

Format with `terraform fmt` and follow the style guide. Put each module in its own directory, with `main.tf`, `variables.tf` and `outputs.tf`, and the `terraform` block in a file of its own. Use snake_case names that don't repeat the resource type.

**Checked by:** the gate (`terraform fmt -check`, TFLint) and review (layout).

### IAC-02 Pinned versions

Every module and layer sets `required_version`, and gives a version constraint for each provider in `required_providers`. A layer commits its `.terraform.lock.hcl`.

A layer calls a module from this repository by its release tag (`?ref=<module>-<version>`). It never calls one by branch, by a commit that isn't a release, or as a copy kept in another repository. A module never declares a `provider` block; its caller passes the providers in.

**Checked by:** the gate (TFLint `terraform_required_version`, `terraform_required_providers`, `terraform_module_pinned_source`) and review.

### IAC-03 Typed and validated inputs

Every variable has a type and a description. Add a `validation` block for every constraint the type can't express, such as:

- a format (an account ID has 12 digits)
- a set of allowed values
- a range
- a rule between fields

An input with no value that is right for every caller is required. Don't give it a placeholder default such as `000000000000`, a default Region or `unspecified`.

Expose a module's behaviour as a validated variable instead of hard-coding it inside the module. Use the name other modules already use for the same value, not a synonym.

**Checked by:** the gate (TFLint `terraform_typed_variables`) and review (validations and defaults).

### IAC-04 No hard-coded accounts or Regions

Account IDs, Regions, organisation, OU and principal IDs, and the ARNs that contain them come from one of three places:

- variables
- data sources such as `aws_caller_identity` and `aws_region`
- values another layer publishes (IAC-08)

A layer sets each of these values once, in its environment's variables.

Some values are fixed by AWS, such as the Region a global service runs in or the account that hosts an AWS-owned registry. Put each one once in a named local, with a comment that says AWS fixes it.

**Checked by:** review.

### IAC-05 Least-privilege IAM in code

Define every IAM role, policy and permission set in code, next to what it grants access to. The same applies to every resource policy and key policy. In each policy:

- Name the actions. Don't use a `*` or `service:*` action, except in a key policy's administration statement.
- Scope resources to ARNs.
- Add the conditions the service supports. A statement for a service principal needs `aws:SourceAccount` or `aws:SourceArn`, so the service can't be used as a confused deputy.

A trust policy names its principals. Don't create IAM users or access keys: people sign in through IAM Identity Center, and pipelines federate through OIDC.

**Checked by:** the gate (the checkov and trivy IAM checks, plus the repository's custom checks, such as one that trust policies name their principals) and review. CODEOWNERS names narrower owners for IAM, resource and key policies.

### IAC-06 Encryption by default

Every resource that stores data is encrypted from creation with a customer managed KMS key for its purpose: data, secrets, logs, metrics or state. Define each key in code, with rotation on and its key policy in code (IAC-05).

Traffic to a resource uses TLS only. Where the service supports a resource policy, add one that denies any request without `aws:SecureTransport`.

A module turns encryption on by default, and either takes the key as an input or creates it. It has no input that turns encryption off.

**Checked by:** the gate (the checkov and trivy encryption checks) and review (the key for each purpose).

### IAC-07 No secrets in code or state

A secret is any value that grants access by itself, such as a password, an API key, a token or a private key. No secret value is written in code, variable files, examples, outputs or state. Handle a secret in one of three ways, in this order of preference:

1. The service that owns the secret generates and stores it, for example with `manage_master_user_password` on `aws_rds_cluster` and `aws_db_instance`.
2. Terraform passes it through a write-only argument, such as `password_wo`, `master_password_wo`, `secret_string_wo` or `value_wo`, each with its `_wo_version`. The value comes from an ephemeral resource, such as `aws_secretsmanager_random_password`, or from an input variable marked `ephemeral = true`. Write-only and ephemeral values never reach the plan or the state; they need Terraform 1.11 or later.
3. The pipeline that owns the secret creates it outside Terraform, and Terraform refers to it by name only.

Each of these stores its value in state, so don't use it for a secret:

- `random_password` or `random_string` as a managed resource
- `tls_private_key`
- `aws_iam_access_key`
- `secret_string` on a secret version

This rule implements Unique's decision record ADR-007, No Secrets in Terraform State.

**Checked by:** the gate (GitHub secret scanning with push protection) and review.

### IAC-08 Interfaces between layers

A layer owns the resources it defines, and no other layer changes them. A later layer reads what an earlier layer created in one of two ways:

- A singular data source looks the object up by exact name or ID, so a missing object fails the plan.
- The earlier layer publishes the value, either as an output copied into the later layer's variables or as an SSM parameter it writes.

A layer doesn't read another layer's state with `terraform_remote_state`, which would need access to that state.

A module returns as outputs every ID, ARN and name its callers need. Callers never take one apart from an ARN.

**Checked by:** review.

### IAC-09 Names and tags

Resource names and the required tags come from the naming module. Set the required tags once, in the provider's `default_tags`, and not again on each resource.

Some resources make up one capability, such as a role, its policies and the stack set that creates it. Take their names from one shared local, so they carry the same stem.

**Checked by:** review.

### IAC-10 Declarative only

Terraform creates and changes AWS resources. CloudFormation creates only two kinds of resource:

- what Terraform needs before it can run, such as a state bucket, or an access role in an account Terraform can't reach yet
- an installation's launch stack

CloudFormation never manages a resource Terraform does. No `local-exec` provisioner or script changes a resource a layer owns; scripts only read or bootstrap.

**Checked by:** review.

### IAC-11 Safe lifecycle

Resources that hold data or identity set `prevent_destroy`. These include accounts, KMS keys, buckets that hold data, log groups and databases.

A rename or move uses a `moved` block, so the plan shows a move instead of a replacement. To adopt an existing resource, use an `import` block, and remove the block once it's applied.

Look objects up by exact name with a singular data source. Never turn a failed lookup into a default value that drives `count` or `for_each`.

**Checked by:** review of the plan posted on the pull request.

### IAC-12 Tests for every module

Every module has `terraform test` files under `tests/`. They run without cloud credentials (`command = plan` with `mock_provider`) and include:

- one test for each validation, with `expect_failures`
- one test for each main path through the module

Every module also has an example under `examples/`, which the gate initialises and validates.

**Checked by:** the gate (`terraform test` and the examples).

### Exceptions

Write a scanner exception at the narrowest scope the scanner supports, in its own syntax, such as `#checkov:skip=<id>:<reason>` or `#trivy:ignore:<id>`. Record it with:

- the rule
- the exact resources
- the reason
- the compensating control
- when to revisit it

A security code owner approves each exception. The same applies to a rule here that a layer can't meet.

## How the rules are checked

### The gate

Every repository that holds this code has one required status check, the gatekeeper. It passes only when every check below passes on the merge result.

| Check | What it shows | Rules |
| --- | --- | --- |
| `terraform fmt -check` | The code is formatted | IAC-01 |
| `terraform validate`, run against each environment's variables for a layer and against each example for a module | The code is valid with every set of inputs it's applied with | IAC-02, IAC-03, IAC-12 |
| TFLint | Variables are typed, versions and module sources are pinned, and nothing declared goes unused | IAC-01, IAC-02, IAC-03 |
| trivy and checkov, with the repository's custom checks | IAM, encryption and other configuration meet the rules | IAC-05, IAC-06 |
| `terraform test` (modules) | Validations and each main path behave as intended | IAC-12 |
| terraform-docs (modules) | Each module's README matches its inputs and outputs | IAC-03 |
| A plan of every affected layer, posted on the pull request (layers) | What applying the change does | IAC-11, in review |

The scanners report to GitHub code scanning, and a new alert at high severity or above blocks the merge. Secret scanning with push protection runs on every repository (IAC-07).

### Review

A code owner who isn't the author approves every change, and approves again after any new push. CODEOWNERS names narrower owners for workflows, identity, and IAM, resource and key policies.

Before approving, the reviewer reads the plan and checks the rules the gate can't check:

- IAC-03: validations and defaults
- IAC-04
- IAC-07: state
- IAC-08 to IAC-11
