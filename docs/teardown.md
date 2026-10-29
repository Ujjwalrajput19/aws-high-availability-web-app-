# Dependency-aware teardown

Delete live lab resources when testing is complete to prevent recurring charges. Stopping EC2 alone is not sufficient because an Application Load Balancer continues to incur charges while provisioned.

## Recommended order

1. **Delete the Application Load Balancer**
   - This removes its listeners and stops future ALB hourly and capacity-unit usage.
2. **Delete the target group**
   - Wait until it is no longer referenced by the load balancer.
3. **Terminate the EC2 instance**
   - Confirm that termination, rather than stop, is intended.
   - Verify whether any attached EBS volume is configured to persist.
4. **Delete the security groups**
   - Wait for ALB and EC2 network interfaces to be released.
   - Delete the EC2 and ALB security groups.
5. **Clean up the IAM role**
   - Detach the instance from the instance profile if necessary.
   - Remove the instance profile, detach the managed policy, and delete the lab role.
6. **Delete the custom route table**
   - Remove explicit subnet associations if they still exist.
   - Delete the public route table.
7. **Detach and delete the Internet Gateway**
8. **Delete both subnets**
9. **Delete the VPC**
10. **Review monitoring artifacts**
    - Delete lab-specific CloudWatch alarms, dashboards, log groups, and flow logs if any were added.

## Final cost and resource check

Review the region used by the lab and confirm that no unintended resources remain:

- EC2 instances and EBS volumes
- Load balancers
- Target groups
- Elastic IP addresses
- NAT gateways
- Network interfaces
- VPC endpoints
- CloudWatch log groups and alarms

Also inspect AWS Billing and Cost Management. Billing data is delayed, so a resource can be gone while its earlier usage still appears.

## What remains after teardown

This GitHub repository remains as the permanent project record:

- architecture and addressing plan;
- security and traffic-flow reasoning;
- reproducible user-data and web content;
- validation results;
- troubleshooting analysis;
- teardown procedure; and
- the roadmap for a Terraform rebuild.

Deleting AWS resources does not delete the documentation or code stored in GitHub.
