# Design considerations and principles

## Glossary

**_You_**, **_the Consumer_**, are the person or team that consumes the modules provided in this repository.
**_We_**, **_the Provider_**, are the person or team, or Unique AG, that provides the modules in this repository.

## Layers

[Azure](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/), [AWS](https://docs.aws.amazon.com/prescriptive-guidance/latest/strategy-migration/aws-landing-zone.html), [GCP](https://cloud.google.com/architecture/landing-zones) as well as most other cloud or infrastructure providers advise, suggest and encourage to have a clean separation of layers mostly boiling down to three key areas:

### Identity
Identity covers all tenant-wide resources related to user identities, authentication, and access management. This area includes systems like Azure Active Directory (AAD) or AWS IAM, where user accounts, service principals, and roles are defined and managed. Identity management enforces policies around authentication and authorization, with a focus on the principle of least privilege, ensuring that users and services have only the access necessary for their tasks. By centralizing identity in its own area, organizations can apply and audit security policies consistently, which is critical for protecting sensitive information and preventing unauthorized access. A dedicated identity layer strengthens security by maintaining clear, enforceable boundaries around who can access what resources and under what conditions.

### Perimeter
Perimeter represents the boundary layer that governs how internal resources connect and communicate with each other, as well as with external networks. It includes virtual networks (VNets in Azure, VPCs in AWS), DNS configurations, firewalls, role assignments, and custom roles. The perimeter applies network-level policies, enforcing secure communication channels and controlling data flow to and from internal resources. By limiting network access based on the principle of least privilege, the perimeter layer minimizes exposure to attacks by ensuring that only essential traffic is permitted. Defining a strong perimeter helps protect critical resources and enables network segmentation, allowing teams to enforce security policies that restrict connections and block unauthorized access to sensitive data.

### Workloads
Workloads are the core applications and services that drive the organization’s business, including databases, virtual machines, Kubernetes clusters (AKS in Azure), and storage accounts. These resources handle and process valuable data and transactions, making secure management essential. Workloads follow tailored policies to ensure compliance, reliability, and security in line with specific application requirements. Organizing workloads in their own zone enables teams to apply the principle of least privilege by granting only essential permissions and isolating them from other layers. This separation not only enhances security but also allows for more focused performance tuning, monitoring, and cost management—ensuring that each application operates within secure, well-defined boundaries.
By structuring these areas as Identity, Perimeter, and Workloads, organizations can manage access and security through precise policies, applying the principle of least privilege at every layer. This approach simplifies governance, reduces complexity, and ensures that security, compliance, and operational needs are consistently met, giving each team clear roles and boundaries in managing the environment.

### Design impact
These terms (`identity`, `perimeter`, `workloads`) are repetitively used in the documentation to provide a clear understanding of the design principles and the separation of concerns.

The segregation of these layers is key to the modules designs and the way they interact with each other. What is not imposed on the consumer of the modules is the actual implementation of these layers. The consumer can choose to use the modules in a single layer or in a multi-layered approach.

> [!IMPORTANT]
> For most consumers, this decision is made based on the organization's security and compliance requirements and often by the organization's security and compliance teams and not the direct consumer themselves. The consumer should be aware of these requirements and should consult with the organization's security and compliance teams before implementing the modules. It can also occur, that central teams provide the implementation of these layers or own modules as a service to the consumers.
