package handlers

import (
	"encoding/json"
	"log"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/eks"
)

func EksInfo() string {
	sess := session.Must(session.NewSession())
	sess.Config.Region = aws.String("us-east-1")
	svc := eks.New(sess)

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
