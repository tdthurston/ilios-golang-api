package handlers

import (
	"encoding/json"
	"log"
	"os" // Add this import

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/aws/aws-sdk-go/service/sts"
)

func Ec2Info() string {
	// Get region from environment variable or use default
	region := os.Getenv("AWS_REGION")
	if region == "" {
		region = "us-east-1" // Default fallback
	}

	// Create a new session using the default credential provider chain
	sess := session.Must(session.NewSession(&aws.Config{
		Region: aws.String(region), // Use the region variable, not the literal string
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

	// Create a new EC2 service client
	svc := ec2.New(sess)

	// Describe EC2 instances
	input := &ec2.DescribeInstancesInput{}
	result, err := svc.DescribeInstances(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			default:
				log.Println(aerr.Error())
			}
		} else {
			log.Println(err.Error())
		}
		return "Unable to retrieve EC2 data"
	}

	// Extract EC2 Data
	ec2s := []map[string]string{}
	for _, reservation := range result.Reservations {
		for _, instance := range reservation.Instances {
			ec2Name := ""
			for _, tag := range instance.Tags {
				if *tag.Key == "Name" {
					ec2Name = *tag.Value
					break
				}
			}

			ec2Data := map[string]string{

				"name":  ec2Name,
				"id":    *instance.InstanceId,
				"type":  *instance.InstanceType,
				"state": *instance.State.Name,
			}
			ec2s = append(ec2s, ec2Data)
		}
	}

	// Convert the EC2 data into JSON format
	ec2sJSON, err := json.MarshalIndent(map[string]interface{}{"EC2 Instances": ec2s}, "", "    ")
	if err != nil {
		log.Println("Error marshaling EC2s to JSON:", err)
		return `{"error": "Error processing EC2 data"}`
	}

	return string(ec2sJSON)
}
