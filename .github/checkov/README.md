# Custom checkov checks

`scripts/aws-checks.sh` runs these checks on every AWS module, beside checkov's own.
The landing zone runs the same checks, under the same IDs, on its layers.

| ID | Check | Standard |
| --- | --- | --- |
| `CKV_UQ_AWS_1` | A role that trusts an account root names its principals with `aws:PrincipalArn`; replaces `CKV_AWS_61` | IAC-05 |
| `CKV_UQ_AWS_2` | A resource share sets `allow_external_principals` to false | IAC-05 |
| `CKV2_UQ_AWS_3` | Every ECR repository has a lifecycle policy | IAC-11 |
| `CKV_UQ_AWS_4` | An ElastiCache replication group uses its own subnet group, not the default | IAC-06 |

Every resource in `tests/pass` passes every check, and each check fails at least one resource in `tests/fail`. Add a resource to each when you add or change a check.
