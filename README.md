# terraform-modules
🚀 Packed with reusable, well-documented Terraform modules to streamline your infrastructure as code. Perfect for DevOps pros looking to boost efficiency and maintainability 🌐.

> [!CAUTION]
> This repository is incubating. As part of Uniques goal to accommodate industry-standards, Unique will slowly strive to industry-standardize its delivery process. Unique is welcoming feedback and contributions to help shape the future of this repository and its release and delivery. Log an issue or get in touch with your Unique SPOC.

## Base Usage

```hcl
# select a specific tag
module "module_name" {
  source = "git::https://github.com/unique-ag/terraform-modules.git//modules/azure/module?depth=1&ref=v1.2.0"
}
# where 'module_name' is a model name of your choice and 'module' an actual module of this repository.
```

## Design
Before using any module, you should get familiar with the [design principles](./DESIGN.md) of this repository as well as the _glossary_ in there.

## Examples

Each module contains an `example` folder, wherein you can see how to use the module.

## Security
Head over to the [security policy](./SECURITY.md) to learn more about our security policy!

> [!CAUTION]
> Unique strives to maintain the highest security standards. None the less, these modules might not adhere to your companies security standards. Please review the modules before using them in production. It is strictly advised to check with your internal IT teams if they offer company-internal modules that are compliant with your companies security standards.
