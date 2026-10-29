#!/bin/bash
set -euo pipefail

dnf install -y httpd

backend_hostname="$(hostname)"

cat > /var/www/html/index.html <<EOF
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>AWS High-Availability Web Application</title>
</head>
<body>
  <h1>AWS High-Availability Web Application</h1>
  <p>Traffic successfully reached an EC2 web server through the Application Load Balancer.</p>
  <p><strong>Backend host:</strong> ${backend_hostname}</p>
</body>
</html>
EOF

systemctl enable --now httpd