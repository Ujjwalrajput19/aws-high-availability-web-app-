# Validation

## 1. Validate Apache on the instance

Connect through Session Manager and run:

```bash
sudo systemctl is-active httpd
curl -I http://localhost
curl http://localhost
```

Expected results:

- `systemctl` returns `active`.
- The header request returns `HTTP/1.1 200 OK`.
- The body request returns the custom lab page.

## 2. Validate target health

Open the target group and inspect the **Targets** tab.

Expected result:

```text
Health status: Healthy
```

A healthy result proves that the load balancer can reach the instance on the configured target port and that the health-check path returns an accepted status code.

If the target is unhealthy, verify:

1. Apache is running.
2. The health-check path is `/`.
3. The target port is 80.
4. The EC2 security group permits port 80 from the ALB security group.
5. The instance is registered with the correct target group and VPC.

## 3. Validate end-to-end delivery

Open the ALB DNS name in a browser or run:

```bash
curl -I http://ALB-DNS-NAME
curl http://ALB-DNS-NAME
```

Expected result: Expected result: an HTTP 200 response and the AWS High-Availability Web Application page.

Do not commit the live ALB DNS name to a public repository after teardown and recreation; treat endpoints as environment-specific values.

## 4. Validate Session Manager

From the EC2 console, choose **Connect → Session Manager → Connect**.

Expected result: a shell opens without an SSH key or inbound port 22.

For a public-subnet instance, verify all of the following if it does not connect:

- SSM Agent is installed and running.
- The EC2 instance profile includes `AmazonSSMManagedInstanceCore`.
- The instance has a path to the required Systems Manager endpoints.
- The security group permits the agent's outbound HTTPS connection on TCP 443.
- DNS resolution is working.

## 5. Validate monitoring

Relevant namespaces and metrics include:

| Namespace | Example metrics |
|---|---|
| `AWS/EC2` | `CPUUtilization`, `NetworkIn`, `NetworkOut` |
| `AWS/ApplicationELB` | `RequestCount`, `TargetResponseTime`, `HTTPCode_Target_2XX_Count` |
| `AWS/ApplicationELB` with load-balancer and target-group dimensions | `HealthyHostCount`, `UnHealthyHostCount` |

The EC2 **Monitoring** tab shows instance metrics; it does not show ALB target health checks. The target group's **Targets** tab is the immediate health-status view. In CloudWatch, use ApplicationELB metrics with the load-balancer and target-group dimensions to graph `HealthyHostCount` and `UnHealthyHostCount`.

Metrics can appear with a short delay or look sparse when the selected time range and period do not align with recent activity. Generate several requests through the ALB, wait a few minutes, refresh, and select an appropriate period.

 ## Validation status for this repository

The following checks have not yet been performed on this adapted copy:

- Apache service status
- Local web response
- Registered target health
- End-to-end ALB response
- Session Manager connectivity
- CloudWatch metrics

Record the actual results here after performing each check. Results from the original reference project are not evidence that this copy has been deployed or validated.
