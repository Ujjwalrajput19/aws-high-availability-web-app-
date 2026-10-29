# Troubleshooting case study: Session Manager not connected

## Symptom

The EC2 instance was running and passed its status checks, but Session Manager reported:

```text
Ping status: -
Session Manager connection status: Not connected
```

The SSM Agent error included an HTTPS request timeout similar to:

```text
unable to acquire credentials or call UpdateInstanceInformation
Post "https://ssm.ap-south-1.amazonaws.com/":
dial tcp <redacted>:443: i/o timeout
```

## Investigation

The troubleshooting sequence followed the outbound path from the instance:

1. Confirmed the instance was running and passed its EC2 checks.
2. Confirmed the SSM IAM role was attached.
3. Confirmed the role included `AmazonSSMManagedInstanceCore`.
4. Confirmed the instance had a public IPv4 address.
5. Confirmed the subnet route table contained `0.0.0.0/0` to the Internet Gateway.
6. Inspected the EC2 security group's outbound rules.
7. Found that the outbound rule set was empty.

The timeout on destination port 443 was the most useful clue: the agent could not establish the outbound TLS session required to register with Systems Manager.

## Root cause

The instance security group did not permit any new outbound connections. Although the network route existed, the security group blocked the SSM Agent before it could reach the service endpoint.

## Correction

Added an EC2 security-group outbound rule:

| Type | Protocol | Port | Destination |
|---|---|---|---|
| HTTPS | TCP | 443 | `0.0.0.0/0` |

After the rule was applied and the console refreshed, the managed-instance status recovered and Session Manager connected.

The required service port is **TCP 443**. HTTP port 80 is unrelated to the Session Manager control channel.

## Why no inbound SSM rule was required

Session Manager does not initiate a new inbound connection from the AWS console to the instance. The SSM Agent initiates an outbound connection to AWS service endpoints and maintains that secure channel.

Security groups are stateful:

- A new outbound flow must match an outbound rule.
- Return packets for that allowed flow are automatically permitted.
- Stateful behavior does not override the absence of a rule for a brand-new outbound flow.
- No inbound SSH or Session Manager rule is needed for the agent-initiated channel.

This explains why an outbound rule corrected the issue even though no inbound rule was added.

## Interview-ready explanation

> Session Manager failed because the SSM Agent could not initiate its required outbound TLS connection on TCP 443. I verified the IAM instance profile, public addressing, subnet route, and Internet Gateway before finding that the instance security group had no egress rules. After permitting outbound HTTPS, the agent registered and the session opened. No inbound rule was necessary because Session Manager is agent initiated and security groups allow return traffic statefully.

## More private alternatives

A production design can avoid assigning the instance a public IPv4 address by using private subnets with one of these patterns:

- controlled egress through a NAT device; or
- interface VPC endpoints for the Systems Manager services required by the region and agent configuration, commonly `ssm` and `ssmmessages`, with `ec2messages` used by some configurations.

Endpoint security groups must permit HTTPS from the managed instances, and the instance must still have correct IAM permissions and DNS resolution.
