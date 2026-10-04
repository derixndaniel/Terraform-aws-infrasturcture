# Terraform AWS Infrastructure Automation

A multi-AZ AWS infrastructure project built using Terraform to demonstrate Infrastructure as Code (IaC), automated cloud provisioning, network segmentation, and load-balanced application delivery.

The infrastructure provisions a custom VPC with public and private subnets across two Availability Zones, EC2 application instances in private subnets, and an internet-facing Application Load Balancer.

## Architecture

```text
                         Internet
                            |
                            v
                  Application Load Balancer
                         HTTP : 80
                       /           \
                      /             \
             Public Subnet 1    Public Subnet 2
                us-east-1a         us-east-1b

                      |             |
                      v             v

             Private Subnet 1   Private Subnet 2
                us-east-1a         us-east-1b
                     |                |
                   EC2-1            EC2-2
                     \                /
                      \              /
                       Target Group
                      (HTTP Port 80)
```

The Application Load Balancer is deployed across the two public subnets, while the application EC2 instances remain isolated inside private subnets.

## Technologies

- Terraform
- AWS
- Amazon VPC
- Amazon EC2
- Application Load Balancer (ALB)
- AWS Security Groups
- Git & GitHub

## Infrastructure Provisioned

Terraform provisions:

- Custom VPC
- 2 public subnets across two Availability Zones
- 2 private subnets across two Availability Zones
- Internet Gateway
- Public route table and subnet associations
- ALB security group
- Application security group
- 2 EC2 application instances
- Application Load Balancer
- Target group
- EC2 target group attachments
- HTTP listener
- Terraform outputs

## Network Design

The project uses a multi-AZ architecture in `us-east-1`.

```text
VPC: 10.0.0.0/16

us-east-1a
├── Public Subnet  : 10.0.0.0/24
└── Private Subnet : 10.0.2.0/24

us-east-1b
├── Public Subnet  : 10.0.11.0/24
└── Private Subnet : 10.0.3.0/24
```

Public subnets are associated with a route table containing a default route to the Internet Gateway.

Application EC2 instances are deployed in private subnets without public IP addresses.

## Security Design

Two security groups are used to separate public and application traffic.

**ALB Security Group**

- Allows inbound HTTP traffic on port `80` from the internet.
- Allows outbound traffic.

**Application Security Group**

- Allows inbound HTTP traffic on port `80` only from the ALB security group.
- EC2 instances are therefore not directly exposed to internet traffic.

Traffic flow:

```text
Internet
   |
   | HTTP :80
   v
Application Load Balancer
   |
   | HTTP :80
   v
Application Security Group
   |
   v
Private EC2 Instances
```

## Dynamic Resource Creation

Terraform `for_each` is used to dynamically provision resources from subnet maps.

For example, public and private subnets are generated from structured variables containing their CIDR blocks and Availability Zones.

The same approach is used to deploy one EC2 application instance into each private subnet and register both instances with the ALB target group.

## Application Validation

Each EC2 instance is bootstrapped using Terraform `user_data` with a lightweight HTTP service listening on port `80`.

The test page identifies the environment and backend instance, allowing the Application Load Balancer routing to be verified.

Example response:

```text
Terraform AWS Infrastructure

Application Load Balancer Working Successfully!

Environment: Dev
Server: private2
```

Both application instances successfully passed the ALB health checks.

## Deployment

Initialize Terraform:

```bash
terraform init
```

Format the configuration:

```bash
terraform fmt
```

Validate the configuration:

```bash
terraform validate
```

Review the infrastructure changes:

```bash
terraform plan
```

Deploy:

```bash
terraform apply
```

After deployment, Terraform outputs the ALB DNS name along with infrastructure identifiers.

The application can then be accessed using:

```text
http://<ALB-DNS-NAME>
```

## Destroying the Infrastructure

The complete environment can be removed using:

```bash
terraform destroy
```

This demonstrates the ability to manage the complete infrastructure lifecycle through Terraform rather than manually creating or deleting AWS resources.

## Project Structure

```text
.
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── .terraform.lock.hcl
├── .gitignore
├── screenshots/
│   ├── vpc-architecture.png
│   ├── alb-healthy-targets.png
│   └── alb-success-response.png
└── README.md
```

## Validation Results

### VPC and Multi-AZ Network Architecture

![VPC Architecture](screenshots/vpc-architecture.png)

The VPC contains four subnets distributed across two Availability Zones, with separate public and private network tiers.

### Application Load Balancer and Healthy Targets

![ALB Healthy Targets](screenshots/alb-healthy-targets.png)

Both private EC2 application instances successfully registered with the target group and passed the Application Load Balancer health checks.

### Successful Application Response

![ALB Successful Response](screenshots/alb-success-response.png)

The application was successfully accessed through the public ALB DNS endpoint while the backend EC2 instances remained within private subnets.

## Terraform Concepts Demonstrated

This project demonstrates practical usage of:

- Infrastructure as Code
- Terraform providers
- Variables and complex variable types
- Resource references and implicit dependencies
- `for_each`
- `for` expressions
- Terraform state
- Terraform outputs
- Resource tagging
- Multi-AZ infrastructure
- AWS network segmentation
- Security-group referencing
- Load balancing
- EC2 bootstrap automation using `user_data`
- Infrastructure lifecycle management

## Future Improvements

Potential production-oriented enhancements include:

- HTTPS using AWS Certificate Manager
- Auto Scaling Groups
- NAT Gateway or controlled outbound connectivity
- Remote Terraform state
- State locking
- Terraform modules
- CloudWatch monitoring and logging
- Route 53 DNS
- CI/CD-based Terraform deployment

## Author

**Derrickson Daniel**

Cloud & DevOps Engineer

GitHub: [derixndaniel](https://github.com/derixndaniel)
