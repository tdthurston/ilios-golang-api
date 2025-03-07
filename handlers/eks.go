package handlers

import (
	"encoding/json"
	"log"
	"os" // Add os import for environment variables

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/eks"
	"github.com/aws/aws-sdk-go/service/sts"
)

func EksInfo() string {
	// Get region from environment variable or use default
	region := os.Getenv("AWS_REGION")
	if region == "" {
		region = "us-east-1" // Default fallback
	}

	// Create a new session using the default credential provider chain
	sess := session.Must(session.NewSession(&aws.Config{
		Region: aws.String(region), // Use dynamic region from environment
	}))

	// Add identity check for debugging
	stsClient := sts.New(sess)
	identity, err := stsClient.GetCallerIdentity(&sts.GetCallerIdentityInput{})
	if err != nil {
		log.Println("ERROR: Failed to get AWS identity:", err)
	} else {
		log.Println("AWS Identity ARN:", *identity.Arn)
		log.Println("AWS Account ID:", *identity.Account)
		log.Println("AWS UserID:", *identity.UserId)
	}

	// Create a new EKS service client
	svc := eks.New(sess)

	// List EKS clusters
	result, err := svc.ListClusters(&eks.ListClustersInput{})
	if err != nil {
		log.Println("Error listing clusters:", err)
		return `{"error": "Unable to retrieve EKS clusters"}`
	}

	// Extract EKS Data
	eksClusters := []map[string]string{}
	for _, clusterName := range result.Clusters {
		describeClusterOutput, err := svc.DescribeCluster(&eks.DescribeClusterInput{Name: clusterName})
		if err != nil {
			log.Println("Error describing cluster:", err)
			continue
		}

		eksData := map[string]string{
			"name":    *describeClusterOutput.Cluster.Name,
			"arn":     *describeClusterOutput.Cluster.Arn,
			"status":  *describeClusterOutput.Cluster.Status,
			"version": *describeClusterOutput.Cluster.Version,
		}
		eksClusters = append(eksClusters, eksData)
	}

	// Convert the EC2 data into JSON format
	eksJSON, err := json.MarshalIndent(map[string]interface{}{"EKS Clusters": eksClusters}, "", "    ")
	if err != nil {
		log.Println("Error marshaling EKS info to JSON:", err)
		return `{"error": "Error processing EKS data"}`
	}

	return string(eksJSON)
}
