# Manual build guide

This guide records the console-built version of the lab. Names are descriptive examples; account-specific IDs and live endpoints are intentionally omitted.

## 1. Create the network

Create a VPC in `ap-south-1`:

- Name: `HA-Web-VPC`
- IPv4 CIDR: `10.10.0.0/16`

Create two subnets:

| Name | Availability Zone | CIDR |
|---|---|---|
| `Ha-Web-Public-Subnet-A` | `ap-south-1a` | `10.10.1.0/24` |
| `Ha-Web-Public-Subnet-B` | `ap-south-1b` | `10.10.2.0/24` |

Create and attach an Internet Gateway named `Ha-Web-IGW`.

Create a route table named `Ha-Web-Public-RT`, associate both subnets, and add:

| Destination | Target |
|---|---|
| `10.10.0.0/16` | Local |
| `0.0.0.0/0` | Internet Gateway |

## 2. Create security groups

### ALB security group

- Inbound: HTTP TCP 80 from `0.0.0.0/0`
- Outbound: HTTP TCP 80 to the EC2 security group

### EC2 security group

- Inbound: HTTP TCP 80 with the ALB security group as the source
- Outbound: HTTPS TCP 443 for Systems Manager and required AWS API access
- Do not add inbound SSH for this lab

Security groups are stateful. Responses to permitted requests are automatically allowed, but a new connection still requires an explicit rule in the direction where it is initiated.

## 3. Create the Systems Manager role

Create an EC2 IAM role and attach the AWS-managed policy:

```text
AmazonSSMManagedInstanceCore
```

Attach the resulting instance profile to the EC2 instance. The lab used the descriptive role name `Ha-Web-EC2-SSM-Role`.

## 4. Launch the web server

Launch an instance with:

- Amazon Linux 2023
- `t3.micro`
- Public Subnet A
- Auto-assigned public IPv4 enabled for this lab design
- EC2 security group
- Systems Manager IAM instance profile
- IMDSv2 required
- No SSH key pair required

Use [scripts/user-data.sh](../scripts/user-data.sh) as user data, or connect through Session Manager and install Apache manually.

## 5. Create the target group

Create an instance target group:

- Protocol: HTTP
- Port: 80
- VPC: `Ha-Web-Lab-VPC`
- Health-check protocol: HTTP
- Health-check path: `/`
- Success code: `200`

Register the EC2 instance as a target.

## 6. Create the load balancer

Create an internet-facing Application Load Balancer:

- IPv4
- Public Subnet A and Public Subnet B
- ALB security group
- HTTP listener on port 80
- Default action forwards to the target group

Wait for the load balancer to become active and for the registered target to become healthy.

## 7. Validate

Follow [validation.md](validation.md) to test Apache locally, target health, the ALB request path, Session Manager, and CloudWatch metrics.

## Important production differences

This lab deliberately starts with a simple public-subnet design. A stronger production pattern would use:

- public subnets for the ALB;
- private subnets for EC2;
- multiple targets across Availability Zones;
- an Auto Scaling group;
- HTTPS with ACM;
- controlled outbound connectivity or Systems Manager VPC endpoints;
- centralized logging and alarms.
