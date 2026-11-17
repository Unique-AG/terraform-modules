from __future__ import annotations

import re
from typing import Any

from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.common.util.type_forcers import extract_policy_dict
from checkov.terraform.checks.data.base_check import BaseDataCheck
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

# A bare account ID or any "...:root" ARN, including ones whose account is still a variable.
ACCOUNT_ROOT = re.compile(r"^\d{12}$|:root$")


def as_list(value: Any) -> list[Any]:
    return value if isinstance(value, list) else [value]


def is_assume(actions: Any) -> bool:
    return any(isinstance(a, str) and a.lower().startswith(("sts:assumerole", "sts:*")) for a in as_list(actions))


NAME = "Ensure a role trusting an account root names its principals with aws:PrincipalArn"
ID = "CKV_UQ_AWS_1"


class RoleTrustNamesPrincipals(BaseResourceCheck):
    def __init__(self) -> None:
        super().__init__(name=NAME, id=ID, categories=(CheckCategories.IAM,), supported_resources=("aws_iam_role",))

    def scan_resource_conf(self, conf: dict[str, list[Any]]) -> CheckResult:
        policy = extract_policy_dict(conf.get("assume_role_policy", [None])[0])
        if not policy:
            return CheckResult.UNKNOWN
        for statement in as_list(policy.get("Statement", [])):
            if not isinstance(statement, dict) or statement.get("Effect") == "Deny":
                continue
            principal = statement.get("Principal")
            roots = [p for p in as_list(principal.get("AWS", [])) if isinstance(p, str) and ACCOUNT_ROOT.search(p)] \
                if isinstance(principal, dict) else []
            condition = statement.get("Condition") or {}
            named = any(
                isinstance(block, dict) and any(k.lower() == "aws:principalarn" for k in block)
                for block in condition.values()
            )
            if roots and not named:
                return CheckResult.FAILED
        return CheckResult.PASSED


class PolicyDocumentTrustNamesPrincipals(BaseDataCheck):
    def __init__(self) -> None:
        super().__init__(name=NAME, id=ID, categories=(CheckCategories.IAM,), supported_data=("aws_iam_policy_document",))

    def scan_data_conf(self, conf: dict[str, list[Any]]) -> CheckResult:
        for statement in as_list(conf.get("statement", [])):
            if not isinstance(statement, dict) or as_list(statement.get("effect", ["Allow"]))[0] == "Deny":
                continue
            if not is_assume(sum((as_list(a) for a in statement.get("actions", [])), [])):
                continue
            roots = [
                identifier
                for block in as_list(statement.get("principals", []))
                if isinstance(block, dict) and as_list(block.get("type", [""]))[0] == "AWS"
                for identifier in sum((as_list(i) for i in block.get("identifiers", [])), [])
                if isinstance(identifier, str) and ACCOUNT_ROOT.search(identifier)
            ]
            named = any(
                isinstance(c, dict) and str(as_list(c.get("variable", [""]))[0]).lower() == "aws:principalarn"
                for c in as_list(statement.get("condition", []))
            )
            if roots and not named:
                return CheckResult.FAILED
        return CheckResult.PASSED


check = RoleTrustNamesPrincipals()
data_check = PolicyDocumentTrustNamesPrincipals()
