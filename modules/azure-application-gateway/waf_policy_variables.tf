variable "ip_waf_list" {
  description = "List of IP addresses for custom rules"
  type = list(object({
    name = string
    list = list(string)
  }))
  default = []
}

variable "waf_policy_name" {
  description = "Name of the WAF policy"
  type        = string
  default     = "default-waf-policy-name"

  validation {
    condition     = length(var.waf_policy_name) <= 50 && length(var.waf_policy_name) > 0
    error_message = "The WAF policy name must be between 1 and 50 characters long."
  }
}


variable "waf_policy_managed_rule_settings" {
  type = list(
    object(
      {
        rule_group_name   = string
        disabled_rule_ids = list(string)
      }
    )
  )
  default = [
    {
      rule_group_name = "General"
      disabled_rule_ids = [
        "200002",
        "200003",
        "200004"
      ]
    },
    {
      rule_group_name = "REQUEST-911-METHOD-ENFORCEMENT"
      disabled_rule_ids = [
        "911100"
      ]
    },
    {
      rule_group_name = "REQUEST-913-SCANNER-DETECTION"
      disabled_rule_ids = [
        "913100",
        "913101",
        "913102",
        "913110",
        "913120"
      ]
    },
    {
      rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
      disabled_rule_ids = [
        "920100",
        "920120",
        "920121",
        "920160",
        "920170",
        "920171",
        "920180",
        "920190",
        "920200",
        "920201",
        "920202",
        "920210",
        "920220",
        "920230",
        "920240",
        "920250",
        "920260",
        "920270",
        "920271",
        "920272",
        "920273",
        "920274",
        "920280",
        "920290",
        "920300",
        "920310",
        "920311",
        "920320",
        "920330",
        "920340",
        "920341",
        "920350",
        "920420",
        "920430",
        "920440",
        "920450",
        "920460",
        "920470",
        "920480"
      ]
    },
    {
      rule_group_name = "REQUEST-921-PROTOCOL-ATTACK"
      disabled_rule_ids = [
        "921110",
        "921120",
        "921130",
        "921140",
        "921150",
        "921151",
        "921160",
        "921170",
        "921180"
      ]
    },
    {
      rule_group_name = "REQUEST-930-APPLICATION-ATTACK-LFI"
      disabled_rule_ids = [
        "930100",
        "930110",
        "930120",
        "930130"
      ]
    },
    {
      rule_group_name = "REQUEST-931-APPLICATION-ATTACK-RFI"
      disabled_rule_ids = [
        "931100",
        "931110",
        "931120",
        "931130"
      ]
    },
    {
      rule_group_name = "REQUEST-932-APPLICATION-ATTACK-RCE"
      disabled_rule_ids = [
        "932100",
        "932105",
        "932106",
        "932110",
        "932115",
        "932120",
        "932130",
        "932140",
        "932150",
        "932160",
        "932170",
        "932171",
        "932180",
        "932190"
      ]
    },
    {
      rule_group_name = "REQUEST-933-APPLICATION-ATTACK-PHP"
      disabled_rule_ids = [
        "933100",
        "933110",
        "933111",
        "933120",
        "933130",
        "933131",
        "933140",
        "933150",
        "933151",
        "933160",
        "933161",
        "933170",
        "933180",
        "933190",
        "933200",
        "933210"
      ]
    },
    {
      rule_group_name = "REQUEST-941-APPLICATION-ATTACK-XSS"
      disabled_rule_ids = [
        "941100",
        "941101",
        "941110",
        "941120",
        "941130",
        "941140",
        "941150",
        "941160",
        "941170",
        "941180",
        "941190",
        "941200",
        "941210",
        "941220",
        "941230",
        "941240",
        "941250",
        "941260",
        "941270",
        "941280",
        "941290",
        "941300",
        "941310",
        "941320",
        "941330",
        "941340",
        "941350",
        "941360"
      ]
    },
    {
      rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
      disabled_rule_ids = [
        "942100",
        "942110",
        "942120",
        "942130",
        "942140",
        "942150",
        "942160",
        "942170",
        "942180",
        "942190",
        "942200",
        "942210",
        "942220",
        "942230",
        "942240",
        "942250",
        "942251",
        "942260",
        "942270",
        "942280",
        "942290",
        "942300",
        "942310",
        "942320",
        "942330",
        "942340",
        "942350",
        "942360",
        "942361",
        "942370",
        "942380",
        "942390",
        "942400",
        "942410",
        "942420",
        "942421",
        "942430",
        "942431",
        "942432",
        "942440",
        "942450",
        "942460",
        "942470",
        "942480",
        "942490",
        "942500"
      ]
    },
    {
      rule_group_name = "REQUEST-943-APPLICATION-ATTACK-SESSION-FIXATION"
      disabled_rule_ids = [
        "943100",
        "943110",
        "943120"
      ]
    },
    {
      rule_group_name = "REQUEST-944-APPLICATION-ATTACK-JAVA"
      disabled_rule_ids = [
        "944100",
        "944110",
        "944120",
        "944130",
        "944200",
        "944210",
        "944240",
        "944250"
      ]
    },
    {
      rule_group_name = "Known-CVEs"
      disabled_rule_ids = [
        "800100",
        "800110",
        "800111",
        "800112",
        "800113"
  ] }]
}