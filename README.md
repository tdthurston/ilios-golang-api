# Golang API
Part one of final project for Ilios LLC internship program

This API returns AWS metadata for the currently configured AWS account using the AWS SDK v2 for Go.

Each endpoint will return associated data for VPCs(/vpcs), EC2 instances(/ec2s), or EKS clusters(/eks) using their respective paths, as well as a health check using /health.